//
//  SettingsView.swift
//  exploring-compilers
//
//  Created by Javier on 02.11.22.
//

import SwiftUI

struct Language : Hashable, Identifiable {
    var name: String
    var code: String
    var id: String { code }
}

struct Compiler :Hashable, Identifiable{
    var name: String
    var code: String
    var id: String { code }
}

struct SettingsView: View {
    @StateObject public var store: SettingsStore
    
    @State public var compilers = [Compiler]()
    @State public var languages = [Language]()

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Language settings")) {
                    Picker("Language", selection: $store.language) {
                        ForEach(self.languages) { language in
                            Text(language.name).tag(language.code)
                        }
                    }
                    .onChange(of: store.language) { tag in
                        loadCompilersForLanguage(code: store.language)
                    }
                    .onAppear {
                        loadLanguages()
                    }
                }
                Section(header: Text("Compiler settings")) {
                    Picker("Compiler", selection: $store.compiler) {
                        ForEach(self.compilers) { compiler in
                            Text(compiler.name).tag(compiler.code)
                        }
                    }
                    .onAppear {
                        loadCompilersForLanguage(code: store.language)
                    }
                    TextField("Arguments", text: $store.userArguments)
                        .autocapitalization(.none)
                        .autocorrectionDisabled(true)
                }
            }.navigationTitle("Settings")
        }
    }
    
    func parseLanguages(data: Data) -> [Language] {
        var languages = [Language]()
        if let str = String(data: data, encoding: .utf8) {
            let lines = str.split(separator: "\n")
            for line in lines {
                let parts = line.split(separator: "|")
                let code = parts[0]
                    .trimmingCharacters(in: CharacterSet(charactersIn: " \t"))
                let name = parts[1]
                    .trimmingCharacters(in: CharacterSet(charactersIn: " \t"))
                if name == "Name" {
                    continue
                }
                
                languages.append(Language(name: String(name), code: String(code)))
            }
        }
        return languages
    }
    
    func parseCompilers(data: Data) -> [Compiler] {
        var compilers = [Compiler]()
        if let str = String(data: data, encoding: .utf8) {
            let lines = str.split(separator: "\n")
            for line in lines {
                let parts = line.split(separator: "|")
                let code = parts[0]
                    .trimmingCharacters(in: CharacterSet(charactersIn: " \t"))
                let name = parts[1]
                    .trimmingCharacters(in: CharacterSet(charactersIn: " \t"))
                if name == "Name" {
                    continue
                }
                
                compilers.append(Compiler(name: String(name), code: String(code)))
            }
        }
        return compilers
    }
    
    public func loadLanguages() {
        let backend = "https://godbolt.org"
        let languagesUrl = URL(string: "\(backend)/api/languages")!
        
        var request = URLRequest(url: languagesUrl)
        request.httpMethod = "GET"
        
        let task = URLSession.shared.dataTask(with: request) {
                (data, response, error) in
                guard let data = data else { return }
            self.languages = parseLanguages(data: data)
            print("updated languages")
       }
       task.resume()
    }
    
    public func loadCompilersForLanguage(code: String) {
        let backend = "https://godbolt.org"
        let compilersUrl = URL(string: "\(backend)/api/compilers/\(code)")!
        
        var request = URLRequest(url: compilersUrl)
        request.httpMethod = "GET"
        
        let task = URLSession.shared.dataTask(with: request) {
                (data, response, error) in
                guard let data = data else { return }
            self.compilers = parseCompilers(data: data)
            print("updated compilers")
       }
       task.resume()
    }
}


struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView(store: SettingsStore())
    }
}
