//
//  AppTabBar.swift
//  ntfy
//
//  Created by von Knobelsdorff, David on 12.01.26.
//

public import SwiftUI

public struct AppTabBar: View {
    @Environment(AppRouter.self) private var appRouter
    
    public init() {
    }

    public var body: some View {
        @Bindable var appRouter = appRouter

        TabView(selection: $appRouter.selectedTab) {
            ForEach(AppTab.allCases) { tab in
                Tab(value: tab) {
                    tab.destination
                } label: {
                    Label(tab.title, systemImage: tab.systemImage)
                        .symbolVariant(.fill)
                }

            }
        }
        .sheet(item: $appRouter.presented) { route in
            route.destination
        }
    }
}

#Preview {
    AppTabBar()
}
