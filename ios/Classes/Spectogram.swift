//
//  Spectogram.swift
//  spectogram
//
//  Created by lukluca on 26/02/23.
//

import Foundation

enum SpectogramError {
    case requiresMicrophoneAccess
    case cantCreateMicrophone
    case viewIsNil
}

typealias SpectogramCompletion = (SpectogramError?) -> Void

protocol Spectrogram :AnyObject {
    var rawAudioData: [Int16] { get }
    var frequencies: [Float] { get }
    var view: SpectogramView? { get set }
   
    func start(darkMode: Bool, rawAudioData: [Int16])
    func start(darkMode: Bool, completion: @escaping SpectogramCompletion)
    func stop()
    func reset()
}

#if targetEnvironment(simulator)

class SimulatorSpectogramController {
    
    private(set) var frequencies = [Float]()
    private(set) var rawAudioData = [Int16]()
    
    private var timer: Timer?
    
    var view: SpectogramView?
    
    func start(darkMode: Bool, completion: @escaping SpectogramCompletion) {
        stop()
        timer = Timer.scheduledTimer(timeInterval: 0.1,
                                     target: self,
                                     selector: #selector(fireTimer),
                                     userInfo: nil,
                                     repeats: true)
    }
    
    func start(darkMode: Bool, rawAudioData: [Int16]) {
        stop()
        self.rawAudioData = rawAudioData
        timer = Timer.scheduledTimer(timeInterval: 0.1,
                                     target: self,
                                     selector: #selector(fireTimer),
                                     userInfo: nil,
                                     repeats: true)
    }
    
    func reset() {
        frequencies.removeAll()
    }
    
    func stop() {
        timer?.invalidate()
        timer = nil
    }
    
    @objc func fireTimer() {
        frequencies.append(Float.random(min: -10, max: 10))
    }
}

extension SimulatorSpectogramController: Spectrogram {}


private extension Float {

    /// Returns a random floating point number between 0.0 and 1.0, inclusive.
    static var random: Float {
        Float(arc4random()) / Float(0xFFFFFFFF)
    }

    /// Random float between 0 and n-1.
    ///
    /// - Parameter min:  Interval min
    /// - Parameter max:  Interval max
    /// - Returns:      Returns a random float point number between 0 and n max
    static func random(min: Float, max: Float) -> Float {
        Float.random * (max - min) + min
    }
}

#endif
