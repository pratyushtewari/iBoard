//
//  DeleteManager.swift
//  iBoardKeyboard
//

import UIKit

protocol DeleteManagerDelegate: AnyObject {
    func shouldDeleteCharacter()
    func shouldDeleteWord()
    func shouldDeleteLine()
    func didFinishDeleting()
}

class DeleteManager {
    
    weak var delegate: DeleteManagerDelegate?
    
    private var deleteTimer: Timer?
    private var deleteCount = 0
    private var isDeleting = false
    private var deleteStartTime: Date?
    
    // Track current deletion session
    private var currentDeletionBuffer: String = ""
    
    // Undo stack
    private var undoStack: [String] = []
    private let maxUndoStackSize = 50
    
    // Thresholds for acceleration
    private let characterDeleteInterval: TimeInterval = 0.1
    private let wordDeleteThreshold: TimeInterval = 1.5
    private let lineDeleteThreshold: TimeInterval = 3.0
    
    func startDeleting() {
        isDeleting = true
        deleteStartTime = Date()
        deleteCount = 0
        currentDeletionBuffer = "" // Start new deletion session
        
        // Initial delete
        delegate?.shouldDeleteCharacter()
        deleteCount += 1
        
        // Start repeating timer
        deleteTimer = Timer.scheduledTimer(withTimeInterval: characterDeleteInterval, repeats: true) { [weak self] _ in
            self?.handleDeleteTick()
        }
    }
    
    func stopDeleting() {
        isDeleting = false
        deleteTimer?.invalidate()
        deleteTimer = nil
        deleteStartTime = nil
        deleteCount = 0
        
        // Save the deletion buffer to undo stack
        if !currentDeletionBuffer.isEmpty {
            pushToUndoStack(currentDeletionBuffer)
            currentDeletionBuffer = ""
        }
        
        delegate?.didFinishDeleting()
    }
    
    private func handleDeleteTick() {
        guard let startTime = deleteStartTime else { return }
        
        let elapsedTime = Date().timeIntervalSince(startTime)
        
        if elapsedTime > lineDeleteThreshold {
            // Delete entire lines
            delegate?.shouldDeleteLine()
        } else if elapsedTime > wordDeleteThreshold {
            // Delete words
            delegate?.shouldDeleteWord()
        } else {
            // Delete characters
            delegate?.shouldDeleteCharacter()
        }
        
        deleteCount += 1
    }
    
    // MARK: - Single Character Delete
    
    func recordSingleDelete(_ deletedChar: String) {
        // For single tap deletes, add to undo stack immediately
        pushToUndoStack(deletedChar)
    }
    
    // MARK: - Track deleted text during session
    
    func addToCurrentDeletion(_ text: String) {
        currentDeletionBuffer = text + currentDeletionBuffer
    }
    
    func getCurrentDeletionBuffer() -> String {
        return currentDeletionBuffer
    }
    
    func clearCurrentDeletionBuffer() {
        currentDeletionBuffer = ""
    }
    
    // MARK: - Undo Management
    
    func pushToUndoStack(_ text: String) {
        guard !text.isEmpty else { return }
        undoStack.append(text)
        
        // Maintain stack size
        if undoStack.count > maxUndoStackSize {
            undoStack.removeFirst()
        }
    }
    
    func popFromUndoStack() -> String? {
        guard !undoStack.isEmpty else { return nil }
        return undoStack.removeLast()
    }
    
    func clearUndoStack() {
        undoStack.removeAll()
    }
    
    func hasUndoHistory() -> Bool {
        return !undoStack.isEmpty
    }
}

// MARK: - Swipe Gesture Manager

class SwipeGestureManager {
    
    enum SwipeDirection {
        case left   // Delete
        case right  // Undo
        case down   // Undo
    }
    
    var onSwipe: ((SwipeDirection) -> Void)?
    
    private var initialTouchPoint: CGPoint?
    private let swipeThreshold: CGFloat = 20
    private var hasTriggeredSwipe = false
    
    func touchBegan(at point: CGPoint) {
        initialTouchPoint = point
        hasTriggeredSwipe = false
    }
    
    func touchMoved(to point: CGPoint) {
        guard let initial = initialTouchPoint else { return }
        guard !hasTriggeredSwipe else { return }
        
        let deltaX = point.x - initial.x
        let deltaY = point.y - initial.y
        
        // Determine if horizontal or vertical swipe
        if abs(deltaX) > abs(deltaY) {
            // Horizontal swipe
            if abs(deltaX) > swipeThreshold {
                if deltaX < 0 {
                    // Swipe left - delete (continuous)
                    onSwipe?(.left)
                    initialTouchPoint = point // Reset for continuous swiping
                } else {
                    // Swipe right - undo
                    onSwipe?(.right)
                    hasTriggeredSwipe = true
                    initialTouchPoint = nil
                }
            }
        } else {
            // Vertical swipe
            if deltaY > swipeThreshold {
                // Swipe down - undo
                onSwipe?(.down)
                hasTriggeredSwipe = true
                initialTouchPoint = nil
            }
        }
    }
    
    func touchEnded() {
        initialTouchPoint = nil
        hasTriggeredSwipe = false
    }
}
