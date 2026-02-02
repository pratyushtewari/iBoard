# iBoard - GBoard Clone for iOS

A comprehensive custom keyboard for iOS that replicates all the features of Android's GBoard.

## Features

1. **Always Show Number Row** - Persistent number row above QWERTY layout
2. **Prediction Row** - Smart text predictions at the top
3. **Secondary Symbol Pop-ups** - Long-press keys for symbols (@, #, $, etc.)
4. **Period Menu** - Double-row menu with punctuation shortcuts
5. **Emoji Keyboard** - Quick access to emojis
6. **Caps Lock** - Double-tap shift for caps lock
7. **Swipe to Delete/Undo** - Swipe left to delete, right to undo
8. **Smart Backspace** - Tap for single char, hold to accelerate deletion
9. **Undo Delete** - Swipe down on backspace or tap undo in prediction bar
10. **Contact Integration** - Predict names, emails, and numbers from contacts
11. **Settings Menu** - Customize all keyboard features
12. **Voice Dictation** - Native iOS voice input support

## Project Structure

```
iBoard/
├── iBoard/                          # Main container app
│   ├── AppDelegate.swift
│   ├── SceneDelegate.swift
│   ├── ViewController.swift
│   ├── SettingsViewController.swift
│   ├── Models/
│   │   └── KeyboardSettings.swift
│   ├── Assets.xcassets/
│   └── Info.plist
├── iBoardKeyboard/                  # Keyboard extension
│   ├── KeyboardViewController.swift
│   ├── Views/
│   │   ├── KeyboardView.swift
│   │   ├── KeyButton.swift
│   │   ├── PredictionBar.swift
│   │   ├── NumberRow.swift
│   │   ├── PopupMenu.swift
│   │   └── EmojiKeyboard.swift
│   ├── Controllers/
│   │   ├── InputManager.swift
│   │   ├── PredictionEngine.swift
│   │   └── ContactsManager.swift
│   ├── Models/
│   │   ├── KeyModel.swift
│   │   └── KeyboardLayout.swift
│   ├── Utilities/
│   │   ├── DeleteManager.swift
│   │   └── HapticFeedback.swift
│   └── Info.plist
└── Shared/
    └── UserDefaultsManager.swift
```

## Installation Instructions

1. Open `iBoard.xcodeproj` in Xcode 14.0 or later
2. Select your development team in project settings
3. Build and run on a physical iOS device (required for keyboard extensions)
4. Go to Settings > General > Keyboard > Keyboards > Add New Keyboard
5. Select "iBoard" from the list
6. Enable "Allow Full Access" for contact integration and predictions

## Requirements

- iOS 15.0+
- Xcode 14.0+
- Swift 5.7+
- Physical iOS device (keyboard extensions don't work in simulator)

## Permissions

- Contacts: For name, email, and phone number predictions
- Full Access: Required for contact integration and advanced features

## Build Configuration

1. Create the project in Xcode with two targets:
   - Main app target: `iBoard`
   - Keyboard extension target: `iBoardKeyboard`

2. Enable App Groups for data sharing:
   - Identifier: `group.com.lotusww.iBoard`

3. Add required capabilities:
   - App Groups
   - Contacts (for main app)

4. Update bundle identifiers:
   - Main app: `com.lotusww.iBoard`
   - Keyboard: `com.lotusww.iBoard.iBoardKeyboard`

## Usage

After installation, open the main app to configure settings. Toggle features on/off as needed. Changes sync immediately to the keyboard extension.

## License

Copyright © 2026. All rights reserved.
