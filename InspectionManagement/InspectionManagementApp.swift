//
//  InspectionManagementApp.swift
//  InspectionManagement
//
//  Created by Sukh Vilas on 22/08/24.
//

import SwiftUI

@main
struct InspectionManagementApp: App {
    // Core Data persistence controller
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            // Initial view of the app
            LoginView()
                // Inject Core Data managed object context into the environment
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}


