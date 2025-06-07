import Flutter
import UIKit
import CallKit
import PushKit

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate, PKPushRegistryDelegate {
  private let callBlocker = CallBlocker()
  private var voipRegistry: PKPushRegistry?
  
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    setupVoIP()
    
    let controller = window?.rootViewController as! FlutterViewController
    let channel = FlutterMethodChannel(
      name: "callblocker.channel",
      binaryMessenger: controller.binaryMessenger
    )
    
    channel.setMethodCallHandler { [weak self] call, result in
      guard let self = self else { return }
      
      switch call.method {
      case "isBlockingEnabled":
        result(self.callBlocker.isBlockingEnabled())
      case "setBlockingEnabled":
        if let args = call.arguments as? [String: Any],
           let enabled = args["enabled"] as? Bool {
          self.callBlocker.setBlockingEnabled(enabled)
          result(nil)
        } else {
          result(FlutterError(
            code: "INVALID_ARGUMENT",
            message: "Enabled state is null",
            details: nil
          ))
        }
      default:
        result(FlutterMethodNotImplemented)
      }
    }
    
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
  
  private func setupVoIP() {
    voipRegistry = PKPushRegistry(queue: .main)
    voipRegistry?.delegate = self
    voipRegistry?.desiredPushTypes = [.voIP]
  }
  
  // MARK: - PKPushRegistryDelegate
  
  func pushRegistry(_ registry: PKPushRegistry, didUpdate credentials: PKPushCredentials, for type: PKPushType) {
    // Handle VoIP push token
  }
  
  func pushRegistry(_ registry: PKPushRegistry, didReceiveIncomingPushWith payload: PKPushPayload, for type: PKPushType, completion: @escaping () -> Void) {
    if let phoneNumber = payload.dictionaryPayload["phone_number"] as? String {
      callBlocker.blockIncomingCall(phoneNumber)
    }
    completion()
  }
}
