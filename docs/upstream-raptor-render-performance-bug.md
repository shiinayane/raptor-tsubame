# Upstream Raptor Bug: Repeated HTML Rendering Is CPU-Heavy

## Status

- Upstream issue: not submitted yet.
- Local workaround: persistent published-site test cache.
- Priority: high for developer experience once pages use many modifiers and layout primitives.
- Affected area: Raptor HTML rendering, modifier rendering, and subview flattening.

## Summary

Publishing this small Tsubame site is unexpectedly CPU-heavy. The site has only a small content set, but a cold publish from tests can take roughly three minutes on this machine. Sampling shows the time is dominated by Raptor's HTML rendering path, not by SwiftPM compilation, Markdown file volume, or disk output.

This appears to come from repeated subtree rendering during modifier handling and subview flattening.

## Local Evidence

Cold publishing test before cache reuse:

```text
swift test --filter ContentMetadataTests/publishedSiteHelperReusesGeneratedOutput
real 188.71
user 360.34
sys 31.29
test body: 185.067 seconds
```

The same test after the local persistent test cache was populated:

```text
swift test --filter ContentMetadataTests/publishedSiteHelperReusesGeneratedOutput
real 0.99
test body: 0.158 seconds
```

This confirms the expensive part is the publish/render step, not the assertion logic.

Direct executable timing during investigation also showed CPU-bound behavior:

```text
.build/debug/RaptorTsubame
real 144.10
user 134.41
sys 3.32
```

## Sampled Hot Path

`sample` showed the dominant stack inside Raptor's render pipeline:

```text
Site.publish
SitePublisher.publish
RenderingContext.render
Document.markupString
PlainDocument.render
Main.render
HTML.markupString
ModifiedHTML.render
ModifiedContentProxy.render
Tag.render
SubviewCollection.render
Subview.render
SubviewCollection.collectFlattenedChildren
HTML.isEmptyHTML
```

The sampled stack repeatedly cycles through `ModifiedHTML`, `ModifiedContentProxy`, `Subview`, `SubviewCollection`, `Tag`, and layout primitives such as `VStack`.

## Suspected Root Cause

Relevant upstream files in the checked-out dependency:

- `../raptor/Sources/Raptor/Framework/ElementTypes/HTML.swift`
- `../raptor/Sources/Raptor/Framework/Modifiers/ModifiedContentProxy.swift`
- `../raptor/Sources/Raptor/Framework/SubviewTypes/SubviewCollection.swift`

`HTML.markupString()` always renders:

```swift
func markupString() -> String {
    render().string
}
```

`HTML.isEmptyHTML` also renders:

```swift
var isEmptyHTML: Bool {
    render().isEmpty
}
```

`ModifiedContentProxy.render()` renders content to inspect the leading tag:

```swift
} else if content.body.isPrimitive, content.markupString().hasPrefix("<div") {
```

and may render again when returning the final markup:

```swift
return Markup("<div\(attributes)>\(content.markupString())</div>")
```

`SubviewCollection.collectFlattenedChildren` uses `isEmptyHTML` while recursively flattening children:

```swift
if !html.isEmptyHTML {
    result.append(Subview(html))
}
```

Together, these code paths can repeatedly render the same nested subtree for structural checks before the final output is emitted.

## Why This Belongs Upstream

Tsubame can reduce how often tests publish the site, but it cannot make Raptor's render pipeline cheaper without patching Raptor itself. The repeated render behavior is framework-level and should affect any Raptor site with nested layout primitives, modifiers, styles, and variadic children.

## Local Workaround

Tsubame now keeps a persistent published-site test cache under:

```text
.build/raptor-tsubame-test-sites/published-<fingerprint>
```

The cache fingerprint includes local site inputs and the checked-out Raptor source tree. This keeps repeated `swift test --filter ...` publishing tests fast when the generated output inputs have not changed.

This is only a developer-experience mitigation. It does not reduce cold publish time.

## Issue Draft Notes

Suggested issue title:

```text
HTML rendering repeatedly renders subtrees during modifier and subview handling
```

Suggested issue body points:

- Raptor version: dependency from `Package.swift`, currently `from: "0.1.2"`.
- A small Raptor site can spend minutes in cold publish despite small output size.
- Sampling points to `ModifiedHTML.render`, `ModifiedContentProxy.render`, `SubviewCollection.render`, `SubviewCollection.collectFlattenedChildren`, and `HTML.isEmptyHTML`.
- `ModifiedContentProxy.render()` calls `content.markupString()` for structural checks, which renders the subtree.
- `HTML.isEmptyHTML` also renders the subtree and is called during subview flattening.
- Consider avoiding render-for-inspection, caching rendered markup during a render pass, or preserving structural metadata without converting full subtrees to strings.

## Related Local Context

- Test helper cache: `Tests/RaptorTsubameTests/Support/TestSupport.swift`
- Existing Markdown upstream issue note: `docs/upstream-raptor-markdown-list-paragraph-bug.md`
