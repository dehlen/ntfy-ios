//
//  Bundle+Ext.swift
//  ntfy
//
//  Created by von Knobelsdorff, David on 12.01.26.
//

public import Foundation

public extension Bundle {
    nonisolated var appBaseUrl: String {
        string(for: "AppBaseURL")
    }
    
    var build: String {
        string(for: "CFBundleVersion")
    }
    
    var version: String {
        string(for: "CFBundleShortVersionString")
    }
    
    var osVersion: String {
        let os = ProcessInfo.processInfo.operatingSystemVersion
        return String(os.majorVersion) + "." + String(os.minorVersion) + "." + String(os.patchVersion)
    }
    
    private nonisolated func string(for key: String) -> String {
        Bundle.main.infoDictionary?[key] as! String
    }
}
