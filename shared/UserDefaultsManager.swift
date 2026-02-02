//
//  UserDefaultsManager.swift
//  iBoard
//
//  Shared between main app and keyboard extension
//

import Foundation

class UserDefaultsManager {
    static let shared = UserDefaultsManager()
    
    // App Group identifier for sharing data between app and extension
    private let appGroupIdentifier = "group.com.lotusww.iBoard"
    
    private var userDefaults: UserDefaults? {
        return UserDefaults(suiteName: appGroupIdentifier)
    }
    
    // Settings Keys
    private enum Keys {
        static let showNumberRow = "showNumberRow"
        static let showPredictions = "showPredictions"
        static let showSecondarySymbols = "showSecondarySymbols"
        static let enableCapsLock = "enableCapsLock"
        static let enableSwipeGestures = "enableSwipeGestures"
        static let enableSmartBackspace = "enableSmartBackspace"
        static let enableContactPredictions = "enableContactPredictions"
        static let enableHapticFeedback = "enableHapticFeedback"
        static let keyboardHeight = "keyboardHeight"
        static let theme = "theme"
    }
    
    // MARK: - Settings Properties
    
    var showNumberRow: Bool {
        get { userDefaults?.bool(forKey: Keys.showNumberRow) ?? true }
        set { userDefaults?.set(newValue, forKey: Keys.showNumberRow) }
    }
    
    var showPredictions: Bool {
        get { userDefaults?.bool(forKey: Keys.showPredictions) ?? true }
        set { userDefaults?.set(newValue, forKey: Keys.showPredictions) }
    }
    
    var showSecondarySymbols: Bool {
        get { userDefaults?.bool(forKey: Keys.showSecondarySymbols) ?? true }
        set { userDefaults?.set(newValue, forKey: Keys.showSecondarySymbols) }
    }
    
    var enableCapsLock: Bool {
        get { userDefaults?.bool(forKey: Keys.enableCapsLock) ?? true }
        set { userDefaults?.set(newValue, forKey: Keys.enableCapsLock) }
    }
    
    var enableSwipeGestures: Bool {
        get { userDefaults?.bool(forKey: Keys.enableSwipeGestures) ?? true }
        set { userDefaults?.set(newValue, forKey: Keys.enableSwipeGestures) }
    }
    
    var enableSmartBackspace: Bool {
        get { userDefaults?.bool(forKey: Keys.enableSmartBackspace) ?? true }
        set { userDefaults?.set(newValue, forKey: Keys.enableSmartBackspace) }
    }
    
    var enableContactPredictions: Bool {
        get { userDefaults?.bool(forKey: Keys.enableContactPredictions) ?? true }
        set { userDefaults?.set(newValue, forKey: Keys.enableContactPredictions) }
    }
    
    var enableHapticFeedback: Bool {
        get { userDefaults?.bool(forKey: Keys.enableHapticFeedback) ?? true }
        set { userDefaults?.set(newValue, forKey: Keys.enableHapticFeedback) }
    }
    
    var keyboardHeight: CGFloat {
        get { CGFloat(userDefaults?.double(forKey: Keys.keyboardHeight) ?? 440.0) }
        set { userDefaults?.set(Double(newValue), forKey: Keys.keyboardHeight) }
    }
    
    var theme: String {
        get { userDefaults?.string(forKey: Keys.theme) ?? "dark" }
        set { userDefaults?.set(newValue, forKey: Keys.theme) }
    }
    
    // MARK: - Initialization
    
    private init() {
        // Set default values on first launch
        registerDefaults()
    }
    
    private func registerDefaults() {
        let defaults: [String: Any] = [
            Keys.showNumberRow: true,
            Keys.showPredictions: true,
            Keys.showSecondarySymbols: true,
            Keys.enableCapsLock: true,
            Keys.enableSwipeGestures: true,
            Keys.enableSmartBackspace: true,
            Keys.enableContactPredictions: true,
            Keys.enableHapticFeedback: true,
            Keys.keyboardHeight: 440.0,
            Keys.theme: "dark"
        ]
        
        userDefaults?.register(defaults: defaults)
    }
    
    // MARK: - Reset
    
    func resetToDefaults() {
        showNumberRow = true
        showPredictions = true
        showSecondarySymbols = true
        enableCapsLock = true
        enableSwipeGestures = true
        enableSmartBackspace = true
        enableContactPredictions = true
        enableHapticFeedback = true
        keyboardHeight = 440.0
        theme = "dark"
    }
}
