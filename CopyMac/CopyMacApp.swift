import SwiftUI

@main
struct CopyMacApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        Settings {
            EmptyView()
        }
    }
}

// Define a type to store clipboard items
enum ClipboardItem {
    case text(String)
    case image(NSImage)
    
    var title: String {
        switch self {
        case .text(let string):
            return string
        case .image:
            return "Image"
        }
    }
}

class AppDelegate: NSObject, NSApplicationDelegate {
    var statusBarItem: NSStatusItem!
    var clipboardHistory: [ClipboardItem] = []
    let maxHistoryItems = 10
    var timer: Timer?
    var lastClipboardContent: String?
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        // Create the status bar item
        statusBarItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        
        if let button = statusBarItem.button {
            button.image = NSImage(systemSymbolName: "doc.on.clipboard", accessibilityDescription: "Clipboard History")
        }
        
        // Set up the menu
        setupMenu()
        
        // Start monitoring clipboard
        startClipboardMonitoring()
    }
    
    func startClipboardMonitoring() {
        // Create a timer that checks the clipboard periodically
        timer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { [weak self] _ in
            self?.checkClipboard()
        }
    }
    
    func checkClipboard() {
        let pasteboard = NSPasteboard.general
        
        // Check for image first
        if let image = pasteboard.readObjects(forClasses: [NSImage.self], options: nil)?.first as? NSImage {
            // Only add if it's different from the last item
            if lastClipboardContent != "image" {
                lastClipboardContent = "image"
                let clipboardItem = ClipboardItem.image(image)
                clipboardHistory.insert(clipboardItem, at: 0)
                
                // Keep only the last 10 items
                if clipboardHistory.count > maxHistoryItems {
                    clipboardHistory.removeLast()
                }
                
                // Update the menu
                setupMenu()
            }
        }
        // Then check for text
        else if let string = pasteboard.string(forType: .string) {
            // Only add if it's different from the last item
            if string != lastClipboardContent {
                lastClipboardContent = string
                let clipboardItem = ClipboardItem.text(string)
                clipboardHistory.insert(clipboardItem, at: 0)
                
                // Keep only the last 10 items
                if clipboardHistory.count > maxHistoryItems {
                    clipboardHistory.removeLast()
                }
                
                // Update the menu
                setupMenu()
            }
        }
    }
    
    func setupMenu() {
        let menu = NSMenu()
        
        // Add clipboard history items
        for (index, item) in clipboardHistory.enumerated() {
            let menuItem = NSMenuItem(
                title: item.title,
                action: #selector(copyItem(_:)),
                keyEquivalent: ""
            )
            
            // If it's an image, add a thumbnail
            if case .image(let image) = item {
                let thumbnailSize = NSSize(width: 20, height: 20)
                let thumbnail = NSImage(size: thumbnailSize)
                thumbnail.lockFocus()
                image.draw(in: NSRect(origin: .zero, size: thumbnailSize),
                          from: .zero,
                          operation: .copy,
                          fraction: 1.0)
                thumbnail.unlockFocus()
                menuItem.image = thumbnail
            }
            
            menuItem.tag = index
            menu.addItem(menuItem)
        }
        
        // Add separator and quit option
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(
            title: "Quit",
            action: #selector(NSApplication.terminate(_:)),
            keyEquivalent: "q"
        ))
        
        statusBarItem.menu = menu
    }
    
    @objc func copyItem(_ sender: NSMenuItem) {
        let index = sender.tag
        guard index < clipboardHistory.count else { return }
        
        let item = clipboardHistory[index]
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        
        switch item {
        case .text(let string):
            pasteboard.setString(string, forType: .string)
        case .image(let image):
            pasteboard.writeObjects([image])
        }
    }
} 