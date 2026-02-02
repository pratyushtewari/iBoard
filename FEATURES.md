# iBoard Features Documentation

## Complete Feature List

### 1. Always Show Number Row ✓

**Implementation:** `KeyModel.swift` - `createNumberRow()`

The number row (1-0) is persistently displayed above the QWERTY layout.

**How it works:**
- Numbers 1-9 and 0 are always visible in a dedicated row
- Located between the prediction bar and main keyboard
- Can be toggled in settings
- Each number key is 32pt tall
- Matches GBoard's layout exactly

**Code Location:** Lines in `KeyboardViewController.swift` - `setupNumberRow()`

### 2. Prediction Row ✓

**Implementation:** `PredictionBar.swift`

Smart text prediction bar displays up to 3 suggestions above the keyboard.

**Features:**
- Shows 3 most relevant predictions
- Primary prediction (first) is bold
- Tap to insert prediction
- Automatically adds space after insertion
- Updates in real-time as you type
- Shows undo button when text is deleted

**Prediction Engine:** `PredictionEngine.swift`
- Common English words (100+ words)
- Learned word frequency
- Contact-based predictions (names, emails, phones)
- Context-aware suggestions

### 3. Secondary Symbol Pop-ups ✓

**Implementation:** `KeyButton.swift` + `PopupMenu.swift`

