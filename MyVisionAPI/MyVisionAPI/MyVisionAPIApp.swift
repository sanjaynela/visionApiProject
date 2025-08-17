//
//  MyVisionAPIApp.swift
//  MyVisionAPI
//
//  Created by Sanjay Nelagadde on 8/15/25.
//

import SwiftUI

@main
struct MyVisionAPIApp: App {
    @AppStorage("hasSeenWelcome") private var hasSeenWelcome = false
    
    var body: some Scene {
        WindowGroup {
            if hasSeenWelcome {
                ContentView()
            } else {
                WelcomeView()
            }
        }
    }
}
