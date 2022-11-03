//
//  SettingsStore.swift
//  exploring-compilers
//
//  Created by Javier on 02.11.22.
//

import Foundation

class SettingsStore : ObservableObject {
    @Published var compiler: String = "clang1500"
    @Published var language: String = "c++"
    @Published var userArguments: String = "-Os"
}
