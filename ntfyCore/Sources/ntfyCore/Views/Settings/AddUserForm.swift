//
//  AddUserForm.swift
//  ntfy
//
//  Created by von Knobelsdorff, David on 13.01.26.
//

import OSLog
import SwiftUI

struct AddUserForm: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.dependencies) private var dependencies: DependencyContainer

    private var userStore: any UserStore {
        dependencies.userStore
    }
    
    @State private var serviceURL: String = ""
    @State private var username: String = ""
    @State private var password: String = ""
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Service URL, eq. https://ntfy.home.io", text: $serviceURL)
                        .textContentType(.URL)
                        .textInputAutocapitalization(.never)
                        .keyboardType(.URL)
                        .autocorrectionDisabled()
                    TextField("Username", text: $username)
                        .textContentType(.username)
                        .textInputAutocapitalization(.never)
                        .keyboardType(.default)
                        .autocorrectionDisabled()
                    SecureField("Password", text: $password)
                        .textContentType(.password)
                } footer: {
                    Text("You can add a user here. All topics for the given server will use this user.")
                }
            }
            .navigationTitle("Add user")
            .toolbar { toolbar }
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
        serviceURL.isEmpty || username.isEmpty || password.isEmpty
    }
    
    private func save() {
        do {
            let user = User(serviceURL: serviceURL, username: username)
            try userStore.saveUser(user: user, password: password)
            dismiss()
        } catch {
            NtfyLogger.userStore.error("Failed to save user \(username, privacy: .public): \(error.localizedDescription, privacy: .public)")
        }
    }
}

#Preview {
    AddUserForm()
}
