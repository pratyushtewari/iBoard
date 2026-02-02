//
//  KeyModel.swift
//  iBoardKeyboard
//

import Foundation
import UIKit

enum KeyType {
    case character(primary: String, secondary: String?)
    case number(String)
    case special(SpecialKeyType)
    case emoji
}

enum SpecialKeyType {
    case shift
    case backspace
    case space
    case `return`
    case globe
    case numberToggle
    case symbolToggle
    case dictation
}

struct KeyModel {
    var type: KeyType
    var frame: CGRect
    var isHighlighted: Bool = false
    var longPressActions: [String]? // For secondary symbols
    var isInputModeSwitcher: Bool = false // For emoji/keyboard switcher
    
    var displayText: String {
        switch type {
        case .character(let primary, _):
            return primary
        case .number(let num):
            return num
        case .special(let specialType):
            switch specialType {
            case .shift: return "⇧"
            case .backspace: return "⌫"
            case .space: return "space"
            case .return: return "return"
            case .globe: return "🌐"
            case .numberToggle: return "?123"
            case .symbolToggle: return "ABC"
            case .dictation: return "🎤"
            }
        case .emoji:
            return "😊"
        }
    }
    
    var secondarySymbol: String? {
        switch type {
        case .character(_, let secondary):
            return secondary
        default:
            return nil
        }
    }
}

struct KeyboardLayout {
    static let qwertyRows: [[KeyModel]] = []
    static let numberRow: [KeyModel] = []
    static let symbolRows: [[KeyModel]] = []
    
    // QWERTY Layout with secondary symbols
    static func createQWERTYLayout(width: CGFloat, isUppercase: Bool = false) -> [[KeyModel]] {
        let keyWidth: CGFloat = (width - 20) / 10
        let keyHeight: CGFloat = 42
        let spacing: CGFloat = 2
        
        // Row 1: Q W E R T Y U I O P
        let row1Characters: [(primary: String, secondary: String?)] = [
            ("q", "1"), ("w", "2"), ("e", "3"), ("r", "4"), ("t", "5"),
            ("y", "6"), ("u", "7"), ("i", "8"), ("o", "9"), ("p", "0")
        ]
        
        // Row 2: A S D F G H J K L
        let row2Characters: [(primary: String, secondary: String?)] = [
            ("a", "@"), ("s", "#"), ("d", "$"), ("f", "%"), ("g", "&"),
            ("h", "*"), ("j", "("), ("k", ")"), ("l", nil)
        ]
        
        // Row 3: Z X C V B N M
        let row3Characters: [(primary: String, secondary: String?)] = [
            ("z", nil), ("x", nil), ("c", nil), ("v", nil),
            ("b", nil), ("n", nil), ("m", nil)
        ]
        
        var rows: [[KeyModel]] = []
        
        // Create Row 1
        var row1: [KeyModel] = []
        for (index, char) in row1Characters.enumerated() {
            let x = CGFloat(index) * (keyWidth + spacing) + 2
            let frame = CGRect(x: x, y: 0, width: keyWidth, height: keyHeight)
            let primary = isUppercase ? char.primary.uppercased() : char.primary
            row1.append(KeyModel(type: .character(primary: primary, secondary: char.secondary), frame: frame))
        }
        rows.append(row1)
        
        // Create Row 2
        var row2: [KeyModel] = []
        let row2Offset: CGFloat = keyWidth * 0.5
        for (index, char) in row2Characters.enumerated() {
            let x = row2Offset + CGFloat(index) * (keyWidth + spacing) + 2
            let frame = CGRect(x: x, y: keyHeight + spacing, width: keyWidth, height: keyHeight)
            let primary = isUppercase ? char.primary.uppercased() : char.primary
            row2.append(KeyModel(type: .character(primary: primary, secondary: char.secondary), frame: frame))
        }
        rows.append(row2)
        
        // Create Row 3 with Shift and Backspace
        var row3: [KeyModel] = []
        let shiftWidth: CGFloat = keyWidth * 1.5
        let backspaceWidth: CGFloat = keyWidth * 1.5
        
        // Shift key
        let shiftFrame = CGRect(x: 2, y: (keyHeight + spacing) * 2, width: shiftWidth, height: keyHeight)
        row3.append(KeyModel(type: .special(.shift), frame: shiftFrame))
        
        // Character keys
        let row3Offset: CGFloat = shiftWidth + spacing + 2
        for (index, char) in row3Characters.enumerated() {
            let x = row3Offset + CGFloat(index) * (keyWidth + spacing)
            let frame = CGRect(x: x, y: (keyHeight + spacing) * 2, width: keyWidth, height: keyHeight)
            let primary = isUppercase ? char.primary.uppercased() : char.primary
            row3.append(KeyModel(type: .character(primary: primary, secondary: char.secondary), frame: frame))
        }
        
        // Backspace key
        let backspaceX = row3Offset + CGFloat(row3Characters.count) * (keyWidth + spacing)
        let backspaceFrame = CGRect(x: backspaceX, y: (keyHeight + spacing) * 2, width: backspaceWidth, height: keyHeight)
        row3.append(KeyModel(type: .special(.backspace), frame: backspaceFrame))
        
        rows.append(row3)
        
        return rows
    }
    
