# iBoard Quick Reference Guide

## Quick Start Checklist

- [x] Create new iOS App project in Xcode
- [ ] Add Custom Keyboard Extension target
- [ ] Enable App Groups for both targets
- [ ] Copy all source files to project
- [ ] Add UserDefaultsManager.swift to both targets
- [ ] Update bundle identifiers
- [ ] Update App Group identifier in code
- [ ] Build and run on physical device
- [ ] Enable keyboard in iOS Settings
- [ ] Enable "Allow Full Access" for contacts
- [ ] Test all features

## File Structure Quick Reference

```
Main App Target (iBoard)
├── AppDelegate.swift
├── SceneDelegate.swift
├── ViewController.swift
├── SettingsViewController.swift
├── KeyboardSettings.swift
├── UserDefaultsManager.swift (shared)
└── Info.plist

Keyboard Extension Target (iBoardKeyboard)
├── KeyboardViewController.swift
├── KeyButton.swift
├── PredictionBar.swift
├── PopupMenu.swift
├── KeyModel.swift
├── PredictionEngine.swift
├── ContactsManager.swift
├── DeleteManager.swift
├── UserDefaultsManager.swift (shared)
└── Info.plist
```

## Key Class Responsibilities

| Class | Responsibility | Location |
|-------|---------------|----------|
| KeyboardViewController | Main keyboard coordinator | iBoardKeyboard/ |
| KeyButton | Individual key UI & touch handling | Views/ |
| PredictionBar | Prediction display & selection | Views/ |
| PopupMenu | Long-press symbol menus | Views/ |
| KeyModel | Keyboard layout data structures | Models/ |
| PredictionEngine | Text prediction logic | Controllers/ |
| ContactsManager | Contact data management | Controllers/ |
| DeleteManager | Smart deletion & undo | Utilities/ |
| UserDefaultsManager | Settings storage | Shared/ |
| ViewController | Main app home screen | iBoard/ |
| SettingsViewController | Settings UI | iBoard/ |

## Important Configuration Values

### Bundle Identifiers
- Main App: `com.lotusww.iBoard`
- Keyboard: `com.lotusww.iBoard.iBoardKeyboard`

### App Group
- Identifier: `group.com.lotusww.iBoard`
- Update in: UserDefaultsManager.swift line 13

### Minimum iOS Version
- iOS 15.0

### Required Capabilities
- App Groups (both targets)
- Contacts (main app only)

## Feature Toggle Reference

All features can be toggled in Settings:

| Feature | Setting Key | Default | Requires Full Access |
|---------|-------------|---------|---------------------|
| Number Row | showNumberRow | true | No |
| Predictions | showPredictions | true | No |
| Secondary Symbols | showSecondarySymbols | true | No |
| Caps Lock | enableCapsLock | true | No |
| Swipe Gestures | enableSwipeGestures | true | No |
| Smart Backspace | enableSmartBackspace | true | No |
| Contact Predictions | enableContactPredictions | true | Yes |
| Haptic Feedback | enableHapticFeedback | true | No |

## Common Tasks

### Adding a New Setting

1. Add property to `UserDefaultsManager.swift`
2. Add key to enum `Keys`
3. Add to `registerDefaults()`
4. Add to `KeyboardSettings.swift`
5. Add UI in `SettingsViewController.swift`
6. Use in relevant keyboard component

### Modifying Keyboard Layout

1. Edit `KeyModel.swift` → `KeyboardLayout`
2. Update key creation functions
3. Rebuild keyboard in `KeyboardViewController`
4. Test on device

### Adding New Predictions

1. Edit `PredictionEngine.swift`
2. Add words to `commonWords` array
3. Or implement custom prediction logic
4. Update `getPredictions()` function

### Customizing Appearance

1. Edit color values in component classes
2. Update `backgroundColor` properties
3. Modify `layer.cornerRadius` for shapes
4. Change font sizes in `titleLabel?.font`

## Debugging Tips

### Keyboard Not Appearing
```
Check:
1. Extension built successfully
2. App installed on device
3. Keyboard added in iOS Settings
4. Not testing in Simulator
```

