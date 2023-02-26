//
//  SpectogramController.swift
//  spectogram
//
//  Created by lukluca on 09/12/22.
//

import Foundation

enum SpectrogramError {
    case requiresMicrophoneAccess
    case cantCreateMicrophone
    case viewIsNil
}

final class SpectrogramController {
    
    private var didLayoutSubviewsCalled = false
    
    var view: SpectogramView? {
        didSet {
            if let view = view {
                if view.didLayoutSubviewsCalled {
                    didLayoutSubviewsCalled = true
                }
            }
        }
    }

    /// The audio spectrogram layer.
    private var audioSpectrogram: AudioSpectrogram?
    
    var onError: ((SpectrogramError) -> Void)?
    
    private(set) var frequencies = [Float]()
    private(set) var rawAudioData = [Int16]()
    
    //MARK: Start / Stop
    
    func start(darkMode: Bool) {
        setSpectrogram(darkMode: darkMode)
        
        audioSpectrogram?.didAppendFrequencies = { [weak self] values in
            self?.frequencies.append(contentsOf: values)
        }
        
        audioSpectrogram?.didAppendAudioData = { [weak self] values in
            self?.rawAudioData.append(contentsOf: values)
        }
        
        audioSpectrogram?.startRunning()
    }
    
    func start(darkMode: Bool, rawAudioData: [Int16]) {
        resetSpectrogram()

        setSpectrogram(darkMode: darkMode)
        
        audioSpectrogram?.startRunning(rawAudioData: rawAudioData)
    }
    
    func stop() {
        audioSpectrogram?.stopRunning()
    }
    
    func reset() {
        frequencies.removeAll()
        resetSpectrogram()
    }
    
    private func resetSpectrogram() {
        audioSpectrogram?.removeFromSuperlayer()
    }
    
    private func setSpectrogram(darkMode: Bool) {
        guard audioSpectrogram?.superlayer == nil else {
            return
        }
        
        guard let view = view else {
            DispatchQueue.main.async { [weak self] in
                self?.onError?(.viewIsNil)
            }
            return
        }
        
        let spectogram = AudioSpectrogram(darkMode: darkMode)
        
        audioSpectrogram = spectogram
        bindSpectogram()
        
        spectogram.configure()
        
        view.layer.addSublayer(spectogram)
    }
    
    private func bindSpectogram() {
        audioSpectrogram?.onError = { [weak self] error in
            DispatchQueue.main.async {
                self?.onError?(error)
            }
        }
        
        if let view = view {
            if didLayoutSubviewsCalled {
                audioSpectrogram?.frame = view.frame
            } else {
                view.didLayoutSubviews = { [weak self] in
                    guard let self = self, let view = self.view else {
                        return
                    }
                    self.didLayoutSubviewsCalled = true
                    
                    if let audioSpectrogram = self.audioSpectrogram {
                        audioSpectrogram.frame = view.frame
                    }
                }
            }
        }
    }
}

extension SpectrogramController: Spectrogram {}
