import Foundation
import CallKit
import UserNotifications

@objc class CallBlocker: NSObject, CXCallDirectoryProviderDelegate {
    private let callDirectoryHandler = CXCallDirectoryHandler()
    private let userDefaults = UserDefaults.standard
    private let blockingEnabledKey = "blocking_enabled"
    private var provider: CXProvider?
    private let callController = CXCallController()
    
    override init() {
        super.init()
        setupCallKit()
    }
    
    private func setupCallKit() {
        let providerConfiguration = CXProviderConfiguration()
        providerConfiguration.supportsVideo = false
        providerConfiguration.maximumCallGroups = 1
        providerConfiguration.maximumCallsPerCallGroup = 1
        providerConfiguration.supportedHandleTypes = [.phoneNumber]
        
        provider = CXProvider(configuration: providerConfiguration)
        provider?.setDelegate(self, queue: nil)
    }
    
    @objc func isBlockingEnabled() -> Bool {
        return userDefaults.bool(forKey: blockingEnabledKey)
    }
    
    @objc func setBlockingEnabled(_ enabled: Bool) {
        userDefaults.set(enabled, forKey: blockingEnabledKey)
        reloadExtension()
    }
    
    private func reloadExtension() {
        CXCallDirectoryManager.sharedInstance.reloadExtension(withIdentifier: "com.example.call-blocker.CallDirectoryHandler") { error in
            if let error = error {
                print("Error reloading extension: \(error.localizedDescription)")
            }
        }
    }
    
    @objc func blockIncomingCall(_ phoneNumber: String) {
        guard isBlockingEnabled() else { return }
        
        let handle = CXHandle(type: .phoneNumber, value: phoneNumber)
        let callUpdate = CXCallUpdate()
        callUpdate.remoteHandle = handle
        
        provider?.reportNewIncomingCall(with: UUID(), update: callUpdate) { error in
            if let error = error {
                print("Error reporting call: \(error.localizedDescription)")
                return
            }
            
            // End the call immediately
            let endCallAction = CXEndCallAction(call: UUID())
            let transaction = CXTransaction(action: endCallAction)
            
            self.callController.request(transaction) { error in
                if let error = error {
                    print("Error ending call: \(error.localizedDescription)")
                }
            }
        }
    }
}

extension CallBlocker: CXProviderDelegate {
    func providerDidReset(_ provider: CXProvider) {
        // Handle provider reset
    }
    
    func provider(_ provider: CXProvider, perform action: CXAnswerCallAction) {
        action.fulfill()
    }
    
    func provider(_ provider: CXProvider, perform action: CXEndCallAction) {
        action.fulfill()
    }
} 