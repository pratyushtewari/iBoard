//
//  ContactsManager.swift
//  iBoardKeyboard
//

import Foundation
import Contacts

class ContactsManager {
    
    static let shared = ContactsManager()
    
    private var cachedNames: [String] = []
    private var cachedEmails: [String] = []
    private var cachedPhones: [String] = []
    private var lastFetchDate: Date?
    
    private init() {}
    
    func requestAccess(completion: @escaping (Bool) -> Void) {
        let store = CNContactStore()
        
        store.requestAccess(for: .contacts) { granted, error in
            DispatchQueue.main.async {
                completion(granted)
            }
        }
    }
    
    func fetchContacts() {
        guard UserDefaultsManager.shared.enableContactPredictions else { return }
        
        // Don't fetch if already fetched in the last hour
        if let lastFetch = lastFetchDate,
           Date().timeIntervalSince(lastFetch) < 3600 {
            return
        }
        
        let store = CNContactStore()
        
        let keysToFetch = [
            CNContactGivenNameKey,
            CNContactFamilyNameKey,
            CNContactEmailAddressesKey,
            CNContactPhoneNumbersKey
        ] as [CNKeyDescriptor]
        
        let request = CNContactFetchRequest(keysToFetch: keysToFetch)
        
        var names: [String] = []
        var emails: [String] = []
        var phones: [String] = []
        
        do {
            try store.enumerateContacts(with: request) { contact, _ in
                // Get full name
                let firstName = contact.givenName
                let lastName = contact.familyName
                
                if !firstName.isEmpty {
                    names.append(firstName)
                }
                
                if !lastName.isEmpty {
                    names.append(lastName)
                }
                
                if !firstName.isEmpty && !lastName.isEmpty {
                    names.append("\(firstName) \(lastName)")
                }
                
                // Get emails
                for emailAddress in contact.emailAddresses {
                    let email = emailAddress.value as String
                    emails.append(email)
                }
                
                // Get phone numbers
                for phoneNumber in contact.phoneNumbers {
                    let phone = phoneNumber.value.stringValue
                    phones.append(phone)
                }
            }
            
            // Update cache
            cachedNames = names
            cachedEmails = emails
            cachedPhones = phones
            lastFetchDate = Date()
            
            // Update prediction engine
            PredictionEngine.shared.updateContacts(
                names: names,
                emails: emails,
                phones: phones
            )
            
        } catch {
            print("Failed to fetch contacts: \(error)")
        }
    }
    
    func getNames() -> [String] {
        return cachedNames
    }
    
    func getEmails() -> [String] {
        return cachedEmails
    }
    
    func getPhones() -> [String] {
        return cachedPhones
    }
    
    func clearCache() {
        cachedNames.removeAll()
        cachedEmails.removeAll()
        cachedPhones.removeAll()
        lastFetchDate = nil
    }
}
