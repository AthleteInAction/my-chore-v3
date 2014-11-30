import UIKit
import AddressBook

class Contacts {
    
    class func getContacts() -> Array<Contact>? {
        
        if requestAccess() {
            
            return fetchContacts()
            
        } else {
            
            NSLog("ADDRESS BOOK REQUEST DENIED")
            return nil
            
        }
        
    }
    
    private class func requestAccess() -> Bool{
        
        var CLEAN: Bool = true
        
        var addressBook: ABAddressBookRef?
        
        if ABAddressBookGetAuthorizationStatus() == ABAuthorizationStatus.NotDetermined {
            
            ABAddressBookRequestAccessWithCompletion(addressBook,{success, error in
                
                if success {
                    
                    CLEAN = true
                    
                } else {
                    
                    NSLog("ADDRESS BOOK ACCESS ERROR")
                    
                }
                
            })
            
        } else if ABAddressBookGetAuthorizationStatus() == ABAuthorizationStatus.Authorized {
            
            CLEAN = true
            
        }
        
        return true
        
    }
    
    private class func extractABAddressBookRef(abRef: Unmanaged<ABAddressBookRef>!) -> ABAddressBookRef? {
        
        if let ab = abRef {
            
            return Unmanaged<NSObject>.fromOpaque(ab.toOpaque()).takeUnretainedValue()
            
        }
        
        return nil
        
    }
    
    private class func fetchContacts() -> Array<Contact> {
        
        var contacts: [Contact] = []
        
        var errorRef: Unmanaged<CFError>?
        var addressBook: ABAddressBookRef? = extractABAddressBookRef(ABAddressBookCreateWithOptions(nil, &errorRef))
        var contactList: NSArray = ABAddressBookCopyArrayOfAllPeople(addressBook).takeRetainedValue()
        
        for record:ABRecordRef in contactList {
            
            var contactPerson: ABRecordRef = record
            var contactName: String = ABRecordCopyCompositeName(contactPerson).takeRetainedValue() as NSString
            
            var firstNameTemp = ABRecordCopyValue(contactPerson, kABPersonFirstNameProperty)?
            var firstName = ""
            if firstNameTemp != nil {
                firstName = "\(firstNameTemp?.takeRetainedValue() as NSString)"
            }
            
            var lastNameTemp = ABRecordCopyValue(contactPerson, kABPersonLastNameProperty)?
            var lastName = ""
            if lastNameTemp != nil {
                lastName = "\(lastNameTemp?.takeRetainedValue() as NSString)"
            }
            
            var phonesRef: ABMultiValueRef = ABRecordCopyValue(contactPerson, kABPersonPhoneProperty).takeRetainedValue() as ABMultiValueRef
            
            for var i:Int = 0; i < ABMultiValueGetCount(phonesRef); i++ {
                
                var label: String = ABMultiValueCopyLabelAtIndex(phonesRef, i).takeRetainedValue() as NSString
                var value: String = ABMultiValueCopyValueAtIndex(phonesRef, i).takeRetainedValue() as NSString
                
                var phone = value
                phone = phone.stringByReplacingOccurrencesOfString("\\D", withString: "", options: NSStringCompareOptions.RegularExpressionSearch, range: Range(start: phone.startIndex, end: phone.endIndex))
                if countElements(phone) == 10 {
                    phone = "1\(phone)"
                }
                
                var contact = Contact()
                contact.contact_full = contactName
                contact.first_name = firstName
                contact.last_name = lastName
                if firstName != "" {
                    contact.contact_name = firstName
                } else {
                    contact.contact_name = lastName
                }
                contact.phone_number = phone
                
                contacts.append(contact)
                
            }
            
            
        }
        
        return contacts
        
    }
    
}