//
//  GeneralSettingsSection.swift
//  ntfy
//
//  Created by von Knobelsdorff, David on 14.01.26.
//

import SwiftUI

struct GeneralSettingsSection: View {
    @Environment(\.dependencies) private var dependencies: DependencyContainer

    private var appRouter: AppRouter {
        dependencies.appRouter
    }

    @AppStorage("default_server") private var defaultServer: String = "https://ntfy.sh"

    var body: some View {
        Section {
            Button {
                appRouter.present(.editDefaultServer)
            } label: {
                LabeledContent("Default server", value: defaultServerHost)
            }
        } header: {
            Text("General")
        } footer: {
            Text("When subscribing to new topics, this server will be used as a default.")
        }
    }
    
    private var defaultServerHost: String {
        guard
            let url = URL(string: defaultServer),
            let host = url.host()
        else {
            return defaultServer
        }
        
        return host
    }
}

#Preview {
    GeneralSettingsSection()
}

