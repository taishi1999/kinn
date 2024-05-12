//
//  calendarApp.swift
//  calendar
//
//  Created by 唐崎大志 on 2024/05/12.
//

import SwiftUI

@main
struct calendarApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
