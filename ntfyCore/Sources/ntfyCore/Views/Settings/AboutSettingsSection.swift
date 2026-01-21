//
//  AboutSettingsSection.swift
//  ntfy
//
//  Created by von Knobelsdorff, David on 14.01.26.
//

import SwiftUI

struct AboutSettingsSection: View {
    var body: some View {
        Section("About") {
            Link("Read the docs", destination: .init(string: "https://ntfy.sh/docs")!)
            Link("Report a bug", destination: .init(string: "https://github.com/binwiederhier/ntfy/issues")!)
            Link("Rate the app", destination: .init(string: "itms-apps://itunes.apple.com/app/id1625396347")!)
            LabeledContent("Version", value: "ntfy \(Bundle.main.version) (\(Bundle.main.build))")
        }
    }
}

#Preview {
    AboutSettingsSection()
}
