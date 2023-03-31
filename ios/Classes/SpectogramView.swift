//
//  SpectogramView.swift
//  spectogram
//
//  Created by lukluca on 09/12/22.
//

import Flutter
import UIKit

class SpectogramNativeViewFactory: NSObject, FlutterPlatformViewFactory {
    
    var didCreate: ((SpectogramView) -> Void)?
    
    private var messenger: FlutterBinaryMessenger
    
    init(messenger: FlutterBinaryMessenger) {
        self.messenger = messenger
        super.init()
    }
    
    func create(withFrame frame: CGRect,
                viewIdentifier viewId: Int64,
                arguments args: Any?) -> FlutterPlatformView {
        
        let native = SpectogramNativeView(frame: frame,
                                          viewIdentifier: viewId,
                                          arguments: args,
                                          binaryMessenger: messenger)
        if let view = native.view() as? SpectogramView {
            didCreate?(view)
        }
        
        return native
    }
}

class SpectogramNativeView: NSObject, FlutterPlatformView {
    
    private let _view: SpectogramView
    
    init(
        frame: CGRect,
        viewIdentifier viewId: Int64,
        arguments args: Any?,
        binaryMessenger messenger: FlutterBinaryMessenger?
    ) {
        _view = SpectogramView()
        super.init()
    }
    
    func view() -> UIView {
        return _view
    }
}

class SpectogramView: UIView {
    
    var didLayoutSubviewsCalled = false
    
    var didLayoutSubviews: (() -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        configure()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        configure()
    }
    
    private func configure() {
        backgroundColor = .black
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        didLayoutSubviewsCalled = true
        
        didLayoutSubviews?()
    }
}
