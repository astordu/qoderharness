# CONTEXT.md 格式

## 结构

```md
# {上下文名称}

{一到两句话，说明这个上下文是什么、为什么存在。}

## Language

**Order**:
{对该术语的一到两句话描述}
_Avoid_: Purchase, transaction

**Invoice**:
交付后发送给客户的付款请求。
_Avoid_: Bill, payment request

**Customer**:
下订单的个人或组织。
_Avoid_: Client, buyer, account
```

## 规则

- **要有主见。** 当同一个概念存在多个词时，挑选最好的那个，把其余的列在 `_Avoid_` 下。
- **定义要精炼。** 最多一到两句。定义它 *是什么*，而不是它 *做什么*。
- **只收录本项目上下文所特有的术语。** 通用编程概念（超时、错误类型、工具模式）不属于此处，即便项目大量使用它们也不例外。在添加一个术语前先问：这是本上下文独有的概念，还是一个通用编程概念？只有前者才属于这里。
- **当自然形成聚类时，把术语归到子标题下。** 如果所有术语都属于同一个内聚的领域，那么用一个扁平列表也没问题。

## 单上下文与多上下文仓库

**单上下文（大多数仓库）：** 仓库根目录下有一个 `CONTEXT.md`。

**多上下文：** 仓库根目录下的 `CONTEXT-MAP.md` 列出各个上下文、它们所在的位置，以及它们之间如何关联：

```md
# Context Map

## Contexts

- [Ordering](./src/ordering/CONTEXT.md) — 接收并跟踪客户订单
- [Billing](./src/billing/CONTEXT.md) — 生成发票并处理付款
- [Fulfillment](./src/fulfillment/CONTEXT.md) — 管理仓库拣货与发货

## Relationships

- **Ordering → Fulfillment**: Ordering 发出 `OrderPlaced` 事件；Fulfillment 消费这些事件以开始拣货
- **Fulfillment → Billing**: Fulfillment 发出 `ShipmentDispatched` 事件；Billing 消费这些事件以生成发票
- **Ordering ↔ Billing**: 共享 `CustomerId` 与 `Money` 类型
```

技能会推断适用哪种结构：

- 如果存在 `CONTEXT-MAP.md`，读取它以找到各上下文
- 如果只存在根目录的 `CONTEXT.md`，则为单上下文
- 如果两者都不存在，在第一个术语被确定下来时延迟创建根目录的 `CONTEXT.md`

当存在多个上下文时，推断当前话题与哪一个相关。如果不清楚，就询问。
