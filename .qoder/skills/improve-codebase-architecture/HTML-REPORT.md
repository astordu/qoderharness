# HTML 报告格式

架构审查会被渲染成一个自包含的 HTML 文件，放在操作系统的临时目录中。Tailwind 和 Mermaid 都来自 CDN。Mermaid 可靠地处理图状图表；手工构建的 div 和内联 SVG 处理更有编排感的视觉元素（体量图、剖面图）。把两者混用——不要什么都靠 Mermaid，那样会开始显得千篇一律。

## 脚手架

```html
<!doctype html>
<html lang="en">
  <head>
    <meta charset="utf-8" />
    <title>Architecture review — {{repo name}}</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <script type="module">
      import mermaid from "https://cdn.jsdelivr.net/npm/mermaid@11/dist/mermaid.esm.min.mjs";
      mermaid.initialize({ startOnLoad: true, theme: "neutral", securityLevel: "loose" });
    </script>
    <style>
      .seam { stroke-dasharray: 4 4; }
      .leak { stroke: #dc2626; }
      .deep { background: linear-gradient(135deg, #0f172a, #1e293b); }
    </style>
  </head>
  <body class="bg-stone-50 text-slate-900 font-sans">
    <main class="max-w-5xl mx-auto px-6 py-12 space-y-12">
      <header>...</header>
      <section id="candidates" class="space-y-10">...</section>
      <section id="top-recommendation">...</section>
    </main>
  </body>
</html>
```

## 页眉

仓库名、日期，以及一个紧凑的图例：实心方框 = 模块，虚线 = 接缝，红色箭头 = 泄漏，粗黑边方框 = 深模块。不要引言段落——直接进入候选项。

## 候选项卡片

每个候选项是一个 `<article>`：

- **Title**（标题）——简短，点明这次加深（例如 "Collapse the Order intake pipeline / 收拢订单接收流水线"）。
- **Badge row**（徽章行）——推荐强度（`Strong` = 翠绿，`Worth exploring` = 琥珀，`Speculative` = 石板灰），外加一个标注依赖类别的标签。
- **Files**（文件）——等宽字体列表，`font-mono text-sm`。
- **Before / After diagram**（前/后对比图）——核心。两栏并排。
- **Problem**（问题）——一句话。哪里疼。
- **Solution**（方案）——一句话。改什么。
- **Wins**（收益）——要点，每条 ≤6 个词。
- **ADR callout**（ADR 提示，如适用）——琥珀色调框中的一行字。

## 图表模式

### Mermaid 图（处理依赖 / 调用流的主力）

```html
<div class="rounded-lg border border-slate-200 bg-white p-4">
  <pre class="mermaid">
    flowchart LR
      A[OrderHandler] --> B[OrderValidator]
      B --> C[OrderRepo]
      C -.leak.-> D[PricingClient]
      classDef leak stroke:#dc2626,stroke-width:2px;
      class C,D leak
  </pre>
</div>
```

### 手工构建的方框与箭头

模块用带边框和标签的 `<div>` 表示。箭头用内联 SVG 元素表示。当你想让"后"图呈现为一个厚边框的深模块、内部结构灰化时使用。

### 剖面图（适合分层的浅结构）

堆叠水平的横条（`h-12 border-l-4`）来展示一次调用穿过的层级。前：6 个薄层，各自什么都没做。后：1 个厚横条，标注合并后的职责。

### 体量图（适合"接口和实现一样宽"）

每个模块两个矩形——一个表示接口的表面积，一个表示实现。前：接口矩形几乎和实现一样高（浅）。后：接口矮，实现高（深）。

### 调用图坍缩

前：一棵函数调用树，渲染成嵌套的方框。后：坍缩成一个方框，内部调用以淡化的样式显示在里面。

## 样式指南

- 走编排排版风，而非企业仪表盘风。留白慷慨。
- 用色克制：一种强调色（翠绿或靛蓝），加上表示泄漏的红色和表示警告的琥珀色。
- 让图表高度约 320px，好让前/后对比舒适地并排放置。
- 图表内部的模块标签用 `text-xs uppercase tracking-wider`。
- 唯一的脚本是 Tailwind CDN 和 Mermaid ESM import。没有应用代码，没有交互性。

## 首推（Top recommendation）小节

一张更大的卡片。候选项名称、一句话说明理由，以及指向其卡片的锚点链接。

## 语气

**只用这些词：** module、interface、implementation、depth、deep、shallow、seam、adapter、leverage、locality。

**绝不替换成：** component、service、unit · API、signature · boundary · layer、wrapper。

**契合的措辞：**
- "Order intake module is shallow — interface nearly matches the implementation."
- "Pricing leaks across the seam."
- "Deepen: one interface, one place to test."
- "Two adapters justify the seam: HTTP in prod, in-memory in tests."

**收益要点** 用词汇表里的术语来点明所得：*"locality: bugs concentrate in one module"*、*"leverage: one interface, N call sites"*。
