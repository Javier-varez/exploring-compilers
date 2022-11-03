//
//  ContentView.swift
//  exploring-compilers
//
//  Created by Javier on 30.10.22.
//

import SwiftUI

struct ContentView: View {
    @StateObject public var settingsStore: SettingsStore = SettingsStore()

    var body: some View {
        TabView {
            BuildView(store: settingsStore).tabItem{
                Label("Build", systemImage: "star")
            }
            
            SettingsView(store: settingsStore).tabItem {
                Label("Settings", systemImage: "gear")
            }
                
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
