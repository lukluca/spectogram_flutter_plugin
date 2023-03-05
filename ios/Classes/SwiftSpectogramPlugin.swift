import Flutter
import UIKit

public class SwiftSpectogramPlugin: NSObject, FlutterPlugin {
    
    private enum ErrorCode: String {
        case controllerIsNil
    }
    
    private lazy var controller: Spectrogram = {
        #if targetEnvironment(simulator)
        return SimulatorSpectogramController()
        #else
        return SpectrogramController()
        #endif
    }()
    
    private var hasBlackBackground = true
    
    private var onError = false
    
    public static func register(with registrar: FlutterPluginRegistrar) {
                
        let factory = SpectogramNativeViewFactory(messenger: registrar.messenger())
        registrar.register(factory, withId: "SpectogramView")
        
        let channel = FlutterMethodChannel(name: "spectogram", binaryMessenger: registrar.messenger())
        let instance = SwiftSpectogramPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "configureWhiteBackground":
            configureWhiteBackground(result: result)
        case "configureBlackBackground":
            configureBlackBackground(result: result)
        case "setWidget":
            setWidget(result: result)
        case "start":
            start(result: result)
        case "stop":
            stop(result: result)
        case "reset":
            reset(result: result)
        default:
            send(result, FlutterMethodNotImplemented)
        }
    }
    
    private func send(_ result: @escaping FlutterResult,
                      _ arguments: Any?) {
        DispatchQueue.main.async {
            result( arguments )
        }
    }
    
    private func sendNull(result: @escaping FlutterResult) {
        send(result, nil)
    }
    
    private func configureWhiteBackground(result: @escaping FlutterResult) {
        hasBlackBackground = false
        sendNull(result: result)
    }
    
    private func configureBlackBackground(result: @escaping FlutterResult) {
        hasBlackBackground = true
        sendNull(result: result)
    }
    
    private func setWidget(result: @escaping FlutterResult) {
        
        if controller.view == nil {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.controller.view = self.getSpectogramView()
                
                if self.controller.view == nil {
                    self.setWidget(result: result)
                    return
                }
                
                self.sendNull(result: result)
            }
        } else {
            sendNull(result: result)
        }
    }
    
    private func getSpectogramView() -> SpectogramView? {
        let window: UIWindow?
        
        if #available(iOS 15.0, *) {
            window = UIApplication
                .shared
                .connectedScenes
                .compactMap { ($0 as? UIWindowScene)?.keyWindow }
                .first
        } else {
            window = UIApplication
                .shared
                .connectedScenes
                .flatMap { ($0 as? UIWindowScene)?.windows ?? [] }
                .first { $0.isKeyWindow }
        }
        
        let topController = UIApplication.topViewController(controller: window?.rootViewController)
        
        return topController?.view.allSubViewsOf(type: SpectogramView.self).first
    }
    
    private func start(result: @escaping FlutterResult) {
       
        controller.start(darkMode: hasBlackBackground)
        
        if onError {
            onError = false
            return
        }
        
        sendNull(result: result)
    }
    
    private func stop(result: @escaping FlutterResult) {
    
        controller.stop()
        
        if onError {
            onError = false
            return
        }
        
        sendNull(result: result)
    }
    
    private func reset(result: @escaping FlutterResult) {
        
        controller.reset()
        
        if onError {
            onError = false
            return
        }
        
        sendNull(result: result)
    }
    
    private func make(from error: SpectrogramError) -> FlutterError {
        switch error {
        case .requiresMicrophoneAccess:
            return FlutterError(code: "requiresMicrophoneAccess",
                                message: "User didn't granted the microphone access?",
                                details: nil)
        case .cantCreateMicrophone:
            return FlutterError(code: "cantCreateMicrophone",
                                message: "Error while creating microphone. Are you on a symulator?",
                                details: nil)
        case .viewIsNil:
            return FlutterError(code: "viewIsNil",
                                message: "Did you miss to call 'setWidget' func?",
                                details: nil)
        }
    }
}


private extension UIApplication {
    class func topViewController(controller: UIViewController?) -> UIViewController? {
        if let navigationController = controller as? UINavigationController {
            return topViewController(controller: navigationController.visibleViewController)
        }
        if let tabController = controller as? UITabBarController {
            if let selected = tabController.selectedViewController {
                return topViewController(controller: selected)
            }
        }
        if let presented = controller?.presentedViewController {
            return topViewController(controller: presented)
        }
        return controller
    }
}

private extension UIView {
    
    /** This is a function to get subViews of a particular type from view recursively. It would look recursively in all subviews and return back the subviews of the type T */
    func allSubViewsOf<T : UIView>(type : T.Type) -> [T]{
        var all = [T]()
        func getSubview(view: UIView) {
            if let aView = view as? T{
                all.append(aView)
            }
            guard view.subviews.count>0 else { return }
            view.subviews.forEach{ getSubview(view: $0) }
        }
        getSubview(view: self)
        return all
    }
}
