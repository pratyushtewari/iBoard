//
//  ViewController.swift
//  iBoard
//

import UIKit

class ViewController: UIViewController {
    
    private let logoImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "iBoard"
        label.font = UIFont.systemFont(ofSize: 48, weight: .bold)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.text = "GBoard Clone for iOS"
        label.font = UIFont.systemFont(ofSize: 18, weight: .regular)
        label.textColor = .secondaryLabel
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let instructionsTextView: UITextView = {
        let textView = UITextView()
        textView.isEditable = false
        textView.isScrollEnabled = true
        textView.font = UIFont.systemFont(ofSize: 16)
        textView.backgroundColor = UIColor.systemGray6
        textView.layer.cornerRadius = 12
        textView.textContainerInset = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
        textView.translatesAutoresizingMaskIntoConstraints = false
        
        let instructions = """
        Welcome to iBoard! 🎉
        
        To enable the iBoard keyboard:
        
        1. Open the Settings app
        2. Go to General → Keyboard → Keyboards
        3. Tap "Add New Keyboard"
        4. Select "iBoard" from the list
        5. Enable "Allow Full Access" for contact predictions
        
        Features:
        
        ✓ Always visible number row
        ✓ Smart text predictions
        ✓ Secondary symbols on long press
        ✓ Period menu with quick punctuation
        ✓ Caps lock (double-tap shift)
        ✓ Swipe to delete/undo
        ✓ Smart backspace acceleration
        ✓ Contact name/email/phone predictions
        ✓ Voice dictation support
        
        Customize your experience in Settings below!
        """
        
        textView.text = instructions
        return textView
    }()
    
    private let settingsButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("⚙️ Settings", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        button.backgroundColor = .systemBlue
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 12
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let openSettingsButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Open iOS Settings", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        button.backgroundColor = .systemGreen
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 12
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemBackground
        setupUI()
        setupActions()
    }
    
    private func setupUI() {
        view.addSubview(titleLabel)
        view.addSubview(subtitleLabel)
        view.addSubview(instructionsTextView)
        view.addSubview(settingsButton)
        view.addSubview(openSettingsButton)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 40),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            subtitleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            instructionsTextView.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 32),
            instructionsTextView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            instructionsTextView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            instructionsTextView.bottomAnchor.constraint(equalTo: settingsButton.topAnchor, constant: -20),
            
            settingsButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            settingsButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            settingsButton.heightAnchor.constraint(equalToConstant: 54),
            settingsButton.bottomAnchor.constraint(equalTo: openSettingsButton.topAnchor, constant: -12),
            
            openSettingsButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            openSettingsButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            openSettingsButton.heightAnchor.constraint(equalToConstant: 50),
            openSettingsButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20)
        ])
    }
    
    private func setupActions() {
        settingsButton.addTarget(self, action: #selector(openSettings), for: .touchUpInside)
        openSettingsButton.addTarget(self, action: #selector(openIOSSettings), for: .touchUpInside)
    }
    
    @objc private func openSettings() {
        let settingsVC = SettingsViewController()
        let navController = UINavigationController(rootViewController: settingsVC)
        navController.modalPresentationStyle = .pageSheet
        present(navController, animated: true)
    }
    
    @objc private func openIOSSettings() {
        if let url = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(url)
        }
    }
}
