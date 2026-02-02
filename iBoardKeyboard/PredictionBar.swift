//
//  PredictionBar.swift
//  iBoardKeyboard
//

import UIKit

protocol PredictionBarDelegate: AnyObject {
    func predictionSelected(_ prediction: String)
    func undoTapped()
}

class PredictionBar: UIView {
    
    weak var delegate: PredictionBarDelegate?
    
    private let stackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.distribution = .fillEqually
        stack.spacing = 1
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private let separatorView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(white: 0.3, alpha: 1.0)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private var undoButton: UIButton?
    private var predictions: [String] = []
    private var showingUndo = false
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        backgroundColor = UIColor(white: 0.15, alpha: 1.0)
        
        addSubview(stackView)
        addSubview(separatorView)
        
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: topAnchor),
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            separatorView.leadingAnchor.constraint(equalTo: leadingAnchor),
            separatorView.trailingAnchor.constraint(equalTo: trailingAnchor),
            separatorView.bottomAnchor.constraint(equalTo: bottomAnchor),
            separatorView.heightAnchor.constraint(equalToConstant: 1)
        ])
    }
    
    func updatePredictions(_ newPredictions: [String]) {
        predictions = newPredictions
        showingUndo = false
        rebuildPredictionButtons()
    }
    
    func showUndo() {
        showingUndo = true
        rebuildPredictionButtons()
    }
    
    func hideUndo() {
        showingUndo = false
        rebuildPredictionButtons()
    }
    
    private func rebuildPredictionButtons() {
        // Remove all existing buttons
        stackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        if showingUndo {
            // Show undo button
            let undoBtn = createUndoButton()
            stackView.addArrangedSubview(undoBtn)
            
            // Add empty spacers
            let spacer1 = UIView()
            let spacer2 = UIView()
            stackView.addArrangedSubview(spacer1)
            stackView.addArrangedSubview(spacer2)
        } else {
            // Show predictions (up to 3)
            let predictionsToShow = Array(predictions.prefix(3))
            
            if predictionsToShow.isEmpty {
                // Add empty spacers
                for _ in 0..<3 {
                    stackView.addArrangedSubview(UIView())
                }
            } else {
                for (index, prediction) in predictionsToShow.enumerated() {
                    let button = createPredictionButton(
                        text: prediction,
                        isPrimary: index == 0
                    )
                    stackView.addArrangedSubview(button)
                }
                
                // Fill remaining slots
                let remaining = 3 - predictionsToShow.count
                for _ in 0..<remaining {
                    stackView.addArrangedSubview(UIView())
                }
            }
        }
    }
    
    private func createPredictionButton(text: String, isPrimary: Bool) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle(text, for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = isPrimary ?
            UIFont.systemFont(ofSize: 15, weight: .semibold) :
            UIFont.systemFont(ofSize: 14, weight: .regular)
        button.backgroundColor = UIColor(white: 0.2, alpha: 1.0)
        button.layer.cornerRadius = 4
        button.addTarget(self, action: #selector(predictionTapped(_:)), for: .touchUpInside)
        return button
    }
    
    private func createUndoButton() -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle("⎌ Undo", for: .normal)
        button.setTitleColor(UIColor.systemBlue, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 15, weight: .semibold)
        button.backgroundColor = UIColor(white: 0.25, alpha: 1.0)
        button.layer.cornerRadius = 4
        button.addTarget(self, action: #selector(undoButtonTapped), for: .touchUpInside)
        return button
    }
    
    @objc private func predictionTapped(_ sender: UIButton) {
        guard let text = sender.title(for: .normal) else { return }
        delegate?.predictionSelected(text)
        
        // Animate button press
        UIView.animate(withDuration: 0.1, animations: {
            sender.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
        }) { _ in
            UIView.animate(withDuration: 0.1) {
                sender.transform = .identity
            }
        }
    }
    
    @objc private func undoButtonTapped() {
        delegate?.undoTapped()
        hideUndo()
    }
}
