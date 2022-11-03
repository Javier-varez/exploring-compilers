//
//  BuildView.swift
//  exploring-compilers
//
//  Created by Javier on 02.11.22.
//

import SwiftUI

let initialCode: String = """
#include <cstdio>

int main() {
  printf("Hello World!\\n");
  return 0;
}
"""

struct BuildView: View {
    @StateObject public var store: SettingsStore
    @State public var result: String = ""
    @State public var code: String = initialCode
    @FocusState public var focused: Bool
    
    public var compiler_explorer = CompilerExplorer()

    var body: some View {
        NavigationView {
            VStack {
                TextEditor(text: $code)
                    .font(.body.monospaced())
                    .keyboardType(.asciiCapable)
                    .focused($focused)
                    .autocorrectionDisabled(true)
                    .autocapitalization(.none)
                ScrollView(.vertical.union(.horizontal)) {
                    Text(result)
                        .font(.body.monospaced())
                        .lineLimit(nil)
                }
            }
            .padding(.all)
            .navigationTitle("Exploring Compilers")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Build") {
                        compiler_explorer.compile(message: code, settings: store) {
                            (asm: String) in
                            result = asm
                            focused = false
                        }
                    }
                }
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Reset") {
                        code = initialCode
                        result = ""
                    }
                }
            }
        }
    }
}

struct BuildView_Previews: PreviewProvider {
    static var previews: some View {
        BuildView(store: SettingsStore())
    }
}
