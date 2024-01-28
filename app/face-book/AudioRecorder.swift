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
            audioRecorder.record()
            self.isRecording = true
            print("Recording started")
        } catch {
            self.isRecording = false
            finishRecording()
        }
    }

    func finishRecording() {
        audioRecorder.stop()
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


class AudioPlayer: NSObject, ObservableObject, AVAudioPlayerDelegate {
    var audioPlayer: AVAudioPlayer!

    func playSound(url: URL) {
        do {
            //create your audioPlayer in your parent class as a property
            self.audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer.play()
        } catch {
            print("couldn't load the file")
        }
    }
}