Long-press letter keys to access secondary symbols (@, #, $, etc.)

**Symbol Mapping:**
- Q → 1
- W → 2
- E → 3
- R → 4
- T → 5
- Y → 6
- U → 7
- I → 8
- O → 9
- P → 0
- A → @
- S → #
- D → $
- F → %
- G → &
- H → *
- J → (
- K → )

**How it works:**
- Long press any key for 0.5 seconds
- Popup menu appears above the key
- Tap the desired symbol
- Menu dismisses automatically

### 4. Period Menu (Double Row) ✓

**Implementation:** `PopupMenu.swift` - Double row layout

Long-press the period key (.) for quick access to punctuation.

**Available symbols:** . , ? ! ' " - @ _ ; /

**Layout:**
- Two rows of symbols
- 6 symbols per row
- Optimized for one-handed use
- Matches GBoard's exact layout

### 5. Emoji Button ✓

**Implementation:** `KeyboardViewController.swift`

Quick access to emoji keyboard via dedicated button.

**Location:** Bottom row, between number toggle and globe
**Action:** Switches to iOS emoji keyboard
**Icon:** 😊

### 6. Caps Lock ✓

**Implementation:** `KeyboardViewController.swift` - `toggleShift()`

Double-tap shift key to enable caps lock.

**Behavior:**
- Single tap: Shift (next letter capitalized)
- Double tap (within 0.3s): Caps lock enabled
- Caps lock keeps all letters uppercase
- Shift key turns blue when caps lock is active
- Tap shift again to disable

**Visual Feedback:**
- Shift active: Highlighted background
- Caps lock: Blue background color

### 7. Backspace Swipe Gestures ✓

**Implementation:** `SwipeGestureManager.swift` + `DeleteManager.swift`

Swipe on backspace key for quick delete/undo actions.

**Gestures:**
- **Swipe Left:** Delete characters continuously
- **Swipe Right:** Undo last deletion
- **Swipe Down:** Undo last deletion

**Threshold:** 30 points of movement
**Features:**
- Haptic feedback on swipe
- Continuous deletion while swiping left
- Single undo action on right/down swipe

### 8. Smart Backspace ✓

**Implementation:** `DeleteManager.swift`

Intelligent backspace with acceleration for faster deletion.

**Behavior:**
- **Tap:** Delete single character
- **Hold 0-1.5s:** Delete characters one by one (0.1s interval)
- **Hold 1.5-3s:** Accelerate to word deletion
- **Hold 3s+:** Delete entire lines

**Features:**
- Smooth acceleration curve
- Visual feedback (undo button appears)
- Automatic stack management for undo

### 9. Undo Delete ✓

**Implementation:** `DeleteManager.swift` + `PredictionBar.swift`

Multiple ways to undo deletions.

**Methods:**
1. Tap "Undo" button in prediction bar
2. Swipe right on backspace
3. Swipe down on backspace

**Undo Stack:**
- Stores up to 50 deletion operations
- Restores exact deleted text
- LIFO (Last In, First Out) order
- Automatically cleared after successful undo

### 10. Contact Integration ✓

**Implementation:** `ContactsManager.swift` + `PredictionEngine.swift`

Predicts contact names, emails, and phone numbers while typing.

**Features:**
- Fetches all contacts on keyboard load
- Caches for 1 hour to improve performance
- Predicts based on input type:
  - Regular text → Name predictions
  - Contains @ → Email predictions
  - Starts with digit/+ → Phone predictions

**Requirements:**
- "Allow Full Access" must be enabled
- Contacts permission granted
- Can be disabled in settings

**Privacy:**
- All processing done on-device
- No data sent to external servers
- Cached locally only

### 11. Settings Menu ✓

**Implementation:** `SettingsViewController.swift`

Comprehensive settings interface in main app.

**Settings Categories:**

**Layout:**
- Show Number Row (toggle)
- Show Secondary Symbols (toggle)

**Predictions:**
- Show Predictions (toggle)
- Contact Predictions (toggle)

**Input:**
- Caps Lock (toggle)
- Smart Backspace (toggle)
- Swipe Gestures (toggle)

**Feedback:**
- Haptic Feedback (toggle)

**How it works:**
- Settings stored in shared UserDefaults (App Groups)
- Sync instantly between app and keyboard
- Changes take effect on next keyboard use
- Each setting has title and description

### 12. Voice Dictation ✓

**Implementation:** Native iOS integration

Access voice dictation through iOS's built-in microphone button.

**How to access:**
- Tap globe key to switch keyboards
- iOS dictation button appears automatically
- Or use long-press on space bar (iOS default)

**Note:** This is handled entirely by iOS - no custom implementation needed.

## Additional Features

### Haptic Feedback

**Implementation:** `KeyButton.swift`

Provides tactile feedback on key press.

**Type:** Light impact feedback
**Trigger:** Every key press
**Can be disabled:** Yes, in settings

### Visual Feedback

**Implementation:** `KeyButton.swift`

Keys animate when pressed for visual confirmation.

**Animation:**
- Scale down to 95% on press
- Return to 100% on release
- Background color change
- Duration: 0.1 seconds

### Adaptive Layout

**Implementation:** `KeyModel.swift`

Keyboard adapts to different screen sizes.

**Features:**
- Calculates key sizes based on screen width
- Maintains proper spacing
- Works in portrait and landscape
- Optimized for all iPhone models

### Theme Support

**Implementation:** `UserDefaultsManager.swift`

Foundation for theme customization.

**Current:**
- Dark theme (default)
- Stored in UserDefaults

**Future:**
- Light theme
- Custom color themes
- User-uploaded themes

## Technical Implementation Details

### Architecture

**Pattern:** MVC (Model-View-Controller)
**Data Flow:** UserDefaults (App Groups) for cross-target communication
**State Management:** Centralized in UserDefaultsManager

### Key Components

1. **KeyboardViewController**
   - Main coordinator for keyboard
   - Handles input events
   - Manages keyboard state

2. **KeyButton**
   - Individual key representation
   - Handles touch events
   - Manages visual state

3. **PredictionBar**
   - Displays predictions
   - Handles prediction selection
   - Shows/hides undo button

4. **DeleteManager**
   - Manages deletion logic
   - Implements acceleration
   - Maintains undo stack

5. **PredictionEngine**
   - Generates text predictions
   - Learns word frequency
   - Integrates contact data

6. **ContactsManager**
   - Fetches contact data
   - Caches for performance
   - Provides contact predictions

### Performance Optimizations

1. **Contact Caching**
   - 1-hour cache duration
   - Prevents repeated fetches
   - Reduces battery usage

2. **Prediction Limiting**
   - Maximum 3 predictions shown
   - Sorted by relevance
   - Duplicate removal

3. **Undo Stack Size**
   - Limited to 50 operations
   - Prevents memory bloat
   - Automatic cleanup

4. **Timer Management**
   - Proper cleanup on touch end
   - Prevents memory leaks
   - Optimized intervals

## Code Quality

### Swift Best Practices

- Protocol-oriented design
- Delegation pattern
- Strong typing
- Optional safety
- Memory management (weak references)

### Error Handling

- Try-catch blocks for file operations
- Nil checking for optionals
- Default value fallbacks
- Graceful degradation

### Documentation

- Inline comments for complex logic
- MARK: statements for organization
- Clear naming conventions
- Comprehensive README

## Testing Recommendations

### Unit Tests

1. PredictionEngine word matching
2. DeleteManager acceleration timing
3. UserDefaultsManager data persistence
4. ContactsManager caching logic

### UI Tests

1. Key tap responsiveness
2. Long press menu appearance
3. Swipe gesture recognition
4. Settings synchronization

### Integration Tests

1. End-to-end typing flow
2. Prediction → insertion flow
3. Delete → undo flow
4. Contact fetch → prediction flow

## Future Enhancements

### Planned Features

1. **Swipe Typing**
   - Gesture recognition
   - Path tracing
   - Word prediction from swipe

2. **Multiple Languages**
   - Language detection
   - Multilingual predictions
   - Language-specific layouts

3. **Custom Themes**
   - Color customization
   - Key shape options
   - Background images

4. **Clipboard Manager**
   - Copy/paste history
   - Pinned items
   - Quick paste

5. **Text Shortcuts**
   - Custom text replacements
   - Phrase expansion
   - Macro support

6. **GIF/Sticker Support**
   - GIF search
   - Sticker packs
   - Recent GIFs

### Known Limitations

1. **Simulator Testing**
   - Keyboard extensions require physical device
   - Cannot test in iOS Simulator

2. **Full Access Requirement**
   - Contact predictions need full access
   - Privacy considerations

3. **Layout Constraints**
   - Fixed keyboard height
   - Limited customization by iOS

4. **Prediction Accuracy**
   - Basic algorithm
   - Needs machine learning for better results

## Support & Maintenance

### Updating the Keyboard

1. Modify source files
2. Build and run
3. Keyboard updates automatically
4. No reinstall required

### Debugging

1. Use Xcode console for logs
2. Check UserDefaults for settings
3. Verify App Group configuration
4. Test on multiple devices

### Version Control

- Git repository recommended
- Tag releases
- Document changes
- Maintain changelog

## Conclusion

iBoard successfully implements all major GBoard features for iOS, providing a familiar and powerful typing experience. The modular architecture allows for easy extension and customization, while maintaining high performance and user privacy.
