//
//  PopupMenu.swift
//  iBoardKeyboard
//

import UIKit

protocol PopupMenuDelegate: AnyObject {
    func popupMenuSelected(_ option: String)
}

class PopupMenu: UIView {
    
    weak var delegate: PopupMenuDelegate?
    
    private var options: [String] = []
    private var optionButtons: [UIButton] = []
    private var sourceButton: UIButton?
    
    private let containerStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.distribution = .fillEqually
        stack.spacing = 4
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        backgroundColor = UIColor(white: 0.3, alpha: 0.98)
        layer.cornerRadius = 8
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = CGSize(width: 0, height: 2)
        layer.shadowOpacity = 0.5
        layer.shadowRadius = 8
        
        addSubview(containerStack)
        
        NSLayoutConstraint.activate([
            containerStack.topAnchor.constraint(equalTo: topAnchor, constant: 8),
            containerStack.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8),
            containerStack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8),
            containerStack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8)
        ])
    }
    
    func show(options: [String], above button: UIButton, in view: UIView) {
        self.options = options
        self.sourceButton = button
        
        // Clear previous buttons
        containerStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        optionButtons.removeAll()
        
        // Determine if we need multiple rows (for period key menu)
        let isDoubleRow = options.count > 6
        
        if isDoubleRow {
            // Create two-row layout
            let topRow = UIStackView()
            topRow.axis = .horizontal
            topRow.distribution = .fillEqually
            topRow.spacing = 4
            
            let bottomRow = UIStackView()
            bottomRow.axis = .horizontal
            bottomRow.distribution = .fillEqually
            bottomRow.spacing = 4
            
            containerStack.axis = .vertical
            containerStack.addArrangedSubview(topRow)
            containerStack.addArrangedSubview(bottomRow)
            
            let midPoint = (options.count + 1) / 2
            
            for (index, option) in options.enumerated() {
                let btn = createOptionButton(text: option)
                optionButtons.append(btn)
                
                if index < midPoint {
                    topRow.addArrangedSubview(btn)
                } else {
                    bottomRow.addArrangedSubview(btn)
                }
            }
        } else {
            // Single row layout
            containerStack.axis = .horizontal
            
            for option in options {
                let btn = createOptionButton(text: option)
                optionButtons.append(btn)
                containerStack.addArrangedSubview(btn)
            }
        }
        
        // Calculate size and position
        let buttonWidth: CGFloat = 44
        let buttonHeight: CGFloat = 44
        let padding: CGFloat = 16
        
        let rows = isDoubleRow ? 2 : 1
        let cols = isDoubleRow ? max((options.count + 1) / 2, options.count - (options.count + 1) / 2) : options.count
        
        let width = CGFloat(cols) * buttonWidth + CGFloat(cols - 1) * 4 + padding
        let height = CGFloat(rows) * buttonHeight + CGFloat(rows - 1) * 4 + padding
        
        let buttonFrame = button.convert(button.bounds, to: view)
        let x = max(8, min(view.bounds.width - width - 8, buttonFrame.midX - width / 2))
        let y = buttonFrame.minY - height - 8
        
        frame = CGRect(x: x, y: y, width: width, height: height)
        
        view.addSubview(self)
        
        // Animate appearance
        alpha = 0
        transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        UIView.animate(withDuration: 0.2) {
            self.alpha = 1
            self.transform = .identity
        }
    }
    
    private func createOptionButton(text: String) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle(text, for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 24, weight: .regular)
        button.backgroundColor = UIColor(white: 0.4, alpha: 1.0)
        button.layer.cornerRadius = 5
        button.addTarget(self, action: #selector(optionTapped(_:)), for: .touchUpInside)
        return button
    }
    
    @objc private func optionTapped(_ sender: UIButton) {
        guard let text = sender.title(for: .normal) else { return }
        
        // Animate selection
        UIView.animate(withDuration: 0.1, animations: {
            sender.backgroundColor = UIColor(white: 0.6, alpha: 1.0)
        }) { _ in
            self.delegate?.popupMenuSelected(text)
            self.dismiss()
        }
    }
    
    func dismiss() {
        UIView.animate(withDuration: 0.15, animations: {
            self.alpha = 0
            self.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        }) { _ in
            self.removeFromSuperview()
        }
    }
    
    // Track touch to handle dismissal
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        
        // Check if touch is on a button
        let touchedButton = optionButtons.first { button in
            button.frame.contains(containerStack.convert(location, from: self))
        }
        
        if touchedButton == nil {
            dismiss()
        }
    }
}
