import Foundation
import CallKit

class CallDirectoryHandler: CXCallDirectoryProvider {
    override func beginRequest(with context: CXCallDirectoryExtensionContext) {
        let userDefaults = UserDefaults(suiteName: "group.com.example.call-blocker")
        let isBlockingEnabled = userDefaults?.bool(forKey: "blocking_enabled") ?? false
        
        if isBlockingEnabled {
            // Add all phone numbers to block
            // You can add specific numbers or patterns here
            context.addBlockingEntry(withNextSequentialPhoneNumber: CXCallDirectoryPhoneNumber(0))
        }
        
        context.completeRequest()
    }
} 