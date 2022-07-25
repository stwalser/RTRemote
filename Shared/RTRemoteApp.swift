//
//  RTRemoteApp.swift
//  Shared
//
//  Created by Stefan Walser on 07.04.21.
//

import SwiftUI

@main
struct RTRemoteApp: App {
    var body: some Scene {
        // Hiding Titlebar for only macOS
        #if os(iOS)
        WindowGroup {
            ContentView()
        }
        #else
        WindowGroup {
            ContentView()
        }.windowStyle(HiddenTitleBarWindowStyle())
        #endif
    }
}

// Disable Focus Ring on macOS
#if !os(iOS)
extension NSTextField {
    open override var focusRingType: NSFocusRingType {
        get{.none}
        set{}
    }
}
#endif
