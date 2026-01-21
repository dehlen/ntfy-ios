//
//  AddSubscriptionForm.swift
//  ntfy
//
//  Created by von Knobelsdorff, David on 12.01.26.
//

import SwiftData
import SwiftUI

struct AddSubscriptionForm: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context

    @State private var topicName: String = ""
    @State private var isUseAnotherServerEnabled: Bool = false
    @State private var serviceURL: String = ""
    
    @AppStorage("default_server") private var defaultServer: String = "https://ntfy.sh"
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Topic name, eg. phil_alerts", text: $topicName)
                        .textInputAutocapitalization(.never)
                        .keyboardType(.default)
                        .autocorrectionDisabled()
                } footer: {
                    Text("Topics may not be password-protected, so choose a name that's not easy to guess. Once subscribed, you can PUT/POST notifications.")
                }
                
                Section {
                    Toggle("Use another server", isOn: $isUseAnotherServerEnabled)
                    if isUseAnotherServerEnabled {
                        TextField("Service URL, eg. https://ntfy.home.io", text: $serviceURL)
                            .textContentType(.URL)
                            .textInputAutocapitalization(.never)
                            .keyboardType(.URL)
                            .autocorrectionDisabled()
                    }
                } footer: {
                    if isUseAnotherServerEnabled {
                        Text("To ensure instant delivery from your self-hosted server, be sure to set upstream-base-url in your server's config, otherwise messages may arrive with significant delay.")
                    }
                }
            }
            .formStyle(.grouped)
            .navigationTitle("Add subscription")
            .toolbar {
                toolbar
            }
        }
    }
    
    @ToolbarContentBuilder private var toolbar: some ToolbarContent {
        ToolbarItem(placement: .cancellationAction) {
            Button("Cancel", role: .cancel) {
                dismiss()
            }
        }
        
        ToolbarItem(placement: .confirmationAction) {
            Button("Subscribe") {
                save()
            }
            .disabled(isSubscribeDisabled)
        }
    }
    
    private var isSubscribeDisabled: Bool {
        if isUseAnotherServerEnabled, serviceURL.isEmpty {
            return true
        }
        
        if topicName.isEmpty {
            return true
        }
        
        return false
    }
    
    private func save() {
        let subscription = TopicSubscription(
            topic: topicName,
            serviceURL: isUseAnotherServerEnabled ? serviceURL : defaultServer
        )
        context.insert(subscription)
        try? context.save()
        dismiss()
    }
}

#Preview {
    AddSubscriptionForm()
}
