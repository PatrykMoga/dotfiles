#!/usr/bin/env swift
import Cocoa
import Carbon

var escPressed = false
var enterPressed = false

class KeyboardBlocker: NSObject, NSApplicationDelegate {
    var window: NSWindow!
    var countdownLabel: NSTextField!
    var secondsRemaining = 30
    var timer: Timer?
    var eventTap: CFMachPort?

    func applicationDidFinishLaunching(_ notification: Notification) {
        setupEventTap()
        setupWindow()
        startCountdown()
    }

    func setupEventTap() {
        let eventMask = (1 << CGEventType.keyDown.rawValue) |
                        (1 << CGEventType.keyUp.rawValue) |
                        (1 << CGEventType.flagsChanged.rawValue)

        eventTap = CGEvent.tapCreate(
            tap: .cgSessionEventTap,
            place: .headInsertEventTap,
            options: .defaultTap,
            eventsOfInterest: CGEventMask(eventMask),
            callback: { _, type, event, _ in
                let keycode = event.getIntegerValueField(.keyboardEventKeycode)
                let isKeyDown = type == .keyDown

                // Track ESC (53) and Enter (36) keys
                if keycode == 53 { escPressed = isKeyDown }
                if keycode == 36 { enterPressed = isKeyDown }

                // Exit only when both ESC and Enter are pressed together
                if escPressed && enterPressed {
                    NSApplication.shared.terminate(nil)
                }
                return nil // Swallow all keyboard events
            },
            userInfo: nil
        )

        guard let tap = eventTap else {
            print("Error: Could not create event tap.")
            print("Grant Accessibility access: System Settings → Privacy & Security → Accessibility")
            exit(1)
        }

        let runLoopSource = CFMachPortCreateRunLoopSource(kCFAllocatorDefault, tap, 0)
        CFRunLoopAddSource(CFRunLoopGetCurrent(), runLoopSource, .commonModes)
        CGEvent.tapEnable(tap: tap, enable: true)
    }

    func setupWindow() {
        let screen = NSScreen.main!
        window = NSWindow(
            contentRect: screen.frame,
            styleMask: [.borderless],
            backing: .buffered,
            defer: false
        )
        window.level = .screenSaver
        window.backgroundColor = .black
        window.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
        window.isOpaque = true

        countdownLabel = NSTextField(labelWithString: "")
        countdownLabel.font = NSFont.monospacedSystemFont(ofSize: 72, weight: .light)
        countdownLabel.textColor = NSColor(white: 0.3, alpha: 1.0)
        countdownLabel.alignment = .center
        countdownLabel.frame = NSRect(
            x: 0,
            y: screen.frame.height / 2 - 50,
            width: screen.frame.width,
            height: 100
        )
        window.contentView?.addSubview(countdownLabel)

        let hint = NSTextField(labelWithString: "Press ESC + Enter to exit early")
        hint.font = NSFont.systemFont(ofSize: 14)
        hint.textColor = NSColor(white: 0.25, alpha: 1.0)
        hint.alignment = .center
        hint.frame = NSRect(
            x: 0,
            y: screen.frame.height / 2 - 100,
            width: screen.frame.width,
            height: 30
        )
        window.contentView?.addSubview(hint)

        window.makeKeyAndOrderFront(nil)
        NSCursor.hide()
    }

    func startCountdown() {
        updateLabel()
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            self.secondsRemaining -= 1
            self.updateLabel()
            if self.secondsRemaining <= 0 {
                NSApplication.shared.terminate(nil)
            }
        }
    }

    func updateLabel() {
        countdownLabel.stringValue = "\(secondsRemaining)"
    }

    func applicationWillTerminate(_ notification: Notification) {
        NSCursor.unhide()
        if let tap = eventTap {
            CGEvent.tapEnable(tap: tap, enable: false)
        }
    }
}

let app = NSApplication.shared
let delegate = KeyboardBlocker()
app.delegate = delegate
app.setActivationPolicy(.accessory)
app.run()
