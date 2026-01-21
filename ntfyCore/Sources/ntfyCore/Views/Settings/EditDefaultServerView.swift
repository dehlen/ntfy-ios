//
//  EditDefaultServerView.swift
//  ntfy
//
//  Created by von Knobelsdorff, David on 13.01.26.
//

import SwiftUI

struct EditDefaultServerView: View {
    @AppStorage("default_server") private var defaultServer: String = "https://ntfy.sh"
    @State private var newDefaultServer: String = ""
    
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField(defaultServer, text: $newDefaultServer)
                        .textContentType(.URL)
                        .textInputAutocapitalization(.never)
                        .keyboardType(.URL)
                        .autocorrectionDisabled()
                } footer: {
                    Text("When subscribing to new topics, this server will be used as a default. Note that if you pick your own ntfy server, you must configure upstream-base-url to receive instant push notifications.")
                }
            }
            .toolbar {
                toolbar
            }
            .navigationTitle("Default server")
        }
    }
    
    @ToolbarContentBuilder private var toolbar: some ToolbarContent {
        ToolbarItem(placement: .cancellationAction) {
            Button("Cancel", role: .cancel) {
                dismiss()
            }
        }
        
        ToolbarItem(placement: .confirmationAction) {
            Button("Save", role: .confirm) {
                save()
            }
            .disabled(isSaveDisabled)
        }
    }
    
    private var isSaveDisabled: Bool {
        newDefaultServer.isEmpty || defaultServer == newDefaultServer
    }
    
    private func save() {
        defaultServer = newDefaultServer
        dismiss()
    }
}

#Preview {
    EditDefaultServerView()
}
