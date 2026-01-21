//
//  UserRow.swift
//  ntfy
//
//  Created by von Knobelsdorff, David on 14.01.26.
//

import SwiftUI

struct UserRow: View {
    let user: User
    
    var body: some View {
        Label {
            VStack(alignment: .leading) {
                Text(user.username)
                    .font(.headline)
                    .foregroundStyle(.primary)
                
                Text(user.serviceURL)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        } icon: {
            Image(systemName: "person")
        }

    }
}

#Preview {
    UserRow(user: .preview)
}
