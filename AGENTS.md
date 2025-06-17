# AGENTS.md

## Coding Guidelines for Codex Agents

This document defines the minimum coding standards for implementing Agents in the Codex project.

## Swift Code Guidelines

### Follow SwiftLint rules

All Swift code must comply with the SwiftLint rules defined in the project.

### Avoid abbreviated variable names

Do not use unclear abbreviations such as `res`, `img`, or `btn`.  
Use descriptive and explicit names like `result`, `image`, or `button`.

### Use `.init(...)` when the return type is explicitly known

In contexts where the return type is clear (e.g., function return values, computed properties), use `.init(...)` for initialization.

#### Examples

```swift
var user: User {
  .init(name: "Alice") // ✅ OK: return type is explicitly User
}

func makeUser() -> User {
  .init(name: "Bob") // ✅ OK
}

let user = User(name: "Carol") // ❌ Less preferred when type is not obvious
```

## Markdown Guidelines

### Follow markdownlint rules for Markdown files

All Markdown documents must conform to the rules defined at:  
https://github.com/DavidAnson/markdownlint/blob/main/doc/Rules.md

## Project-wide Conventions

### Use English for naming and comments

Use English for:

- Branch names (e.g., `feature/add-intent-support`, `bugfix/crash-on-startup`)
- Code comments
- Documentation and identifiers (variables, methods, etc.)

Avoid using Japanese or other non-English languages in code unless strictly necessary (e.g., legal compliance, UI text localization).

## Initial Blueprint

> High-level concept and goals for the first public milestone of **Wishle**.  
> Implementation details live in individual prompts and source files.

| Area | Decision | Rationale |
| ---- | -------- | --------- |
| **Product Pillar** | “Store what you *wish* to do, not what you *must* do.” | Differentiates Wishle from Reminders and other GTD apps. |
| **Tech Stack** | Swift 6.2 · SwiftUI · SwiftData + CloudKit · Foundation Models (on-device) | Always adopt the latest iOS APIs; ensure privacy-preserving AI. |
| **Core Models** | `Task`, `Tag` only | Keep schema minimal and extensible—same philosophy as Incomes. |
| **Architecture** | Service-oriented (Cookle pattern) + AppIntent command layer | Enables Codex-generated services to be shared across apps. |
| **Monetization** | Free tier (local only, ads) / Pro tier (iCloud sync, no ads) | Mirrors Incomes paywall flow for reuse. |
| **Brand Assets** | Name **Wishle**; mascot **Bluebird**; palette `#3A8DFF` / `#FFD64D` | Consistent with Cookle & Nyanble series styling. |
| **Agents Roles** | `codex-dev` generates code · `gpt-review` reviews · `ci-runner` tests · `release-bot` ships | Defined above; included here for quick reference. |
| **MVP Scope** | Add/Update/Delete Task, basic AI suggestions, Widget (Next Up) | Aim for TestFlight within 4 weeks after repo bootstrap. |

### Next Steps

1. Bootstrap Xcode project with **App + SwiftData + CloudKit** template.  
2. Commit `/prompts` directory with Task/Tag model prompts.  
3. Enable `generate.yml` workflow and run the first Codex generation.  
4. Integrate paywall flow reusing `SubscriptionManager` from Incomes.  
5. Prepare App Store Connect metadata draft (screenshots can use placeholder icons).
