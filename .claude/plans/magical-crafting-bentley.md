# Plan: Task Updates for SpeakCraft

## Overview

Update task #21 with proper multi-language speech recognition research, and create three new tasks.

---

## Task #21: Multi-Language Support (UPDATE)

### Research Findings

The original fix (`SFSpeechRecognizer()` without locale) was too simple.

**Why it didn't work:**
1. `SFSpeechRecognizer()` uses system's speech recognition language setting, NOT `Locale.current`
2. Recognizer created once at class init - if user changes language, old instance persists
3. No UI to select language
4. No check for on-device support per language

**Correct implementation:**
```swift
// Get available languages
let supported = SFSpeechRecognizer.supportedLocales()

// Create recognizer dynamically with user's chosen locale
func setLanguage(_ locale: Locale) throws {
    guard SFSpeechRecognizer.supportedLocales().contains(locale) else {
        throw SpeechError.languageNotSupported
    }
    guard let recognizer = SFSpeechRecognizer(locale: locale) else {
        throw SpeechError.languageNotAvailable
    }
    guard recognizer.supportsOnDeviceRecognition else {
        throw SpeechError.networkRequired
    }
    self.speechRecognizer = recognizer
}
```

### Changes Required
1. Make `speechRecognizer` a var, create dynamically when language changes
2. Add `selectedLocale` property, stored in settings
3. Check `supportsOnDeviceRecognition` before using
4. Handle errors gracefully in UI
5. Language selector in Settings (Task #24)

### Files to Modify
- `app/SpeakCraft/SpeechRecognizer.swift`

---

## Task #23: Apple Intelligence Prompt Optimization (NEW)

### Purpose
Use Foundation Models framework to clean up/optimize prompts.

### User Requirements
- **Automatic by default** (configurable in settings)
- **Keep original text** in separate field for comparison
- **Allow regeneration** if user doesn't like the result

### UI Design
```
┌─────────────────────────────────────────────┐
│ Original (from speech):                      │
│ ┌─────────────────────────────────────────┐ │
│ │ [readonly] fix the bug in the login...  │ │
│ └─────────────────────────────────────────┘ │
│                                              │
│ Optimized:                        [↻ Redo]  │
│ ┌─────────────────────────────────────────┐ │
│ │ Fix the authentication bug in the       │ │
│ │ login flow that causes...               │ │
│ └─────────────────────────────────────────┘ │
│                                              │
│ [Copy Optimized] [Copy Original]            │
└─────────────────────────────────────────────┘
```

### Implementation (Foundation Models)
```swift
import FoundationModels

class PromptOptimizer {
    func optimize(_ text: String) async throws -> String {
        // Check availability
        guard case .available = SystemLanguageModel.default.availability else {
            throw PromptOptimizerError.unavailable
        }

        let session = LanguageModelSession(instructions: """
            Clean up this transcribed speech for clarity.
            Fix grammar, typos, and awkward sentences.
            Keep the meaning exactly the same - do not add details,
            expand ideas, or make it more specific.
            Just make it grammatically correct and easy to read.
            """)

        let response = try await session.respond(to: text)
        return response.content
    }
}
```

### Error Handling
- `guardrailViolation` - Show message, keep original
- `exceededContextWindowSize` - Break into chunks or keep original
- `unsupportedLanguageOrLocale` - Keep original, warn user

### Files to Create/Modify
- `app/SpeakCraft/PromptOptimizer.swift` (new)
- `app/SpeakCraft/PromptEditorView.swift` - Dual text fields, redo button
- `app/SpeakCraft/Prompt.swift` - Add `originalContent: String?` field

---

## Task #24: User Settings (NEW)

### Settings
| Setting | Type | Default | Description |
|---------|------|---------|-------------|
| Auto-copy to clipboard | Bool | false | Copy optimized text after recording |
| Auto-paste to input | Bool | false | Paste to active app after recording |
| Auto-optimize | Bool | true | Run AI optimization after recording |
| Global hotkey | KeyCombo? | none | Shortcut for recording |
| Speech language | Locale | system | Language for speech recognition |

### Implementation
```swift
// Settings.swift
import SwiftUI

class Settings: ObservableObject {
    @AppStorage("autoCopy") var autoCopy = false
    @AppStorage("autoPaste") var autoPaste = false
    @AppStorage("autoOptimize") var autoOptimize = true
    @AppStorage("speechLanguage") var speechLanguageIdentifier = ""
    // Hotkey stored separately (needs custom handling)
}
```

### UI
- Settings accessible from app menu (Cmd+,)
- Simple form with toggles and pickers
- Language picker populated from `SFSpeechRecognizer.supportedLocales()`

### Files to Create
- `app/SpeakCraft/Settings.swift`
- `app/SpeakCraft/SettingsView.swift`

---

## Task #25: Auto-Paste to Current Input (NEW)

### Purpose
Like macOS native dictation - paste transcribed text directly into the active text field in any app.

### Approach
1. Copy text to clipboard (replaces existing)
2. Simulate Cmd+V keystroke using CGEvent
3. Requires Accessibility permissions

### Implementation
```swift
import Carbon.HIToolbox

func pasteToActiveApp() {
    // Copy to clipboard first (already done)

    // Simulate Cmd+V
    let source = CGEventSource(stateID: .hidSystemState)

    let keyDown = CGEvent(keyboardEventSource: source, virtualKey: CGKeyCode(kVK_ANSI_V), keyDown: true)
    keyDown?.flags = .maskCommand
    keyDown?.post(tap: .cghidEventTap)

    let keyUp = CGEvent(keyboardEventSource: source, virtualKey: CGKeyCode(kVK_ANSI_V), keyDown: false)
    keyUp?.flags = .maskCommand
    keyUp?.post(tap: .cghidEventTap)
}
```

### Workflow Integration
When recording stops (and auto-paste enabled):
1. Transcribe speech
2. Optimize text (if auto-optimize enabled)
3. Copy to clipboard
4. Simulate Cmd+V

### Permissions
- Accessibility permission required for CGEvent
- Show permission request on first use
- Graceful degradation if denied (just copy, don't paste)

### Files to Modify
- `app/SpeakCraft/SpeechRecognizer.swift` - Add paste action
- `app/SpeakCraft/ContentView.swift` - Handle permission flow

---

## Files to Create/Update

### Update existing:
- `tasks/21-multi-language-support.md` - Full rewrite with research

### Create new:
- `tasks/23-prompt-optimization.md`
- `tasks/24-user-settings.md`
- `tasks/25-auto-paste.md`

---

## Execution Order

1. Task #24 (Settings) - Foundation for other features
2. Task #21 (Multi-language) - Uses settings for language preference
3. Task #23 (Prompt optimization) - Uses settings for auto-optimize
4. Task #25 (Auto-paste) - Uses settings for auto-paste toggle

---

## Verification

After implementation:
- [ ] Polish speech recognition works
- [ ] Settings persist across app restart
- [ ] AI optimization runs automatically
- [ ] Original vs optimized text shown side by side
- [ ] Regenerate button produces different result
- [ ] Auto-paste works in external apps
- [ ] All features can be toggled in settings
