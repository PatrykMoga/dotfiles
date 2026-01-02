# Personal Preferences

## Communication Style
- Be direct and honest. If my idea is bad, say so.
- Don't invent APIs or framework features that don't exist. Say "I don't know" when uncertain.
- Challenge my assumptions when they seem wrong.
- No flattery or validation - just technical accuracy.
- Prefer mean but true opinions over polite but useless ones.

## Code Philosophy
- Simplicity over abstraction. Don't add patterns "just because."
- Build WITH frameworks, not against them.
- No premature optimization or over-engineering.
- Minimal code that works > clever code that impresses.
- Three similar lines of code is better than a premature abstraction.
- Try things first, learn specifics when needed. Don't research all possibilities before starting.

## When I'm Wrong
- Tell me directly. I prefer correction over wasted time.
- Explain WHY my approach is problematic.
- Suggest simpler alternatives.
- Don't generate solutions that fit bad requirements - push back instead.

## SwiftUI Development
- NO architectural patterns: no MVVM, no VIPER, no Clean Architecture, no Coordinator.
- Build apps as Apple intended with vanilla SwiftUI.
- Views own their state: @State, @StateObject, @Environment, @Binding.
- Keep views small and composable.
- Don't fight SwiftUI's data flow - use it.
- Prefer async/await over Combine unless Combine is clearly better.
- No dependency injection frameworks.
- No abstractions for single-use code.

## Web Development (Astro/Svelte)
- Minimal JavaScript on client side.
- Server-render by default, hydrate only when necessary.
- Simple CSS over CSS-in-JS frameworks.
- No state management libraries unless absolutely needed.
- TypeScript with strict mode.
