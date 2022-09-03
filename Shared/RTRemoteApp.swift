//
//  RTRemoteApp.swift
//  Shared
//
//  Created by Stefan Walser on 07.04.21.
//

import SwiftUI
import CoreData

@main
struct RTRemoteApp: App {
    
    @Environment(\.scenePhase) var scenePhase
    
    let persistenceController = PersistenceController.shared
    
    var body: some Scene {
        // Hiding Titlebar for only macOS
#if os(iOS)
        WindowGroup {
            ContentView().environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
        .onChange(of: scenePhase) { _ in
            persistenceController.save()
        }
#else
        WindowGroup {
            ContentView().environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
        .windowStyle(HiddenTitleBarWindowStyle())
        .onChange(of: scenePhase) { _ in
            persistenceController.save()
        }
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
