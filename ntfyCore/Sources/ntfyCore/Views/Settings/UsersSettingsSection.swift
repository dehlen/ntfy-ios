//
//  UsersSettingsSection.swift
//  ntfy
//
//  Created by von Knobelsdorff, David on 14.01.26.
//

import OSLog
import SwiftUI

struct UsersSettingsSection: View {
    @Environment(AppRouter.self) private var appRouter
    @Environment(LiveUserStore.self) private var userStore
    
    var body: some View {
        Section {
            ForEach(userStore.users) { user in
                NavigationLink(value: AppRoute.editUser(user)) {
                    UserRow(user: user)
                }
            }
            .onDelete(perform: deleteUser)
            
            Button("Add user", systemImage: "plus") {
                appRouter.present(.addUser)
            }
        } header: {
            Text("Users")
        } footer: {
            Text("To access read-protected topics, you may add or edit users here. All topics for a given server will use the same user.")
        }
    }
    
    private func deleteUser(at offsets: IndexSet) {
        let users = offsets.map { userStore.users[$0] }
        for user in users {
            do {
                try userStore.deleteUser(userID: user.id)
            } catch {
                NtfyLogger.userStore.error("Failed to delete user \(user.username, privacy: .public): \(error.localizedDescription, privacy: .public)")
            }
        }
    }
}

#Preview {
    UsersSettingsSection()
}
