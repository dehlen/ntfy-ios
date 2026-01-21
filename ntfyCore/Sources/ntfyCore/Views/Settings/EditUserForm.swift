//
//  EditUserForm.swift
//  ntfy
//
//  Created by von Knobelsdorff, David on 13.01.26.
//

import OSLog
import SwiftUI

struct EditUserForm: View {
    let user: User

    @Environment(\.dismiss) private var dismiss
    @Environment(\.dependencies) private var dependencies: DependencyContainer

    private var userStore: any UserStore {
        dependencies.userStore
    }
    
    @State private var username: String = ""
    @State private var password: String = ""
    
    var body: some View {
        Form {
            Section {
                TextField("Username", text: $username)
                    .textContentType(.username)
                    .textInputAutocapitalization(.never)
                    .keyboardType(.default)
                    .autocorrectionDisabled()
                SecureField("Password", text: $password)
                    .textContentType(.password)
            } footer: {
                Text("Edit the username or password for \(user.serviceURL) here. This user is used for all topics of this server. Leave the password blank to leave it unchanged.")
            }
            Section {
                Button("Delete", role: .destructive) {
                    delete()
                }
            }
        }
        .navigationTitle("Edit user")
        .onAppear {
            self.username = user.username
        }
        .toolbar { toolbar }
    }
    
    @ToolbarContentBuilder private var toolbar: some ToolbarContent {
        ToolbarItem(placement: .confirmationAction) {
            Button("Save", role: .confirm) {
                save()
            }
            .disabled(isSaveDisabled)
        }
    }
    
    private var isSaveDisabled: Bool {
        username.isEmpty || (user.username == username && password.isEmpty)
    }
    
    private func save() {
        do {
            try userStore.updateUser(
                user: user,
                newUsername: username,
                newPassword: password
            )
            dismiss()
        } catch {
            NtfyLogger.userStore.error("Failed to update user \(user.username, privacy: .public): \(error.localizedDescription, privacy: .public)")
        }
    }
    
    private func delete() {
        do {
            try userStore.deleteUser(userID: user.id)
            dismiss()
        } catch {
            NtfyLogger.userStore.error("Failed to delete user \(user.username, privacy: .public): \(error.localizedDescription, privacy: .public)")
        }
    }
}

#Preview {
    EditUserForm(user: .preview)
}
