# Plan: Bug Fixes and UI Redesign

## Issues to Fix

1. **Recording crashes app** - Critical, app unusable
2. **Custom section removal crash** - Index-based binding causes "index out of range"
3. **Window too small** - Can't see + button in sidebar
4. **Polish language doesn't work** - SpeechRecognizer hardcoded to `en-US`
5. **UI redesign** - Single text box instead of Task/Context/Rules sections

---

## Task Files to Create

### Task 18: Fix Recording Crash
**File:** `tasks/18-fix-recording-crash.md`

Investigate and fix crash when clicking record button:
- Check AVAudioSession/AVAudioEngine lifecycle
- Verify microphone authorization handling
- Look for race conditions in start/stop
- Test error states

### Task 19: Fix Custom Section Removal Crash
**File:** `tasks/19-fix-custom-section-binding.md`

Fix index out of range crash:
- Current code uses index-based binding in ForEach (fragile)
- Replace with `ForEach($prompt.customSections)` using `Bindable`
- Or iterate by ID and use computed bindings safely

### Task 20: Fix Window Size
**File:** `tasks/20-fix-window-size.md`

Make window usable on launch:
- Increase `.defaultSize()` (currently 900x600)
- Add `.windowResizability(.contentMinSize)` with minimum
- Test sidebar visibility

### Task 21: Multi-Language Support
**File:** `tasks/21-multi-language-support.md`

Support all languages user has in macOS:
- Remove hardcoded `Locale(identifier: "en-US")`
- Use `SFSpeechRecognizer()` without locale (uses system default)
- Or use `Locale.current` which reflects user's preferred language
- Polish is supported by Apple's on-device recognition
- Match behavior of native macOS dictation

### Task 22: Simplify UI - Single Content Field
**File:** `tasks/22-single-input-redesign.md`

Replace sections with single input:
- **Model change:** Remove task/context/rules/examples/customSections, add single `content: String`
- **UI change:** One TextEditor, one record button
- **Remove:** SectionView, CustomSectionView, section-level recording
- **Keep:** Sidebar, search, copy to clipboard, global hotkey
- **Defer:** AI optimization/sectioning for later
- **Note:** Existing prompts will be lost (acceptable per user)

---

## Implementation Order

1. **22-single-input-redesign** - Do this first since it removes custom sections entirely (fixes task 19 automatically)
2. **18-fix-recording-crash** - Critical functionality
3. **21-multi-language-support** - Quick change after recording works
4. **20-fix-window-size** - Quick fix

**Note:** Task 19 becomes unnecessary after task 22 removes custom sections.

---

## Files to Modify

| File | Changes |
|------|---------|
| `Prompt.swift` | Remove task/context/rules/examples/customSections, add content |
| `PromptEditorView.swift` | Replace all section views with single TextEditor |
| `SectionView.swift` | Delete entirely |
| `SpeechRecognizer.swift` | Fix crash, remove hardcoded locale |
| `SpeakCraftApp.swift` | Increase window size |
| `ContentView.swift` | Simplify toolbar, remove section picker |
| `TranscriptionView.swift` | Remove section picker |
| `SidebarView.swift` | Update search to use content field |

---

## Verification

After implementation:
- [ ] App launches at proper size
- [ ] Click record - no crash
- [ ] Speak in English - transcribes correctly
- [ ] Speak in Polish - transcribes correctly
- [ ] Create/edit/delete prompts works
- [ ] Copy to clipboard works
- [ ] Search works
- [ ] Global hotkey works
