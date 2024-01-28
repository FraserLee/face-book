//
//  AudioRecorder.swift
//  face-book
//
//  Created by Henri Lemoine on 2024-01-27.
//

import Foundation
import AVFoundation

class AudioRecorder: NSObject, ObservableObject, AVAudioRecorderDelegate {
    @Published var isRecording = false
    var audioRecorder: AVAudioRecorder!
    
    func startRecording() {
        let audioFilename = getRecordingURL()
        
        let settings = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 12000,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]

        do {
            audioRecorder = try AVAudioRecorder(url: audioFilename, settings: settings)
            audioRecorder.delegate = self

            let recordingSession = AVAudioSession.sharedInstance()
            do {
                try recordingSession.setCategory(.playAndRecord, mode: .default)
                try recordingSession.setActive(true)
                // Request permission to record.
                recordingSession.requestRecordPermission() { [unowned self] allowed in
                    DispatchQueue.main.async {
                        if allowed {
                            print("Permission to record granted. Starting recording...")
                            self.audioRecorder?.record()
                        } else {
                            // Handle the case where permission is denied
                            // Print error message
                            print("Permission to record denied.")
                        }
                    }
                }
            } catch {
                // Handle session setup failure
            }
        } catch {
            self.isRecording = false
            finishRecording()
        }
    }

    func finishRecording() {
        // audioRecorder.stop()
        audioRecorder?.stop()
        audioRecorder = nil
        self.isRecording = false
        print("Recording ended")
    }
    
    func toggleRecording() {
        if isRecording {
            finishRecording()
        } else {
            startRecording()
        }
    }

    func getDocumentsDirectory() -> URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
    
    func getRecordingURL() -> URL {
        return getDocumentsDirectory().appendingPathComponent("recording.m4a")
    }

    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        if !flag {
            finishRecording()
        }
    }
}
