//
//  ntfyApp.swift
//  ntfy
//
//  Created by von Knobelsdorff, David on 12.01.26.
//

import ntfyCore
import SwiftData
import SwiftUI

@main
struct ntfyApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) private var delegate
    @State private var dependencyContainer: DependencyContainer = .live

    var body: some Scene {
        WindowGroup {
            AppTabBar()
                .environment(\.dependencies, dependencyContainer)
        }
        .modelContainer(dependencyContainer.modelContainer)
    }
}
