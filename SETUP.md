# iBoard - Complete Setup Instructions

## Project Setup in Xcode

Since we cannot create an actual `.xcodeproj` file programmatically, follow these steps to set up the project in Xcode:

### Step 1: Create New Xcode Project

1. Open Xcode
2. Select "File" → "New" → "Project"
3. Choose "iOS" → "App"
4. Click "Next"

**Project Settings:**
- Product Name: `iBoard`
- Team: Select your development team
- Organization Identifier: `com.lotusww` (change to your identifier)
- Interface: `Storyboard` (we'll remove it)
- Language: `Swift`
- Uncheck "Use Core Data"
- Uncheck "Include Tests"

5. Click "Next" and choose a save location
6. Click "Create"

### Step 2: Add Keyboard Extension Target

1. In Xcode, go to "File" → "New" → "Target"
2. Choose "iOS" → "Custom Keyboard Extension"
3. Click "Next"

**Extension Settings:**
- Product Name: `iBoardKeyboard`
- Team: Same as main app
- Language: `Swift`

4. Click "Finish"
5. When asked "Activate 'iBoardKeyboard' scheme?", click "Activate"

### Step 3: Configure App Groups

**For Main App Target (iBoard):**
1. Select the project in Navigator
2. Select "iBoard" target
3. Go to "Signing & Capabilities"
4. Click "+ Capability"
5. Add "App Groups"
6. Click "+" to add a new group: `group.com.lotusww.iBoard`

**For Keyboard Extension Target (iBoardKeyboard):**
1. Select "iBoardKeyboard" target
2. Go to "Signing & Capabilities"
3. Click "+ Capability"
4. Add "App Groups"
5. Select the same group: `group.com.lotusww.iBoard`

### Step 4: Remove Storyboard (Main App)

1. Select "iBoard" target
2. Go to "Info" tab
3. Find "Application Scene Manifest" → "Scene Configuration" → "Application Session Role" → "Item 0"
4. Delete the "Storyboard Name" entry
5. Delete `Main.storyboard` file from project
6. Delete `LaunchScreen.storyboard` file from project

### Step 5: Add Source Files

Create the following folder structure and add the files:

```
iBoard/
├── AppDelegate.swift
├── SceneDelegate.swift
├── ViewController.swift
├── SettingsViewController.swift
├── KeyboardSettings.swift
└── Info.plist

iBoardKeyboard/
├── KeyboardViewController.swift
├── Views/
│   ├── KeyButton.swift
│   ├── PredictionBar.swift
│   └── PopupMenu.swift
├── Models/
│   └── KeyModel.swift
├── Controllers/
│   ├── PredictionEngine.swift
│   └── ContactsManager.swift
├── Utilities/
│   └── DeleteManager.swift
└── Info.plist

Shared/
└── UserDefaultsManager.swift
```

**Important:** Add `UserDefaultsManager.swift` to BOTH targets:
1. Right-click on the file in Navigator
2. Select "Target Membership"
3. Check both "iBoard" and "iBoardKeyboard"

### Step 6: Update Bundle Identifiers

**Main App (iBoard):**
1. Select "iBoard" target
2. Go to "General" tab
3. Under "Identity", verify Bundle Identifier: `com.lotusww.iBoard`

**Keyboard Extension (iBoardKeyboard):**
1. Select "iBoardKeyboard" target
2. Go to "General" tab
3. Bundle Identifier should be: `com.lotusww.iBoard.iBoardKeyboard`

### Step 7: Update Info.plist Files

**Main App Info.plist:**
- Add the `NSContactsUsageDescription` key with description:
  "iBoard needs access to your contacts to provide name, email, and phone number predictions while typing."

**Keyboard Extension Info.plist:**
- Verify `NSExtensionPointIdentifier` is `com.apple.keyboard-service`
- Verify `RequestsOpenAccess` is set to `YES` (for contact access)

### Step 8: Update App Group Identifier in Code

In `UserDefaultsManager.swift`, update line 13:
```swift
private let appGroupIdentifier = "group.com.lotusww.iBoard"
```
Replace `com.lotusww` with your actual organization identifier.

### Step 9: Build Settings

**For Both Targets:**
1. Set iOS Deployment Target to 15.0 or higher
2. Ensure Swift Language Version is Swift 5

### Step 10: Test Build

1. Select "iBoard" scheme
2. Select a physical iOS device (keyboard extensions don't work in simulator)
3. Click "Build" (Cmd+B)
4. Fix any build errors

## Installation on Device

1. Build and run the app on your physical iPhone
2. After installation, go to iPhone Settings → General → Keyboard → Keyboards
3. Tap "Add New Keyboard"
4. Select "iBoard" from the list
5. Tap on "iBoard" in the keyboard list
6. Enable "Allow Full Access" for contact predictions

## File Organization

Make sure to organize files in Xcode groups to match this structure:

```
iBoard (Group)
├── App
│   ├── AppDelegate.swift
│   ├── SceneDelegate.swift
│   └── Info.plist
├── ViewControllers
│   ├── ViewController.swift
│   └── SettingsViewController.swift
├── Models
│   └── KeyboardSettings.swift
└── Resources

iBoardKeyboard (Group)
├── KeyboardViewController.swift
├── Views
│   ├── KeyButton.swift
│   ├── PredictionBar.swift
│   └── PopupMenu.swift
├── Models
│   └── KeyModel.swift
├── Controllers
│   ├── PredictionEngine.swift
│   └── ContactsManager.swift
├── Utilities
│   └── DeleteManager.swift
└── Info.plist

Shared (Group)
└── UserDefaultsManager.swift
```

## Troubleshooting

### Keyboard doesn't appear in Settings
- Make sure the app is installed on the device
- Check that the keyboard extension target builds successfully
- Verify Info.plist settings for the extension

### Can't access contacts
- Enable "Allow Full Access" in Settings → General → Keyboard → Keyboards → iBoard
- Check that NSContactsUsageDescription is in the main app's Info.plist
- Grant contacts permission when prompted by the main app

### Settings not syncing
- Verify both targets have the same App Group enabled
- Check that the App Group identifier matches in code and capabilities
- Make sure UserDefaultsManager.swift is included in both targets

### Build errors
- Clean build folder (Cmd+Shift+K)
- Delete derived data
- Restart Xcode
- Ensure all files are added to correct targets

## Features Implementation Status

✅ Number row always visible
✅ Prediction bar with text suggestions
✅ Secondary symbols on long press
✅ Period menu with punctuation
✅ Emoji keyboard access
✅ Caps lock (double-tap shift)
✅ Swipe gestures on backspace
✅ Smart backspace acceleration
✅ Undo functionality
✅ Contact integration
✅ Settings menu with toggles
✅ Voice dictation (via iOS)
✅ Haptic feedback

## Next Steps

1. Customize the keyboard appearance (colors, fonts)
2. Add more prediction algorithms
3. Implement swipe typing (advanced)
4. Add multiple language support
5. Create custom themes
6. Add GIF/sticker support
7. Implement clipboard manager
8. Add text shortcuts/macros

## Notes

- This keyboard requires a physical iOS device to test
- Full access is required for contact predictions
- Some features (like swipe typing) require additional implementation
- The keyboard will work on iOS 15.0 and later
- Make sure to test on different iPhone models and orientations
