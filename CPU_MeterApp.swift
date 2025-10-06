//
//  CPU_MeterApp.swift
//  CPU_Meter
//
//  Minimal overlay showing CPU/GPU/ANE usage with menu bar About/Quit only.
//  © 2025 Jozef Belvončik — MIT License
//

import SwiftUI
import AppKit

final class OverlayWindow: NSWindow {
    init(view: NSView) {
        super.init(
            contentRect: NSRect(x: 100, y: 100, width: 220, height: 120),
            styleMask: [.borderless],
            backing: .buffered,
            defer: false
        )
        isOpaque = false
        backgroundColor = .clear
        level = .floating
        isMovableByWindowBackground = true
        collectionBehavior = [.canJoinAllSpaces]
        contentView = view
    }
    override var canBecomeKey: Bool { false }
}

@main
struct CPU_MeterApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    var body: some Scene { Settings { EmptyView() } }
}

final class AppDelegate: NSObject, NSApplicationDelegate {
    private var window: OverlayWindow?

    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.regular)

        // ---- MENU ----
        let mainMenu = NSMenu()

        let appMenuItem = NSMenuItem()
        mainMenu.addItem(appMenuItem)

        let appMenu = NSMenu(title: "CPU Meter")
        appMenu.addItem(withTitle: "About CPU Meter", action: #selector(showAbout), keyEquivalent: "")
        appMenu.addItem(NSMenuItem.separator())
        appMenu.addItem(withTitle: "Quit CPU Meter", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q")

        appMenuItem.submenu = appMenu
        NSApp.mainMenu = mainMenu

        // ---- WINDOW ----
        let host = NSHostingView(rootView: OverlayView())
        window = OverlayWindow(view: host)
        window?.orderFrontRegardless()
        NSApp.activate(ignoringOtherApps: true)
    }

    @objc func showAbout() {
        let alert = NSAlert()
        alert.messageText = "CPU Meter 1.0"
        alert.informativeText = "Displays live CPU, GPU and APE usage overlay.\n© 2025 Jozef Belvončik"
        alert.addButton(withTitle: "OK")
        alert.runModal()
    }
}
