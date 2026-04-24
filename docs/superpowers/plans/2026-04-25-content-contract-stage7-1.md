# Content Contract Stage 7.1 Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add the Stage 7.1 Fuwari-aligned metadata contract for `image`, `updated`, and `lang` while preserving existing Raptor publishing semantics.

**Architecture:** Keep custom front matter parsing centralized in `SiteContentMetadata`. Add enum-backed metadata keys and read-only optional properties, then protect behavior with data-only tests. Do not change route generation, article rendering, image rendering, or draft publishing behavior in this stage.

**Tech Stack:** Swift, Raptor, Swift Testing, existing `SiteContentMetadata` and `SiteContentLoader` content layer.

---

## File Structure

- Modify `Sources/Content/SiteContentKind.swift`
  - Add enum cases for `image`, `updated`, `lang`, and `draft`.
  - Keep this file as the shared key/type vocabulary for content metadata.
- Modify `Sources/Content/SiteContentMetadata.swift`
  - Add optional `image`, `updated`, and `lang` computed properties.
  - Add `isDraftMarked` only for compatibility testing/documentation, not for publishing decisions.
  - Reuse the existing `trimmedValue(for:)` helper.
- Modify `Tests/RaptorTsubameTests/Content/ContentMetadataTests.swift`
  - Extend the shared parser normalization test for new fields.
  - Add a test proving empty values default to `nil`.
  - Add a test proving `draft: true` does not change `isPublished`.
- No changes to `Sources/Content/SiteContentLoader.swift`
  - Preparation-time descriptors do not need these fields yet.
- No changes to page/component rendering
  - Stage 7.1 is a metadata contract stage, not visible UI.

## Task 1: Add Failing Metadata Contract Tests

**Files:**
- Modify: `Tests/RaptorTsubameTests/Content/ContentMetadataTests.swift`

- [ ] **Step 1: Extend the existing normalization test**

In `sharedSiteMetadataParserNormalizesCustomContentFields()`, change the metadata dictionary and expectations to include `image`, `updated`, `lang`, and `draft`:

```swift
let metadata = SiteContentMetadata(
    [
        "kind": "page",
        "published": "FALSE",
        "path": " about ",
        "category": " Notes ",
        "tags": "Raptor, Swift, ",
        "image": " ./cover.jpg ",
        "updated": " 2026-04-25 ",
        "lang": " zh_CN ",
        "draft": "true"
    ]
)

#expect(metadata.kind == .page)
#expect(metadata.isPublished)
#expect(metadata.path == "about")
#expect(metadata.category == "Notes")
#expect(metadata.tags == ["Raptor", "Swift"])
#expect(metadata.image == "./cover.jpg")
#expect(metadata.updated == "2026-04-25")
#expect(metadata.lang == "zh_CN")
#expect(metadata.isDraftMarked)
```

- [ ] **Step 2: Add a nil-default test for optional Fuwari-aligned fields**

Add this test below the normalization test:

```swift
@Test("Fuwari aligned metadata fields default to nil when absent or empty")
func fuwariAlignedMetadataFieldsDefaultToNil() {
    let metadata = SiteContentMetadata(
        [
            "image": " ",
            "updated": "",
            "lang": "\n"
        ]
    )

    #expect(metadata.image == nil)
    #expect(metadata.updated == nil)
    #expect(metadata.lang == nil)
    #expect(!metadata.isDraftMarked)
}
```

- [ ] **Step 3: Add a draft compatibility test**

Add this test near `publishedMetadataFollowsRaptorBoolParsing()`:

```swift
@Test("draft metadata is compatibility-only and does not affect publishing")
func draftMetadataDoesNotAffectPublishing() {
    let metadata = SiteContentMetadata(
        [
            "published": "true",
            "draft": "true"
        ]
    )

    #expect(metadata.isPublished)
    #expect(metadata.isDraftMarked)
}
```

- [ ] **Step 4: Run the focused tests and verify failure**

Run:

```bash
swift test --filter ContentMetadataTests
```

Expected: FAIL because `SiteContentMetadata` does not yet expose `image`, `updated`, `lang`, or `isDraftMarked`.

## Task 2: Implement Metadata Keys And Accessors

**Files:**
- Modify: `Sources/Content/SiteContentKind.swift`
- Modify: `Sources/Content/SiteContentMetadata.swift`

- [ ] **Step 1: Add enum cases**

In `SiteContentMetadataKey`, add:

```swift
case image
case updated
case lang
case draft
```

The enum should become:

```swift
enum SiteContentMetadataKey: String, Sendable {
    case kind
    case published
    case path
    case category
    case tags
    case image
    case updated
    case lang
    case draft
}
```

- [ ] **Step 2: Add optional field accessors**

In `SiteContentMetadata`, add these computed properties after `tags`:

```swift
var image: String? {
    trimmedValue(for: .image)
}

var updated: String? {
    trimmedValue(for: .updated)
}

var lang: String? {
    trimmedValue(for: .lang)
}

var isDraftMarked: Bool {
    Bool(stringValue(for: .draft) ?? "") ?? false
}
```

Reasoning:

- `image`, `updated`, and `lang` use the existing trimmed optional semantics.
- `isDraftMarked` is explicit compatibility metadata.
- `isPublished` remains unchanged, so `draft` never overrides Raptor-facing publishing.

- [ ] **Step 3: Run the focused tests and verify pass**

Run:

```bash
swift test --filter ContentMetadataTests
```

Expected: PASS for the content metadata suite.

## Task 3: Run Full Verification And Inspect Scope

**Files:**
- Verify: all modified files

- [ ] **Step 1: Run the full test suite**

Run:

```bash
swift test
```

Expected: all tests pass.

- [ ] **Step 2: Confirm no unintended rendering changes**

Run:

```bash
git diff -- Sources Tests
```

Expected: only metadata key/accessor changes and metadata tests changed. No page, component, style, route, or content fixture files changed.

- [ ] **Step 3: Inspect git status**

Run:

```bash
git status --short
```

Expected: only these files are modified:

```text
 M Sources/Content/SiteContentKind.swift
 M Sources/Content/SiteContentMetadata.swift
 M Tests/RaptorTsubameTests/Content/ContentMetadataTests.swift
```

## Task 4: Commit Stage 7.1 Metadata Contract

**Files:**
- Commit: `Sources/Content/SiteContentKind.swift`
- Commit: `Sources/Content/SiteContentMetadata.swift`
- Commit: `Tests/RaptorTsubameTests/Content/ContentMetadataTests.swift`

- [ ] **Step 1: Stage implementation files**

Run:

```bash
git add Sources/Content/SiteContentKind.swift Sources/Content/SiteContentMetadata.swift Tests/RaptorTsubameTests/Content/ContentMetadataTests.swift
```

- [ ] **Step 2: Commit**

Run:

```bash
git commit -m "feat: add content metadata contract fields"
```

Expected: commit succeeds with only the Stage 7.1 metadata contract implementation.

## Self-Review Notes

- Spec coverage: The plan implements `image`, `updated`, and `lang`; documents `draft` through an explicit compatibility accessor; preserves `published`; defers rendering, series, pinned, and TOC.
- Placeholder scan: No implementation placeholders are intentionally left in the task steps.
- Type consistency: All new names are `SiteContentMetadata.image`, `SiteContentMetadata.updated`, `SiteContentMetadata.lang`, and `SiteContentMetadata.isDraftMarked`.