    // Number Row (1-0)
    static func createNumberRow(width: CGFloat, yPosition: CGFloat) -> [KeyModel] {
        let keyWidth: CGFloat = (width - 20) / 10
        let keyHeight: CGFloat = 32
        let spacing: CGFloat = 2
        
        var numberKeys: [KeyModel] = []
        let numbers = ["1", "2", "3", "4", "5", "6", "7", "8", "9", "0"]
        
        for (index, number) in numbers.enumerated() {
            let x = CGFloat(index) * (keyWidth + spacing) + 2
            let frame = CGRect(x: x, y: yPosition, width: keyWidth, height: keyHeight)
            numberKeys.append(KeyModel(type: .number(number), frame: frame))
        }
        
        return numberKeys
    }
    
    // Bottom row with special keys
    static func createBottomRow(width: CGFloat, yPosition: CGFloat) -> [KeyModel] {
        let keyHeight: CGFloat = 42
        let spacing: CGFloat = 4
        
        var bottomRow: [KeyModel] = []
        
        // Number toggle (?123)
        let numberToggleWidth: CGFloat = 60
        let numberToggleFrame = CGRect(x: 2, y: yPosition, width: numberToggleWidth, height: keyHeight)
        bottomRow.append(KeyModel(type: .special(.numberToggle), frame: numberToggleFrame))
        
        // Emoji button
        let emojiWidth: CGFloat = 40
        let emojiX = numberToggleWidth + spacing + 2
        let emojiFrame = CGRect(x: emojiX, y: yPosition, width: emojiWidth, height: keyHeight)
        bottomRow.append(KeyModel(type: .emoji, frame: emojiFrame))
        
        // Globe button
        let globeWidth: CGFloat = 40
        let globeX = emojiX + emojiWidth + spacing
        let globeFrame = CGRect(x: globeX, y: yPosition, width: globeWidth, height: keyHeight)
        bottomRow.append(KeyModel(type: .special(.globe), frame: globeFrame))
        
        // Space bar
        let spaceX = globeX + globeWidth + spacing
        let returnWidth: CGFloat = 80
        let dictationWidth: CGFloat = 40
        let spaceWidth = width - spaceX - returnWidth - dictationWidth - spacing * 3 - 2
        let spaceFrame = CGRect(x: spaceX, y: yPosition, width: spaceWidth, height: keyHeight)
        bottomRow.append(KeyModel(type: .special(.space), frame: spaceFrame))
        
        // Period with long-press menu
        let periodWidth: CGFloat = 40
        let periodX = spaceX + spaceWidth + spacing
        let periodFrame = CGRect(x: periodX, y: yPosition, width: periodWidth, height: keyHeight)
        let periodKey = KeyModel(
            type: .character(primary: ".", secondary: nil),
            frame: periodFrame,
            longPressActions: [".", ",", "?", "!", "'", "\"", "-", "@", "_", ";", "/"]
        )
        bottomRow.append(periodKey)
        
        // Return key
        let returnX = periodX + periodWidth + spacing
        let returnFrame = CGRect(x: returnX, y: yPosition, width: returnWidth, height: keyHeight)
        bottomRow.append(KeyModel(type: .special(.return), frame: returnFrame))
        
        return bottomRow
    }
}
