//
//  SpectogramController.swift
//  spectogram
//
//  Created by lukluca on 09/12/22.
//

import Foundation

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
    
    private(set) var frequencies = [Float]()
    private(set) var rawAudioData = [Int16]()
    
    //MARK: Start / Stop
    
    func start(darkMode: Bool, completion: @escaping SpectogramCompletion) {
        
        audioSpectrogram?.didAppendFrequencies = { [weak self] values in
            self?.frequencies.append(contentsOf: values)
        }
        
        audioSpectrogram?.didAppendAudioData = { [weak self] values in
            self?.rawAudioData.append(contentsOf: values)
        }
        
        setSpectrogram(darkMode: darkMode) { [weak self] error in
            if let error {
                completion(error)
                return
            }
            
            self?.audioSpectrogram?.startRunning()
            completion(nil)
        }
    }
    
    func start(darkMode: Bool, rawAudioData: [Int16]) {
        resetSpectrogram()

        setSpectrogram(darkMode: darkMode) {_ in }
        
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
    
    private func setSpectrogram(darkMode: Bool, completion: @escaping SpectogramCompletion) {
        guard audioSpectrogram?.superlayer == nil else {
            completion(nil)
            return
        }
        
        guard let view = view else {
            DispatchQueue.main.async {
                completion(.viewIsNil)
            }
            return
        }
        
        let spectogram = AudioSpectrogram(darkMode: darkMode)
        
        audioSpectrogram = spectogram
        bindSpectogram()
        
        spectogram.configure { error in
            if let error {
                completion(error)
                return
            }
            
            view.layer.addSublayer(spectogram)
            completion(nil)
            
        }
    }
    
    private func bindSpectogram() {
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
