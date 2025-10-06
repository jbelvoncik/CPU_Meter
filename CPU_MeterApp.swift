//
//  CPU_MeterApp.swift
//  CPU_Meter
//
//  Floating overlay helper showing CPU/GPU/ANE load.
//  Remembers window position across launches.
//  (Hotkey/opacity feature removed.)
//
//  © 2025 Jozef Belvončik MIT License
//

import SwiftUI
import AppKit

final class OverlayWindow: NSWindow {
    private static let posKey = "windowPosition"

    init(view: NSView) {
        // Default window size & restored position
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

    // Save position on close
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
            let v = screen.visibleFrame
            return NSRect(x: v.maxX - 220, y: v.maxY - 180, width: 200, height: 140)
        }
        return NSRect(x: 100, y: 100, width: 200, height: 140)
    }
}

@main
struct CPU_MeterApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    var body: some Scene { Settings { EmptyView() } }
}

final class AppDelegate: NSObject, NSApplicationDelegate {
    private var window: OverlayWindow?
    func applicationDidFinishLaunching(_ note: Notification) {
        let host = NSHostingView(rootView: OverlayView())
        window = OverlayWindow(view: host)
        window?.orderFrontRegardless()
        NSApp.setActivationPolicy(.regular)
        let mainMenu = NSMenu()
        let appMenuItem = NSMenuItem()
        mainMenu.addItem(appMenuItem)
        let appMenu = NSMenu()
        appMenu.addItem(withTitle: \"Quit CPU Meter\", action: #selector(NSApplication.terminate(_:)), keyEquivalent: \"q\")
        appMenuItem.submenu = appMenu
        NSApp.mainMenu = mainMenu
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            NSApp.setActivationPolicy(.accessory)
        }
    }
    func applicationWillTerminate(_ notification: Notification) { window?.close() }
}
