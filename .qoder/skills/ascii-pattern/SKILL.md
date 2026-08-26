# Pattern Library

## Box Diagrams

```
┌─────────────────┐
│  Component A    │
│  (Description)  │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│  Component B    │
└─────────────────┘
```

## File Trees

```
test-orchestration-demo/
├── .claude/
│   ├── skills/           ⭐ This skill!
│   └── instructions/
├── Docs/
│   └── results-implementation/
└── frontend/             ✨ 7-folder architecture
    ├── app/              (Next.js routes)
    ├── modules/          (Feature modules)
    ├── shared/           (UI components)
    ├── lib/              (Integrations)
    ├── store/            (Global state)
    ├── styles/           (Design system)
    └── types/            (TypeScript)
```

## Flow Charts

```
User Answer
     │
     ▼
tRPC Endpoint
     │
     ▼
Claude AI → Evaluation
     │
     ▼
Results Store → UI
```

## Comparison Tables

```
┌──────────────────────────────────────────┐
│    BEFORE (17 folders)  AFTER (7 folders)│
├──────────────────────────────────────────┤
│  Complexity: High      Simple     -60% ⬇️│
│  Type Safety: 70%      100%       +30% ✅│
│  Code Lines: 3,455     2,500     -955 🧹│
│  Build Time: 8.5s      7.2s      -15% ⚡│
└──────────────────────────────────────────┘
```

## Progress Bars

```
DevPrep AI - Results Analytics
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Tab 1: Overview      ████████████████ 100% ✅
Tab 2: Questions     ████████████████ 100% ✅
Tab 3: Hint Analytics████████████████ 100% ✅
Tab 4: Insights      ████████████████ 100% ✅
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

## Box-Drawing Characters

```
┌─┬─┐  ╔═╦═╗  Basic boxes
├─┼─┤  ╠═╬═╣  Heavy boxes
└─┴─┘  ╚═╩═╝  Rounded corners

│ ║    Vertical lines
─ ═    Horizontal lines

▲ ▼    Arrows
► ◄    Arrows horizontal

✅ ❌  Status indicators
🚧 📋  Progress states
⭐ 🔥  Priorities
```
