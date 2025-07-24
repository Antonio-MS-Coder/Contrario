//
//  Marea_BajaApp.swift
//  Marea Baja
//
//  Created by Tono Murrieta  on 23/07/25.
//

import SwiftUI

@main
struct Marea_BajaApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
