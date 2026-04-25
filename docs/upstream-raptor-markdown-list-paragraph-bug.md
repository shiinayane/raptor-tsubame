# Upstream Raptor Bug: List Paragraphs Are Flattened

## Status

- Upstream issue: not submitted yet.
- Local workaround: none.
- Priority: medium-high for article readability.
- Affected area: Raptor Markdown rendering, not Tsubame CSS.

## Summary

Raptor's Markdown renderer flattens paragraphs inside list items. When a list item contains multiple paragraphs, the rendered HTML concatenates paragraph text directly inside `<li>` without paragraph wrappers or visible separation.

This makes Markdown like an ordered list item with a bold heading and an indented paragraph render as one continuous line.

## Reproduction

Markdown:

```markdown
1. **"Elegant" abstractions can be misleading**

   A unified system looks great on paper, but may not fit the existing architecture.
```

Observed rendered text:

```text
1. "Elegant" abstractions can be misleadingA unified system looks great on paper, but may not fit the existing architecture.
```

The second paragraph loses its paragraph boundary and is concatenated directly after the bold text.

## Expected HTML

For a list item containing multiple paragraphs, the rendered HTML should preserve block structure:

```html
<ol>
  <li>
    <p><strong>"Elegant" abstractions can be misleading</strong></p>
    <p>A unified system looks great on paper, but may not fit the existing architecture.</p>
  </li>
</ol>
```

An acceptable minimal output would at least preserve visible separation between child paragraphs inside the list item.

## Actual Root Cause

The issue is in Raptor's `MarkdownToHTML`.

Relevant upstream files in the checked-out dependency:

- `.build/checkouts/raptor/Sources/Raptor/Rendering/Markdown/MarkdownToHTML.swift`
- `.build/checkouts/raptor/Sources/Raptor/Rendering/Markdown/Markup+IsInsideList.swift`

`visitParagraph(_:)` omits `<p>` wrappers for any paragraph inside a list:

```swift
if paragraph.isInsideList == false {
    result += "<p>"
}
```

`Markup.isInsideList` returns true for markup nested inside a list item:

```swift
self is ListItemContainer || parent?.isInsideList == true
```

Then `visitListItem(_:)` concatenates all child output directly:

```swift
var result = "<li>"

for child in listItem.children {
    result += visit(child)
}

result += "</li>"
```

Together, these rules produce:

```html
<li><strong>"Elegant" abstractions can be misleading</strong>A unified system looks great on paper...</li>
```

The paragraph boundary is already lost before CSS runs, so this cannot be fixed reliably with `markdown-reading.css`.

## Why This Belongs Upstream

Tsubame's scoped Markdown CSS can style valid list markup, but it cannot recover paragraph structure that Raptor does not emit.

This behavior affects any Raptor site that uses multi-paragraph list items, not just this project.

## Issue Draft Notes

Suggested issue title:

```text
Markdown renderer flattens multi-paragraph list items
```

Suggested issue body points:

- Raptor version: dependency from `Package.swift`, currently `from: "0.1.2"`.
- Markdown input with a list item containing a bold first paragraph and an indented second paragraph.
- Current output concatenates the two paragraphs inside one `<li>`.
- Expected output should preserve `<p>` wrappers for multi-paragraph list items.
- Root cause appears to be `visitParagraph(_:)` dropping paragraph wrappers whenever `paragraph.isInsideList == true`, combined with `visitListItem(_:)` direct child concatenation.
- This is not a visual CSS issue because the emitted DOM lacks a structural boundary.

## Local Follow-Up Options

Option A: wait for upstream fix and keep this documented.

Option B: implement a temporary custom Markdown processor locally. This is higher risk because our current `SafeMarkdownToHTML` delegates to Raptor's `MarkdownToHTML`; fully fixing list paragraphs would require taking over more of the renderer behavior.

Preferred current action: submit upstream issue first, then decide whether a local workaround is necessary based on frequency and severity in real posts.
