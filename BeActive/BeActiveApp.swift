//
//  BeActiveApp.swift
//  BeActive
//
//  Created by Carmen Lucas on 23/7/23.
//

import SwiftUI

@main
struct BeActiveApp: App {
    @StateObject var manager = HealthManager()
    var body: some Scene {
        WindowGroup {
            BeActiveTabView().environmentObject(manager)
            
        }
    }
}
