---
title: Markdown Compatibility Lab
date: 2026-04-26
description: Fixture for auditing Raptor Markdown compatibility in Tsubame.
kind: page
layout: ArticlePage
path: /posts/markdown-compatibility-lab/
published: true
category: Notes
tags: Raptor, Markdown
---

# Markdown Compatibility Lab

compat-basic-paragraph-marker: This page audits Markdown structures rendered through the Tsubame article pipeline.

## Basic Inline Markup

compat-inline-marker: This paragraph includes **strong text**, *emphasis*, [an external link](https://example.com), and `inline code`.

![Compatibility image marker](/images/tsubame-cover.svg)

## Ordered And Unordered Lists

compat-basic-list-marker:

1. First ordered item
2. Second ordered item

- First unordered item
- Second unordered item

## Nested Lists

compat-nested-list-marker:

1. Parent ordered item
   - Nested unordered child
   - Nested unordered sibling
2. Second parent ordered item

## Multi-Paragraph List Item

compat-multiparagraph-list-marker:

1. **"Elegant" abstractions can be misleading**

   A unified system looks great on paper, but may not fit the existing architecture.

2. Second item after the known bug sample

## List Item With Blockquote

compat-list-blockquote-marker:

1. List item before quote

   > A quote nested under a list item should remain visibly distinct.

2. List item after quote

## List Item With Fenced Code

compat-list-code-marker:

1. List item before code

   ```swift
   let nested = "code"
   print(nested)
   ```

2. List item after code

## Blockquote With Multiple Paragraphs

compat-blockquote-marker:

> First paragraph in a blockquote.
>
> Second paragraph in the same blockquote.

## Table

compat-table-marker:

| Pattern | Status |
| --- | --- |
| Table rendering | Supported |
| Wide content | Scroll candidate |

---

compat-hr-marker: Text after a horizontal rule.

## Raw HTML And HTML Code

compat-raw-html-marker:

<div data-compat-raw-html="true">Raw HTML should render as HTML.</div>

compat-inline-html-marker: <span data-compat-inline-html="true">Inline HTML should render as HTML.</span>

compat-fenced-html-code-marker:

Inline hostile code: `</code><script>alert("inline")</script>`.

```html
</code><script>alert("block")</script>
```

compat-existing-entity-marker: `&lt;already escaped="true"&gt;`
