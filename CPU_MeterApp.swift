//
//  CPU_MeterApp.swift
//  CPU_Meter
//
//  Floating overlay helper with remembered position
//  and toggleable opacity + click-through (Cmd+Shift+O).
//
//  © 2025 Jozef Belvončik MIT License
//

import SwiftUI
import AppKit

final class OverlayWindow: NSWindow {
    private static let posKey = "windowPosition"

    private var transparent = false

    init(view: NSView) {
        let frame = Self.restoreFrame()
        super.init(contentRect: frame,
                   styleMask: [.borderless],
                   backing: .buffered,
                   defer: false)
        isOpaque = false
        backgroundColor = .clear
        level = .floating
        collectionBehavior = [.canJoinAllSpaces]
        isMovableByWindowBackground = true
        ignoresMouseEvents = false
        contentView = view
    }

    override var canBecomeKey: Bool { false }

    override func close() {
        Self.saveFrame(frame)
        super.close()
    }

    // MARK: - Position persistence
    private static func saveFrame(_ rect: NSRect) {
        let dict: [String: Double] = ["x": rect.origin.x, "y": rect.origin.y]
        UserDefaults.standard.set(dict, forKey: posKey)
    }

    private static func restoreFrame() -> NSRect {
        if let dict = UserDefaults.standard.dictionary(forKey: posKey) as? [String: Double],
           let x = dict["x"], let y = dict["y"] {
            return NSRect(x: x, y: y, width: 200, height: 140)
        }
        if let screen = NSScreen.main {
            let visible = screen.visibleFrame
            return NSRect(x: visible.maxX - 220, y: visible.maxY - 180, width: 200, height: 140)
        }
        return NSRect(x: 100, y: 100, width: 200, height: 140)
    }

    // MARK: - Toggle opacity and click-through
    func toggleTransparency() {
        transparent.toggle()
        alphaValue = transparent ? 0.4 : 1.0
        ignoresMouseEvents = transparent
    }
}

@main
struct CPU_MeterApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    var body: some Scene { Settings { EmptyView() } }
}

final class AppDelegate: NSObject, NSApplicationDelegate {
    private var window: OverlayWindow?
    private var monitor: Any?

    func applicationDidFinishLaunching(_ note: Notification) {
        let host = NSHostingView(rootView: OverlayView())
        window = OverlayWindow(view: host)
        window?.orderFrontRegardless()
        NSApp.setActivationPolicy(.accessory)

        // Register hotkey Cmd+Shift+O
        monitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown) { [weak self] event in
            if event.modifierFlags.contains([.command, .shift]) && event.charactersIgnoringModifiers == "o" {
                self?.window?.toggleTransparency()
                return nil
            }
            return event
        }
    }

    func applicationWillTerminate(_ notification: Notification) {
        if let m = monitor { NSEvent.removeMonitor(m) }
        window?.close()
    }
}
