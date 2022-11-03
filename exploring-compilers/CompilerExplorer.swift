//
//  CompilerExplorer.swift
//  exploring-compilers
//
//  Created by Javier on 31.10.22.
//

import Foundation

struct CompilationOptions: Codable {
    var userArguments: String
}

struct CompilationRequest: Codable {
    var source: String
    var options: CompilationOptions
    var lang: String?
}

struct TextObject: Decodable {
    var text: String
}

struct CompilationAnswer: Decodable {
    var asm: [TextObject]
    var code: UInt
}

class CompilerExplorer {
    private let backend = "https://godbolt.org"
    
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()
    
    init() {
        encoder.outputFormatting = .prettyPrinted
    }
    
    private func encodeRequest(source: String, compilerArgs: String?) -> Data{
        let request = CompilationRequest(source: source, options: CompilationOptions(userArguments: compilerArgs ?? ""))
        let encoded_message = try! encoder.encode(request)
        return encoded_message
    }
    
    private func decodeAnswer(jsonData: Data) -> String {
        let decoded = try! decoder.decode(CompilationAnswer.self, from: jsonData)
        var concat = ""
        for res in decoded.asm {
            concat.append(res.text)
            concat.append("\n")
        }
        return concat
    }
    
    private func compilationEndpoint(compiler: String?) -> URL {
        return URL(string: "\(backend)/api/compiler/\(compiler ?? "clang1500")/compile")!
    }

    public func compile(message: String, settings: SettingsStore, callable: @escaping (String) -> Void) {
        var request = URLRequest(url: compilationEndpoint(compiler: settings.compiler))
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.httpBody = encodeRequest(source: message, compilerArgs: settings.userArguments)
        
        let task = URLSession.shared.dataTask(with: request) {
            (data, response, error) in
            guard let data = data else { return }
            let asm = self.decodeAnswer(jsonData: data)
            callable(asm)
        }
        task.resume()
    }
}
