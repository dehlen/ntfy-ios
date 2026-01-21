//
//  DetailRow.swift
//  ntfy
//
//  Created by von Knobelsdorff, David on 14.01.26.
//

import SwiftUI

struct DetailRow: View {
    let headline: String
    let subheadline: String?

    var body: some View {
        VStack(alignment: .leading) {
            Text(headline)
                .font(.headline)
                .foregroundStyle(.primary)
            if let subheadline {
                Text(subheadline)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
    }
}

#Preview {
    DetailRow(headline: "Headline", subheadline: "Subheadline")
}
