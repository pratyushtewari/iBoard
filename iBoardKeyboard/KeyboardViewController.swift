//
//  KeyboardViewController.swift
//  iBoardKeyboard
//
//  FIXED VERSION - Ensures keyboard displays properly
//

import UIKit

class KeyboardViewController: UIInputViewController {
    
    // MARK: - Properties
    
    private var keyboardView: UIView!
    private var predictionBar: PredictionBar?
    private var numberRow: UIView?
    private var keyButtons: [KeyButton] = []
    private var currentPopupMenu: PopupMenu?
    
    private var isShiftEnabled = false
    private var isCapsLockEnabled = false
    private var lastShiftTapTime: Date?
    
    private var isNumberMode = false
    private var isSymbolMode = false
    
    private let deleteManager = DeleteManager()
    private let swipeGestureManager = SwipeGestureManager()
    
    private var currentText: String = ""
    private var lastDeletedText: String = ""
    
    override var needsInputModeSwitchKey: Bool {
        return false // We handle it manually with emoji button
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("KeyboardViewController viewDidLoad")
        
        // Set background color immediately
        view.backgroundColor = UIColor(white: 0.1, alpha: 1.0)
        
        // Setup keyboard UI
        setupKeyboardContainer()
        setupDeleteManager()
        setupSwipeGestures()
        
        // Fetch contacts on load
        if UserDefaultsManager.shared.enableContactPredictions {
            ContactsManager.shared.fetchContacts()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("KeyboardViewController viewWillAppear")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        print("KeyboardViewController viewDidAppear - view bounds: \(view.bounds)")
        
        // Build keyboard after view appears to ensure proper sizing
        if keyButtons.isEmpty {
            buildKeyboard()
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        print("KeyboardViewController viewDidLayoutSubviews - view bounds: \(view.bounds)")
    }
    
    // MARK: - Setup
    
    private func setupKeyboardContainer() {
        // Create main keyboard container
        keyboardView = UIView()
        keyboardView.backgroundColor = UIColor(white: 0.1, alpha: 1.0)
        keyboardView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(keyboardView)
        
        let height = UserDefaultsManager.shared.keyboardHeight
        
        NSLayoutConstraint.activate([
            keyboardView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            keyboardView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            keyboardView.topAnchor.constraint(equalTo: view.topAnchor),
            keyboardView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        // Force layout
        view.layoutIfNeeded()
    }
    
    private func buildKeyboard() {
        print("Building keyboard...")
        
        // Clear any existing elements
        keyButtons.forEach { $0.removeFromSuperview() }
        keyButtons.removeAll()
        predictionBar?.removeFromSuperview()
        predictionBar = nil
        numberRow?.removeFromSuperview()
        numberRow = nil
        
        // Get actual width
        let width = keyboardView.bounds.width > 0 ? keyboardView.bounds.width : UIScreen.main.bounds.width
        print("Using width: \(width)")
        
        var yOffset: CGFloat = 5
        
        // Setup prediction bar
        if UserDefaultsManager.shared.showPredictions {
            predictionBar = PredictionBar(frame: CGRect(x: 0, y: yOffset, width: width, height: 40))
            predictionBar?.delegate = self
            keyboardView.addSubview(predictionBar!)
            yOffset += 45
        }
        
        // Setup number row
        if UserDefaultsManager.shared.showNumberRow {
            buildNumberRow(at: yOffset, width: width)
            yOffset += 37
        }
        
        // Build main keyboard
        buildQWERTYKeyboard(startingAt: yOffset, width: width)
        
        print("Keyboard built with \(keyButtons.count) buttons")
    }
    
    private func buildNumberRow(at yPosition: CGFloat, width: CGFloat) {
        let keyWidth: CGFloat = (width - 20) / 10
        let keyHeight: CGFloat = 32
        let spacing: CGFloat = 2
        
        let numbers = ["1", "2", "3", "4", "5", "6", "7", "8", "9", "0"]
        
        for (index, number) in numbers.enumerated() {
            let x = CGFloat(index) * (keyWidth + spacing) + 2
            let frame = CGRect(x: x, y: yPosition, width: keyWidth, height: keyHeight)
            let key = KeyModel(type: .number(number), frame: frame)
            
            let button = KeyButton(key: key)
            button.delegate = self
            keyboardView.addSubview(button)
            keyButtons.append(button)
        }
    }
    
    private func buildQWERTYKeyboard(startingAt yOffset: CGFloat, width: CGFloat) {
        let keyWidth: CGFloat = (width - 20) / 10
        let keyHeight: CGFloat = 42
        let spacing: CGFloat = 2
        
        // Row 1: Q W E R T Y U I O P
        let row1 = ["q", "w", "e", "r", "t", "y", "u", "i", "o", "p"]
        let row1Secondary = ["1", "2", "3", "4", "5", "6", "7", "8", "9", "0"]
        
        for (index, char) in row1.enumerated() {
            let x = CGFloat(index) * (keyWidth + spacing) + 2
            let y = yOffset
            let frame = CGRect(x: x, y: y, width: keyWidth, height: keyHeight)
            let primary = isShiftEnabled || isCapsLockEnabled ? char.uppercased() : char
            let secondary = row1Secondary[index]
            let key = KeyModel(type: .character(primary: primary, secondary: secondary), frame: frame)
            
            let button = KeyButton(key: key)
            button.delegate = self
            keyboardView.addSubview(button)
            keyButtons.append(button)
        }
        
        // Row 2: A S D F G H J K L
        let row2 = ["a", "s", "d", "f", "g", "h", "j", "k", "l"]
        let row2Secondary = ["@", "#", "$", "%", "&", "*", "(", ")", nil]
        let row2Offset: CGFloat = keyWidth * 0.5
        
        for (index, char) in row2.enumerated() {
            let x = row2Offset + CGFloat(index) * (keyWidth + spacing) + 2
            let y = yOffset + keyHeight + spacing
            let frame = CGRect(x: x, y: y, width: keyWidth, height: keyHeight)
            let primary = isShiftEnabled || isCapsLockEnabled ? char.uppercased() : char
            let key = KeyModel(type: .character(primary: primary, secondary: row2Secondary[index]), frame: frame)
            
            let button = KeyButton(key: key)
            button.delegate = self
            keyboardView.addSubview(button)
            keyButtons.append(button)
        }
        
        // Row 3: Shift + Z X C V B N M + Backspace
        let shiftWidth: CGFloat = keyWidth * 1.5
        let backspaceWidth: CGFloat = keyWidth * 1.5
        let y3 = yOffset + (keyHeight + spacing) * 2
        
        // Shift key
        let shiftFrame = CGRect(x: 2, y: y3, width: shiftWidth, height: keyHeight)
        let shiftKey = KeyModel(type: .special(.shift), frame: shiftFrame)
        let shiftButton = KeyButton(key: shiftKey)
        shiftButton.delegate = self
        keyboardView.addSubview(shiftButton)
        keyButtons.append(shiftButton)
        
        // Z X C V B N M
        let row3 = ["z", "x", "c", "v", "b", "n", "m"]
        let row3Offset: CGFloat = shiftWidth + spacing + 2
        
        for (index, char) in row3.enumerated() {
            let x = row3Offset + CGFloat(index) * (keyWidth + spacing)
            let frame = CGRect(x: x, y: y3, width: keyWidth, height: keyHeight)
            let primary = isShiftEnabled || isCapsLockEnabled ? char.uppercased() : char
            let key = KeyModel(type: .character(primary: primary, secondary: nil), frame: frame)
            
            let button = KeyButton(key: key)
            button.delegate = self
            keyboardView.addSubview(button)
            keyButtons.append(button)
        }
        
        // Backspace key
        let backspaceX = row3Offset + CGFloat(row3.count) * (keyWidth + spacing)
        let backspaceFrame = CGRect(x: backspaceX, y: y3, width: backspaceWidth, height: keyHeight)
        let backspaceKey = KeyModel(type: .special(.backspace), frame: backspaceFrame)
        let backspaceButton = KeyButton(key: backspaceKey)
        backspaceButton.delegate = self
        keyboardView.addSubview(backspaceButton)
        keyButtons.append(backspaceButton)
        
        // Bottom row
        buildBottomRow(startingAt: yOffset + (keyHeight + spacing) * 3, width: width)
    }
    
    private func buildBottomRow(startingAt yPosition: CGFloat, width: CGFloat) {
        let keyHeight: CGFloat = 42
        let spacing: CGFloat = 4
        
        // ?123 button
        let numberToggleWidth: CGFloat = 60
        let numberToggleFrame = CGRect(x: 2, y: yPosition, width: numberToggleWidth, height: keyHeight)
        let numberToggleKey = KeyModel(type: .special(.numberToggle), frame: numberToggleFrame)
        let numberToggleButton = KeyButton(key: numberToggleKey)
        numberToggleButton.delegate = self
        keyboardView.addSubview(numberToggleButton)
        keyButtons.append(numberToggleButton)
        
        // Emoji button - marked as input mode switcher for iOS
        let emojiWidth: CGFloat = 38
        let emojiX = numberToggleWidth + spacing + 2
        let emojiFrame = CGRect(x: emojiX, y: yPosition, width: emojiWidth, height: keyHeight)
        var emojiKey = KeyModel(type: .emoji, frame: emojiFrame)
        emojiKey.isInputModeSwitcher = true
        let emojiButton = KeyButton(key: emojiKey)
        emojiButton.delegate = self
        keyboardView.addSubview(emojiButton)
        keyButtons.append(emojiButton)
        
        // Space bar (expanded - no globe button)
        let returnWidth: CGFloat = 75
        let periodWidth: CGFloat = 38
        let spaceX = emojiX + emojiWidth + spacing
        let spaceWidth = width - spaceX - returnWidth - periodWidth - spacing * 2 - 2
        let spaceFrame = CGRect(x: spaceX, y: yPosition, width: spaceWidth, height: keyHeight)
        let spaceKey = KeyModel(type: .special(.space), frame: spaceFrame)
        let spaceButton = KeyButton(key: spaceKey)
        spaceButton.delegate = self
        keyboardView.addSubview(spaceButton)
        keyButtons.append(spaceButton)
        
        // Period with long-press menu - Updated symbols: . , ! & ( ) @
        let periodX = spaceX + spaceWidth + spacing
        let periodFrame = CGRect(x: periodX, y: yPosition, width: periodWidth, height: keyHeight)
        let periodKey = KeyModel(
            type: .character(primary: ".", secondary: nil),
            frame: periodFrame,
            longPressActions: [".", ",", "!", "&", "(", ")", "@"]
        )
        let periodButton = KeyButton(key: periodKey)
        periodButton.delegate = self
        keyboardView.addSubview(periodButton)
        keyButtons.append(periodButton)
        
        // Return key
        let returnX = periodX + periodWidth + spacing
        let returnFrame = CGRect(x: returnX, y: yPosition, width: returnWidth, height: keyHeight)
        let returnKey = KeyModel(type: .special(.return), frame: returnFrame)
        let returnButton = KeyButton(key: returnKey)
        returnButton.delegate = self
        keyboardView.addSubview(returnButton)
        keyButtons.append(returnButton)
    }
    
    private func setupDeleteManager() {
        deleteManager.delegate = self
        
        swipeGestureManager.onSwipe = { [weak self] direction in
            guard let self = self else { return }
            
            switch direction {
            case .left:
                // Swipe left - delete character
                self.deleteCharacter()
            case .right:
                // Swipe right - undo
                self.performUndo()
            case .down:
                // Swipe down - undo
                self.performUndo()
            }
        }
    }
    
    private func setupSwipeGestures() {
        // Swipe gestures are handled in KeyButton touch events
    }
    
    // MARK: - Text Input
    
    private func insertText(_ text: String) {
        textDocumentProxy.insertText(text)
        currentText += text
        
        // Learn the word for predictions
        if text == " " {
            if let lastWord = currentText.split(separator: " ").last {
                PredictionEngine.shared.learnWord(String(lastWord))
            }
        }
        
        updatePredictions()
        
        // Reset shift after character input (unless caps lock)
        if isShiftEnabled && !isCapsLockEnabled {
            isShiftEnabled = false
            updateKeyboardCase()
        }
    }
    
    private func deleteCharacter() {
        guard textDocumentProxy.hasText else { return }
        
        // Save deleted text for undo
        if let beforeContext = textDocumentProxy.documentContextBeforeInput,
           !beforeContext.isEmpty {
            let deletedChar = String(beforeContext.last!)
            lastDeletedText = deletedChar
            deleteManager.addToCurrentDeletion(deletedChar)
        }
        
        textDocumentProxy.deleteBackward()
        
        if !currentText.isEmpty {
            currentText.removeLast()
        }
        
        updatePredictions()
        
        // Show undo in prediction bar
        if UserDefaultsManager.shared.showPredictions {
            predictionBar?.showUndo()
        }
    }
    
    private func deleteWord() {
        guard let beforeContext = textDocumentProxy.documentContextBeforeInput else { return }
        
        // Find the last word
        var deleteCount = 0
        var foundNonSpace = false
        
        for char in beforeContext.reversed() {
            if char == " " {
                if foundNonSpace {
                    break
                }
            } else {
                foundNonSpace = true
            }
            deleteCount += 1
        }
        
        // Save for undo
        if deleteCount > 0 {
            let startIndex = beforeContext.index(beforeContext.endIndex, offsetBy: -deleteCount)
            let deletedText = String(beforeContext[startIndex...])
            lastDeletedText = deletedText
            deleteManager.addToCurrentDeletion(deletedText)
        }
        
        for _ in 0..<deleteCount {
            textDocumentProxy.deleteBackward()
        }
        
        updatePredictions()
        predictionBar?.showUndo()
    }
    
    private func deleteLine() {
        guard let beforeContext = textDocumentProxy.documentContextBeforeInput else { return }
        
        // Find the last newline or delete entire context
        var deleteCount = 0
        
        for char in beforeContext.reversed() {
            if char == "\n" {
                break
            }
            deleteCount += 1
        }
        
        if deleteCount == 0 {
            deleteCount = beforeContext.count
        }
        
        // Save for undo
        if deleteCount > 0 {
            let startIndex = beforeContext.index(beforeContext.endIndex, offsetBy: -deleteCount)
            let deletedText = String(beforeContext[startIndex...])
            lastDeletedText = deletedText
            deleteManager.addToCurrentDeletion(deletedText)
        }
        
        for _ in 0..<deleteCount {
            textDocumentProxy.deleteBackward()
        }
        
        updatePredictions()
        predictionBar?.showUndo()
    }
    
    private func performUndo() {
        // First try to undo from delete manager's undo stack
        if let undoText = deleteManager.popFromUndoStack() {
            textDocumentProxy.insertText(undoText)
            predictionBar?.hideUndo()
            updatePredictions()
            return
        }
        
        // Fallback to lastDeletedText
        guard !lastDeletedText.isEmpty else { return }
        
        textDocumentProxy.insertText(lastDeletedText)
        lastDeletedText = ""
        
        predictionBar?.hideUndo()
        updatePredictions()
    }
    
    private func toggleShift() {
        let now = Date()
        
        if let lastTap = lastShiftTapTime,
           now.timeIntervalSince(lastTap) < 0.3,
           UserDefaultsManager.shared.enableCapsLock {
            // Double tap - enable caps lock
            isCapsLockEnabled = true
            isShiftEnabled = true
        } else {
            // Single tap - toggle shift
            if isCapsLockEnabled {
                isCapsLockEnabled = false
                isShiftEnabled = false
            } else {
                isShiftEnabled = !isShiftEnabled
            }
        }
        
        lastShiftTapTime = now
        updateKeyboardCase()
    }
    
    private func updateKeyboardCase() {
        let shouldBeUppercase = isShiftEnabled || isCapsLockEnabled
        
        for button in keyButtons {
            if case .character(let primary, let secondary) = button.keyModel.type {
                let baseChar = primary.lowercased()
                let newPrimary = shouldBeUppercase ? baseChar.uppercased() : baseChar
                var updatedKey = button.keyModel
                updatedKey.type = .character(primary: newPrimary, secondary: secondary)
                button.updateKey(updatedKey)
            }
            
            // Highlight shift key if enabled
            if case .special(.shift) = button.keyModel.type {
                if isCapsLockEnabled {
                    button.backgroundColor = UIColor.systemBlue
                } else if isShiftEnabled {
                    button.highlight()
                } else {
                    button.unhighlight()
                }
            }
        }
    }
    
    private func updatePredictions() {
        guard UserDefaultsManager.shared.showPredictions else { return }
        guard let predictionBar = predictionBar else { return }
        
        // Get current word being typed
        if let beforeContext = textDocumentProxy.documentContextBeforeInput {
            let words = beforeContext.components(separatedBy: CharacterSet.whitespacesAndNewlines)
            if let currentWord = words.last, !currentWord.isEmpty {
                let predictions = PredictionEngine.shared.getPredictions(for: currentWord)
                predictionBar.updatePredictions(predictions)
            } else {
                predictionBar.updatePredictions([])
            }
        }
    }
}

// MARK: - KeyButtonDelegate

extension KeyboardViewController: KeyButtonDelegate {
    
    func keyButtonTapped(_ button: KeyButton, key: KeyModel) {
        currentPopupMenu?.dismiss()
        
        switch key.type {
        case .character(let primary, _):
            insertText(primary)
            
        case .number(let num):
            insertText(num)
            
        case .special(let specialType):
            handleSpecialKey(specialType)
            
        case .emoji:
            handleEmojiKey()
        }
    }
    
    func keyButtonLongPressed(_ button: KeyButton, key: KeyModel) {
        // Show popup menu for keys with long press actions
        if let actions = key.longPressActions, UserDefaultsManager.shared.showSecondarySymbols {
            let popup = PopupMenu()
            popup.delegate = self
            popup.show(options: actions, above: button, in: keyboardView)
            currentPopupMenu = popup
        }
        
        // Handle backspace long press
        if case .special(.backspace) = key.type {
            if UserDefaultsManager.shared.enableSmartBackspace {
                deleteManager.startDeleting()
            }
        }
    }
    
    func keyButtonTouchDown(_ button: KeyButton, key: KeyModel) {
        // Handle swipe gestures on backspace
        if case .special(.backspace) = key.type, UserDefaultsManager.shared.enableSwipeGestures {
            swipeGestureManager.touchBegan(at: button.center)
        }
    }
    
    func keyButtonTouchUp(_ button: KeyButton, key: KeyModel) {
        // Stop delete timer
        if case .special(.backspace) = key.type {
            deleteManager.stopDeleting()
            swipeGestureManager.touchEnded()
        }
    }
    
    // Add method to track touch movement
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesMoved(touches, with: event)
        
        guard let touch = touches.first else { return }
        let location = touch.location(in: keyboardView)
        
        // Check if we're tracking backspace swipe
        if UserDefaultsManager.shared.enableSwipeGestures {
            swipeGestureManager.touchMoved(to: location)
        }
    }
    
    private func handleSpecialKey(_ type: SpecialKeyType) {
        switch type {
        case .shift:
            toggleShift()
            
        case .backspace:
            // Single tap backspace - record for individual undo
            if let beforeContext = textDocumentProxy.documentContextBeforeInput,
               !beforeContext.isEmpty {
                let deletedChar = String(beforeContext.last!)
                deleteManager.recordSingleDelete(deletedChar)
            }
            deleteCharacter()
            
        case .space:
            insertText(" ")
            
        case .return:
            insertText("\n")
            
        case .globe:
            advanceToNextInputMode()
            
        case .numberToggle:
            // Toggle to number/symbol mode
            // This would require rebuilding the keyboard layout
            break
            
        case .symbolToggle:
            // Toggle back to alphabet mode
            break
            
        case .dictation:
            // iOS handles dictation automatically
            break
        }
    }
    
    private func handleEmojiKey() {
        // Request emoji keyboard switch
        // The proper way is to use the globe key behavior
        self.advanceToNextInputMode()
    }
}

// MARK: - PredictionBarDelegate

extension KeyboardViewController: PredictionBarDelegate {
    
    func predictionSelected(_ prediction: String) {
        // Delete current word and insert prediction
        guard let beforeContext = textDocumentProxy.documentContextBeforeInput else { return }
        
        let words = beforeContext.components(separatedBy: CharacterSet.whitespacesAndNewlines)
        if let currentWord = words.last, !currentWord.isEmpty {
            for _ in currentWord {
                textDocumentProxy.deleteBackward()
            }
        }
        
        insertText(prediction)
        insertText(" ")
    }
    
    func undoTapped() {
        performUndo()
    }
}

// MARK: - PopupMenuDelegate

extension KeyboardViewController: PopupMenuDelegate {
    
    func popupMenuSelected(_ option: String) {
        insertText(option)
        currentPopupMenu = nil
    }
}

// MARK: - DeleteManagerDelegate

extension KeyboardViewController: DeleteManagerDelegate {
    
    func shouldDeleteCharacter() {
        deleteCharacter()
    }
    
    func shouldDeleteWord() {
        deleteWord()
    }
    
    func shouldDeleteLine() {
        deleteLine()
    }
    
    func didFinishDeleting() {
        // Cleanup after delete operation
    }
}
