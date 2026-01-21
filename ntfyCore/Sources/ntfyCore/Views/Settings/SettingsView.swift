//
//  SettingsView.swift
//  ntfy
//
//  Created by von Knobelsdorff, David on 12.01.26.
//

import SwiftUI

struct SettingsView: View {
    @Environment(AppRouter.self) private var appRouter
    
    var body: some View {
        @Bindable var appRouter = appRouter

        NavigationStack(path: $appRouter.settingsRouter.path) {
            Form {
                GeneralSettingsSection()
                UsersSettingsSection()
                AboutSettingsSection()
            }
            .navigationTitle("Settings")
            .navigationDestination(for: AppRoute.self, destination: { route in
                route.destination
            })
        }
    }
}

#Preview {
    SettingsView()
}
