//
//  KeyboardSettings.swift
//  iBoard
//

import Foundation

struct KeyboardSettings: Codable {
    var showNumberRow: Bool
    var showPredictions: Bool
    var showSecondarySymbols: Bool
    var enableCapsLock: Bool
    var enableSwipeGestures: Bool
    var enableSmartBackspace: Bool
    var enableContactPredictions: Bool
    var enableHapticFeedback: Bool
    var keyboardHeight: Double
    var theme: String
    
    static var `default`: KeyboardSettings {
        return KeyboardSettings(
            showNumberRow: true,
            showPredictions: true,
            showSecondarySymbols: true,
            enableCapsLock: true,
            enableSwipeGestures: true,
            enableSmartBackspace: true,
            enableContactPredictions: true,
            enableHapticFeedback: true,
            keyboardHeight: 280.0,
            theme: "dark"
        )
    }
}

struct SettingsSection {
    let title: String
    let items: [SettingsItem]
}

struct SettingsItem {
    let title: String
    let description: String
    let key: SettingsKey
    var isEnabled: Bool
}

enum SettingsKey {
    case numberRow
    case predictions
    case secondarySymbols
    case capsLock
    case swipeGestures
    case smartBackspace
    case contactPredictions
    case hapticFeedback
}