### Settings Not Saving
```
Check:
1. App Groups enabled for both targets
2. App Group identifier matches in code
3. UserDefaultsManager in both targets
4. No typos in setting keys
```

### Predictions Not Working
```
Check:
1. showPredictions = true
2. textDocumentProxy has text
3. PredictionEngine initialized
4. No crashes in getPredictions()
```

### Contact Predictions Not Working
```
Check:
1. "Allow Full Access" enabled
2. Contacts permission granted
3. enableContactPredictions = true
4. ContactsManager fetchContacts() called
```

## Performance Tuning

### Memory Management
- Weak delegate references
- Timer invalidation
- Array size limits (undo stack)
- Cache expiration (contacts)

### CPU Optimization
- Debounce prediction updates
- Lazy contact loading
- Efficient string operations
- Minimal UI redraws

### Battery Life
- Reduce haptic feedback frequency
- Optimize timer intervals
- Cache frequently used data
- Minimize network calls (none currently)

## Testing Checklist

### Basic Functionality
- [ ] Tap keys to type
- [ ] Delete works
- [ ] Space bar works
- [ ] Return key works
- [ ] Shift toggles case
- [ ] Numbers appear

### Advanced Features
- [ ] Double-tap shift for caps lock
- [ ] Long press shows symbols
- [ ] Period menu appears
- [ ] Predictions show up
- [ ] Tap prediction inserts text
- [ ] Hold backspace accelerates
- [ ] Swipe left deletes
- [ ] Swipe right undos
- [ ] Contact names appear
- [ ] Settings sync to keyboard

### Edge Cases
- [ ] Empty text field
- [ ] Very long text
- [ ] Special characters
- [ ] Emoji input
- [ ] Multiple keyboards switching
- [ ] App backgrounding/foregrounding
- [ ] Low memory conditions

## Common Code Patterns

### Accessing Settings
```swift
if UserDefaultsManager.shared.showPredictions {
    // Feature enabled
}
```

### Inserting Text
```swift
textDocumentProxy.insertText("Hello")
```

### Haptic Feedback
```swift
if UserDefaultsManager.shared.enableHapticFeedback {
    feedbackGenerator.impactOccurred()
}
```

### Delegate Pattern
```swift
protocol MyDelegate: AnyObject {
    func didSomething()
}

weak var delegate: MyDelegate?
```

## Keyboard Extension Limitations

### Cannot Use
- FileManager extensively
- Background URLSession
- HealthKit
- HomeKit
- Apple Pay
- Local authentication (Face ID/Touch ID)

### Can Use
- UserDefaults (via App Groups)
- Contacts (with full access)
- UIKit (subset)
- Foundation
- Core Graphics
- Local notifications (limited)

## Support Resources

### Apple Documentation
- [App Extension Programming Guide](https://developer.apple.com/library/archive/documentation/General/Conceptual/ExtensibilityPG/)
- [Custom Keyboard Guide](https://developer.apple.com/documentation/uikit/keyboards_and_input/creating_a_custom_keyboard)
- [App Groups](https://developer.apple.com/documentation/bundleresources/entitlements/com_apple_security_application-groups)

### Common Issues
- SIGKILL on keyboard = memory limit exceeded
- Keyboard dismissed = crash or hang detected
- Settings not syncing = App Group misconfigured
- Predictions slow = optimize algorithm

## Version History

### v1.0 - Initial Release
- All 13 core features implemented
- GBoard feature parity achieved
- iOS 15.0+ support

## Next Steps After Setup

1. Test on multiple devices
2. Gather user feedback
3. Optimize performance
4. Add telemetry (privacy-conscious)
5. Plan v2.0 features
6. Submit to App Store (optional)

## Quick Commands

### Build
```
Cmd + B
```

### Run
```
Cmd + R
```

### Clean
```
Cmd + Shift + K
```

### Archive
```
Product → Archive
```

## Contact & Support

For issues with this implementation:
1. Check SETUP.md for detailed instructions
2. Review FEATURES.md for feature documentation
3. Verify all checklists completed
4. Test on physical device
5. Check Xcode console for errors

---

**Remember:** Keyboard extensions MUST be tested on physical iOS devices. The simulator will not work.

Good luck with your iBoard implementation! 🎉
