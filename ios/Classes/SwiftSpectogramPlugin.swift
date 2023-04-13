import Flutter
import UIKit

public class SwiftSpectogramPlugin: NSObject, FlutterPlugin {
    
    private lazy var controller: Spectrogram = {
        
        let contro: Spectrogram
        
        #if targetEnvironment(simulator)
        contro = SpectrogramController()
        #else
        contro = SpectrogramController()
        #endif
        
        return contro
    }()
    
    private var hasBlackBackground = true
    
    public static func register(with registrar: FlutterPluginRegistrar) {
                
        let factory = SpectogramNativeViewFactory(messenger: registrar.messenger())
        registrar.register(factory, withId: "SpectogramView")
        
        let channel = FlutterMethodChannel(name: "spectogram", binaryMessenger: registrar.messenger())
        
        let instance = SwiftSpectogramPlugin()
        factory.didCreate = { [weak instance] view in
            instance?.controller.view = view
            instance?.didSetView?()
        }
        
        registrar.addMethodCallDelegate(instance, channel: channel)
    }
    
    public func detachFromEngine(for registrar: FlutterPluginRegistrar) {
        controller.view = nil
        didSetView = nil
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "configureWhiteBackground":
            configureWhiteBackground(result: result)
        case "configureBlackBackground":
            configureBlackBackground(result: result)
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
    
    private func sendIfNotNil(error: SpectogramError?, over result: @escaping FlutterResult) -> Bool {
        if let error {
            send(result: result, error: error)
            return true
        }
        
        return false
    }
    
    private func send(result: @escaping FlutterResult, error: SpectogramError) {
        send(result, make(from: error))
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
    
    private var didSetView: (() -> ())?
    
    private func start(result: @escaping FlutterResult) {
        
        func start() {
            //TODO add to start completion block
            controller.start(darkMode: hasBlackBackground) { [weak self] error in
                guard let self else {
                    return
                }
                if self.sendIfNotNil(error: error, over: result) {
                    return
                }
                
                self.sendNull(result: result)
            }
        }
        
        if controller.view != nil {
            start()
        } else {
            didSetView = {
                start()
            }
        }
    }
    
    private func stop(result: @escaping FlutterResult) {

        controller.stop()
        
        sendNull(result: result)
    }
    
    private func reset(result: @escaping FlutterResult) {
        
        controller.reset()
        
        sendNull(result: result)
    }
    
    private func make(from error: SpectogramError) -> FlutterError {
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
                                message: "There are some developer problems",
                                details: nil)
        }
    }
}
