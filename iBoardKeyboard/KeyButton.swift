//
//  KeyButton.swift
//  iBoardKeyboard
//

import UIKit

protocol KeyButtonDelegate: AnyObject {
    func keyButtonTapped(_ button: KeyButton, key: KeyModel)
    func keyButtonLongPressed(_ button: KeyButton, key: KeyModel)
    func keyButtonTouchDown(_ button: KeyButton, key: KeyModel)
    func keyButtonTouchUp(_ button: KeyButton, key: KeyModel)
}

class KeyButton: UIButton {
    
    weak var delegate: KeyButtonDelegate?
    var keyModel: KeyModel
    
    private var longPressTimer: Timer?
    private var isLongPressing = false
    private let feedbackGenerator = UIImpactFeedbackGenerator(style: .light)
    
    // Secondary symbol label
    private let secondaryLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 10, weight: .regular)
        label.textColor = UIColor.white.withAlphaComponent(0.5)
        label.textAlignment = .left
        return label
    }()
    
    init(key: KeyModel) {
        self.keyModel = key
        super.init(frame: key.frame)
        setupButton()
        setupGestures()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupButton() {
        // Button appearance
        backgroundColor = UIColor(white: 0.2, alpha: 1.0)
        layer.cornerRadius = 5
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = CGSize(width: 0, height: 1)
        layer.shadowOpacity = 0.3
        layer.shadowRadius = 0
        
        setTitle(keyModel.displayText, for: .normal)
        setTitleColor(.white, for: .normal)
        titleLabel?.font = UIFont.systemFont(ofSize: 22, weight: .regular)
        
        // Special styling for certain keys
        switch keyModel.type {
        case .special:
            backgroundColor = UIColor(white: 0.3, alpha: 1.0)
            titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        case .number:
            titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .regular)
        default:
            break
        }
        
        // Add secondary symbol label if exists
        if let secondary = keyModel.secondarySymbol, UserDefaultsManager.shared.showSecondarySymbols {
            addSubview(secondaryLabel)
            secondaryLabel.text = secondary
            secondaryLabel.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                secondaryLabel.topAnchor.constraint(equalTo: topAnchor, constant: 2),
                secondaryLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 4)
            ])
        }
    }
    
    private func setupGestures() {
        addTarget(self, action: #selector(touchDown), for: .touchDown)
        addTarget(self, action: #selector(touchUp), for: [.touchUpInside, .touchUpOutside, .touchCancel])
        addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
        addTarget(self, action: #selector(touchDragExit), for: .touchDragExit)
    }
    
    @objc private func touchDown() {
        if UserDefaultsManager.shared.enableHapticFeedback {
            feedbackGenerator.impactOccurred()
        }
        
        animatePress(isPressed: true)
        delegate?.keyButtonTouchDown(self, key: keyModel)
        
        // Start long press timer for keys with long press actions
        if keyModel.longPressActions != nil || isBackspaceKey() {
            longPressTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false) { [weak self] _ in
                guard let self = self else { return }
                self.isLongPressing = true
                if UserDefaultsManager.shared.enableHapticFeedback {
                    self.feedbackGenerator.impactOccurred()
                }
                self.delegate?.keyButtonLongPressed(self, key: self.keyModel)
            }
        }
    }
    
    @objc private func touchDragExit() {
        // Cancel long press if finger drags out
        longPressTimer?.invalidate()
        longPressTimer = nil
    }
    
    @objc private func touchUp() {
        animatePress(isPressed: false)
        delegate?.keyButtonTouchUp(self, key: keyModel)
        
        longPressTimer?.invalidate()
        longPressTimer = nil
        isLongPressing = false
    }
    
    @objc private func buttonTapped() {
        if !isLongPressing {
            delegate?.keyButtonTapped(self, key: keyModel)
        }
    }
    
    private func animatePress(isPressed: Bool) {
        UIView.animate(withDuration: 0.1) {
            self.transform = isPressed ? CGAffineTransform(scaleX: 0.95, y: 0.95) : .identity
            self.backgroundColor = isPressed ?
                UIColor(white: 0.4, alpha: 1.0) :
                (self.isSpecialKey() ? UIColor(white: 0.3, alpha: 1.0) : UIColor(white: 0.2, alpha: 1.0))
        }
    }
    
    private func isSpecialKey() -> Bool {
        if case .special = keyModel.type {
            return true
        }
        return false
    }
    
    private func isBackspaceKey() -> Bool {
        if case .special(let type) = keyModel.type, type == .backspace {
            return true
        }
        return false
    }
    
    func updateKey(_ key: KeyModel) {
        self.keyModel = key
        setTitle(key.displayText, for: .normal)
        frame = key.frame
        
        // Update secondary label
        if let secondary = key.secondarySymbol, UserDefaultsManager.shared.showSecondarySymbols {
            secondaryLabel.text = secondary
            if secondaryLabel.superview == nil {
                addSubview(secondaryLabel)
                secondaryLabel.translatesAutoresizingMaskIntoConstraints = false
                NSLayoutConstraint.activate([
                    secondaryLabel.topAnchor.constraint(equalTo: topAnchor, constant: 2),
                    secondaryLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 4)
                ])
            }
        } else {
            secondaryLabel.removeFromSuperview()
        }
    }
    
    func highlight() {
        backgroundColor = UIColor(white: 0.5, alpha: 1.0)
    }
    
    func unhighlight() {
        backgroundColor = isSpecialKey() ? UIColor(white: 0.3, alpha: 1.0) : UIColor(white: 0.2, alpha: 1.0)
    }
}
