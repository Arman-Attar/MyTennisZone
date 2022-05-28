//
//  TennisTrackerApp.swift
//  TennisTracker
//
//  Created by Arman Zadeh-Attar on 2022-04-28.
//

import SwiftUI

@main
struct TennisTrackerApp: App {
    static var isAlreadyLaunched = false
    var body: some Scene {
        WindowGroup {
            signIn()
        }
    }
}

