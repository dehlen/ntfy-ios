//
//  UserStore.swift
//  ntfy
//
//  Created by von Knobelsdorff, David on 14.01.26.
//

public import Foundation
import Security

public protocol UserStore: Observable {
    var users: [User] { get set }

    func saveUser(user: User, password: String) throws
    func updateUser(user: User, newUsername: String, newPassword: String?) throws
    func fetchPassword(for userID: User.ID) throws -> String
    func deleteUser(userID: User.ID) throws
}

@Observable public final class LiveUserStore: UserStore {
    private let service: String
    private let accessGroup: String

    private let decoder = JSONDecoder()
    private let encoder = JSONEncoder()
    
    public var users: [User] = []
    
    public init(service: String = Bundle.main.bundleIdentifier!, accessGroup: String = "group.\(Bundle.main.bundleIdentifier!)") {
        self.service = service
        self.accessGroup = accessGroup
        self.fetchUsers()
    }

    // MARK: - Save / Update

    public func saveUser(
        user: User,
        password: String
    ) throws {
        let metadata: [String: String] = [
            "serviceURL": user.serviceURL,
            "username": user.username
        ]

        let metadataData = try encoder.encode(metadata)
        let passwordData = Data(password.utf8)

        let item: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: user.id,
            kSecValueData as String: passwordData,
            kSecAttrGeneric as String: metadataData,
            kSecAttrAccessGroup as String: accessGroup
        ]

        let status = SecItemAdd(item as CFDictionary, nil)
        guard status == errSecSuccess else {
            throw KeychainError.unexpectedStatus(status)
        }
        
        fetchUsers()
    }
    
    public func updateUser(
        user: User,
        newUsername: String,
        newPassword: String?
    ) throws {
        let metadata: [String: String] = [
            "serviceURL": user.serviceURL,
            "username": newUsername
        ]

        let metadataData = try encoder.encode(metadata)

        var attributes: [String: Any] = [
            kSecAttrGeneric as String: metadataData
        ]

        if let newPassword, !newPassword.isEmpty {
            attributes[kSecValueData as String] = Data(newPassword.utf8)
        }

        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: user.id,
            kSecAttrAccessGroup as String: accessGroup
        ]

        let status = SecItemUpdate(query as CFDictionary, attributes as CFDictionary)
        guard status == errSecSuccess else {
            throw KeychainError.unexpectedStatus(status)
        }
        
        fetchUsers()
    }

    // MARK: - Fetch password

    public func fetchPassword(for userID: User.ID) throws -> String {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: userID,
            kSecAttrAccessGroup as String: accessGroup,
            kSecReturnData as String: true
        ]

        var result: AnyObject?
        let status = unsafe SecItemCopyMatching(query as CFDictionary, &result)

        guard
            status == errSecSuccess,
            let data = result as? Data,
            let password = String(data: data, encoding: .utf8)
        else {
            throw KeychainError.unexpectedStatus(status)
        }

        return password
    }

    // MARK: - Delete user

    public func deleteUser(userID: User.ID) throws {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: userID,
            kSecAttrAccessGroup as String: accessGroup
        ]

        let status = SecItemDelete(query as CFDictionary)

        guard status == errSecSuccess || status == errSecItemNotFound else {
            throw KeychainError.unexpectedStatus(status)
        }
        
        fetchUsers()
    }
    
    // MARK: - Fetch users

    private func fetchUsers() {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecMatchLimit as String: kSecMatchLimitAll,
            kSecAttrAccessGroup as String: accessGroup,
            kSecReturnAttributes as String: true
        ]

        var result: AnyObject?
        let status = unsafe SecItemCopyMatching(query as CFDictionary, &result)

        guard status == errSecSuccess else {
            self.users = []
            return
        }

        guard let items = result as? [[String: Any]] else {
            self.users = []
            return
        }

        self.users = items.compactMap { item in
            guard
                let id = item[kSecAttrAccount as String] as? String,
                let metadataData = item[kSecAttrGeneric as String] as? Data,
                let metadata = try? decoder.decode([String: String].self, from: metadataData),
                let serviceURL = metadata["serviceURL"],
                let username = metadata["username"]
            else {
                return nil
            }

            return User(
                id: id,
                serviceURL: serviceURL,
                username: username
            )
        }
    }
}

public enum KeychainError: LocalizedError {
    case unexpectedStatus(OSStatus)
}
