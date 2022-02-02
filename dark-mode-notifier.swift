#!/usr/bin/env swift
// Compile with:
// swiftc dark-mode-notifier.swift -o dark-mode-notifier
// modified from https://github.com/mnewt/dotemacs/blob/6d3b033578d0037c7202cfa92d6a32fbb843c394/bin/dark-mode-notifier.swift

import Cocoa

@discardableResult
func shell(_ args: String...) -> Int32 {
    let task = Process()
    task.launchPath = "/usr/bin/env"
    task.arguments = args
    task.launch()
    task.waitUntilExit()
    return task.terminationStatus
}

func updateTheme() {
    let env = ProcessInfo.processInfo.environment as [String: String]
    let home = env["HOME"]!
    shell("/usr/bin/killall", "-USR1", "nvim")
    shell("/opt/homebrew/bin/tmux", "source-file", "\(home)/.tmux.conf")
}

updateTheme()

DistributedNotificationCenter.default.addObserver(
    forName: Notification.Name("AppleInterfaceThemeChangedNotification"),
    object: nil,
    queue: nil) { (notification) in
        updateTheme()
}

// Enter cocoa run loop and start listening for notifyd events
NSApplication.shared.run()
