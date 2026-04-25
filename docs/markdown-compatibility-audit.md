# Markdown Compatibility Audit

## 概览

本文记录 Tsubame 在 Stage 7.2D 中对 Raptor Markdown 文章管线的兼容性审计结果。它是 audit-only 文档：只记录当前真实渲染行为、作者侧注意事项和已知缺口，不在本阶段添加本地 Markdown renderer workaround。

当前审计入口和验证材料：

- 线上路由夹具：`/posts/markdown-compatibility-lab/`
- 夹具源文件：`Posts/pages/markdown-compatibility-lab.md`
- 发布测试：`Tests/RaptorTsubameTests/Publishing/MarkdownCompatibilityPublishingTests.swift`
- 上游缺陷记录：`docs/upstream-raptor-markdown-list-paragraph-bug.md`

## 行为矩阵

| 分类 | Markdown/HTML 模式 | 当前行为 | 维护说明 |
| --- | --- | --- | --- |
| Supported | 普通段落、H2+ headings、strong/emphasis、链接 | 正常生成对应 HTML，并经过文章页管线发布。 | 作为基础作者语法使用；首个 H1 会被 Raptor 作为文章标题消费，在 `removeTitleFromBody` 为 true 时不会保留在 Markdown body 输出中。 |
| Supported | Inline code、fenced code | 代码内容按文本输出，HTML 片段在代码语境中会被转义。 | HTML 示例应优先放在 fenced code 中。 |
| Supported | 图片、简单有序/无序列表、blockquote、table、horizontal rule | 当前夹具和测试覆盖到生成结构，样式由 scoped Markdown CSS 处理。 | 复杂排版发布前仍建议检查生成 HTML。 |
| Supported with security expectation | raw HTML block、inline HTML | Raptor/Tsubame 当前策略是允许 raw HTML 在代码块外作为真实 HTML 输出。 | 只在文章确实需要真实 HTML 时使用；不要把不可信输入当作 raw HTML 发布。 |
| Supported with security expectation | HTML inside inline/fenced code | 代码中的 HTML 必须保持转义；来自代码示例的 literal `<script>` 不应作为真实脚本标签出现在输出中。 | 发布测试已覆盖 inline 和 fenced HTML code 的转义期望。 |
| Known broken/upstream | Multi-Paragraph List Items | Raptor 当前会压平 list item 内部的多个 paragraph，导致文本边界丢失。 | 详见 `docs/upstream-raptor-markdown-list-paragraph-bug.md`。 |
| Known broken/upstream | list item 中嵌套 paragraph 后再接 blockquote/code 等复杂块 | 基础内容可见，但周边 paragraph 结构受同一个上游 list paragraph 行为影响。 | 如果可读性重要，避免把复杂块塞进同一个 list item。 |
| Not covered yet | footnote、definition list、task list、Markdown 扩展语法 | Stage 7.2D 未覆盖。 | 需要真实文章需求或上游支持确认后再加入夹具和测试。 |
| Not covered yet | 数学公式、diagram、自定义 shortcode | Stage 7.2D 未覆盖。 | 这些不属于当前 Raptor Markdown baseline。 |

## 已知缺口：Multi-Paragraph List Items

已单独记录在：

- `docs/upstream-raptor-markdown-list-paragraph-bug.md`

当前结论是：Raptor 的 `MarkdownToHTML.visitParagraph(_:)` 对 list 内 paragraph 省略 `<p>` 包裹，`visitListItem(_:)` 又直接拼接子节点输出，因此 multi-paragraph list item 会丢失段落边界。这不是 Tsubame CSS 能可靠修复的问题，因为结构在 HTML 生成阶段已经丢失。

作者侧建议：

- 暂时避免在同一个 list item 内写多个段落。
- 如果需要解释性段落，把说明放到 list 外部，或拆成独立段落。
- 对 list item 中嵌套 blockquote/code 的复杂结构，发布前检查生成 HTML。

## Raw HTML 策略

Tsubame 当前保留 Raptor 的 raw HTML 行为：代码块外的 raw HTML 是有意允许的，可以作为真实 HTML 输出。这适合少量受控文章增强，但不应处理不可信输入。

代码语境相反：inline code 和 fenced code 内的 HTML 必须作为文本展示并被转义。尤其是代码示例里的 literal `<script>` 不应作为真实 `<script>` 标签进入发布 HTML。

## 为什么这不是 workaround

Stage 7.2D 的目标是建立兼容性基线，而不是接管 Markdown renderer。此审计文档、夹具页和发布测试只描述真实 Raptor 行为，避免在 Tsubame 内临时修补上游 renderer 输出。

未来只有在真实文章频繁受到影响时，再考虑两类方案：

- 优先提交或跟进 Raptor 上游 issue，等待上游修复 list paragraph 结构。
- 如必须本地处理，再评估自定义 renderer 或窄范围 post-processing；这会增加 Tsubame 对 Markdown 渲染细节的维护责任，应谨慎进入。
