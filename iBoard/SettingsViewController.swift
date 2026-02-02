//
//  SettingsViewController.swift
//  iBoard
//

import UIKit
import Contacts

class SettingsViewController: UITableViewController {
    
    private var settings: [SettingsSection] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "iBoard Settings"
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .done,
            target: self,
            action: #selector(dismissSettings)
        )
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "SettingCell")
        tableView.register(SwitchTableViewCell.self, forCellReuseIdentifier: "SwitchCell")
        
        loadSettings()
        checkContactsPermission()
    }
    
    private func loadSettings() {
        let userDefaults = UserDefaultsManager.shared
        
        settings = [
            SettingsSection(
                title: "Layout",
                items: [
                    SettingsItem(
                        title: "Show Number Row",
                        description: "Display numbers 1-0 above keyboard",
                        key: .numberRow,
                        isEnabled: userDefaults.showNumberRow
                    ),
                    SettingsItem(
                        title: "Show Secondary Symbols",
                        description: "Display symbols like @ # $ on letter keys",
                        key: .secondarySymbols,
                        isEnabled: userDefaults.showSecondarySymbols
                    )
                ]
            ),
            SettingsSection(
                title: "Predictions",
                items: [
                    SettingsItem(
                        title: "Show Predictions",
                        description: "Display text predictions above keyboard",
                        key: .predictions,
                        isEnabled: userDefaults.showPredictions
                    ),
                    SettingsItem(
                        title: "Contact Predictions",
                        description: "Suggest names, emails, and phone numbers",
                        key: .contactPredictions,
                        isEnabled: userDefaults.enableContactPredictions
                    )
                ]
            ),
            SettingsSection(
                title: "Input",
                items: [
                    SettingsItem(
                        title: "Caps Lock",
                        description: "Double-tap shift for caps lock",
                        key: .capsLock,
                        isEnabled: userDefaults.enableCapsLock
                    ),
                    SettingsItem(
                        title: "Smart Backspace",
                        description: "Hold backspace to accelerate deletion",
                        key: .smartBackspace,
                        isEnabled: userDefaults.enableSmartBackspace
                    ),
                    SettingsItem(
                        title: "Swipe Gestures",
                        description: "Swipe on backspace to delete/undo",
                        key: .swipeGestures,
                        isEnabled: userDefaults.enableSwipeGestures
                    )
                ]
            ),
            SettingsSection(
                title: "Feedback",
                items: [
                    SettingsItem(
                        title: "Haptic Feedback",
                        description: "Vibrate on key press",
                        key: .hapticFeedback,
                        isEnabled: userDefaults.enableHapticFeedback
                    )
                ]
            )
        ]
    }
    
    private func checkContactsPermission() {
        CNContactStore.authorizationStatus(for: .contacts)
    }
    
    @objc private func dismissSettings() {
        dismiss(animated: true)
    }
    
    // MARK: - TableView DataSource
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return settings.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return settings[section].items.count
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return settings[section].title
    }
    
    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        if section == 1 && settings[section].title == "Predictions" {
            return "Contact predictions require 'Allow Full Access' to be enabled in iOS Settings."
        }
        return nil
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SwitchCell", for: indexPath) as! SwitchTableViewCell
        let item = settings[indexPath.section].items[indexPath.row]
        
        cell.configure(with: item)
        cell.switchToggled = { [weak self] isOn in
            self?.handleSettingToggled(item.key, isOn: isOn)
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    // MARK: - Settings Handling
    
    private func handleSettingToggled(_ key: SettingsKey, isOn: Bool) {
        let userDefaults = UserDefaultsManager.shared
        
        switch key {
        case .numberRow:
            userDefaults.showNumberRow = isOn
            
        case .predictions:
            userDefaults.showPredictions = isOn
            
        case .secondarySymbols:
            userDefaults.showSecondarySymbols = isOn
            
        case .capsLock:
            userDefaults.enableCapsLock = isOn
            
        case .swipeGestures:
            userDefaults.enableSwipeGestures = isOn
            
        case .smartBackspace:
            userDefaults.enableSmartBackspace = isOn
            
        case .contactPredictions:
            userDefaults.enableContactPredictions = isOn
            
            if isOn {
                requestContactsPermission()
            }
            
        case .hapticFeedback:
            userDefaults.enableHapticFeedback = isOn
        }
        
        // Show alert that changes will take effect
        showChangesSavedAlert()
    }
    
    private func requestContactsPermission() {
        ContactsManager.shared.requestAccess { granted in
            if granted {
                ContactsManager.shared.fetchContacts()
            } else {
                self.showContactsPermissionAlert()
            }
        }
    }
    
    private func showChangesSavedAlert() {
        let alert = UIAlertController(
            title: "Settings Updated",
            message: "Your changes have been saved and will take effect the next time you use the keyboard.",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    private func showContactsPermissionAlert() {
        let alert = UIAlertController(
            title: "Contacts Permission Required",
            message: "To enable contact predictions, please allow access to contacts in Settings.",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Open Settings", style: .default) { _ in
            if let url = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(url)
            }
        })
        present(alert, animated: true)
    }
}

// MARK: - Custom Switch Cell

class SwitchTableViewCell: UITableViewCell {
    
    var switchToggled: ((Bool) -> Void)?
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        label.textColor = .secondaryLabel
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let toggleSwitch: UISwitch = {
        let toggle = UISwitch()
        toggle.translatesAutoresizingMaskIntoConstraints = false
        return toggle
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        contentView.addSubview(titleLabel)
        contentView.addSubview(descriptionLabel)
        contentView.addSubview(toggleSwitch)
        
        toggleSwitch.addTarget(self, action: #selector(switchValueChanged), for: .valueChanged)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: toggleSwitch.leadingAnchor, constant: -12),
            
            descriptionLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            descriptionLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            descriptionLabel.trailingAnchor.constraint(equalTo: toggleSwitch.leadingAnchor, constant: -12),
            descriptionLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12),
            
            toggleSwitch.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            toggleSwitch.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16)
        ])
    }
    
    func configure(with item: SettingsItem) {
        titleLabel.text = item.title
        descriptionLabel.text = item.description
        toggleSwitch.isOn = item.isEnabled
    }
    
    @objc private func switchValueChanged() {
        switchToggled?(toggleSwitch.isOn)
    }
}
