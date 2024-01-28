//
//  ContentView.swift
//  face-book
//
//  Created by Fraser Lee on 2024-01-27.
//

import SwiftUI
import SwiftData

let TIMER_DELAY = 5.0
let FILE_CHECK_DELAY = 1.0

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @StateObject var audioRecorder = AudioRecorder()
    @StateObject var audioPlayer = AudioPlayer()
    
    @State private var isTimerActive = false
    @State private var timer = Timer.publish(every: TIMER_DELAY, on: .main, in: .common).autoconnect()
    @State private var fileCheckTimer = Timer.publish(every: FILE_CHECK_DELAY, on: .main, in: .common).autoconnect()

    @State private var openAIHelper: OpenAIHelper?
    @State private var helperInitializationError: Error?

    var body: some View {
        // rounded rect taking up the top half of the screen with padding
        GeometryReader { geo in
            VStack(spacing:10){
                HostedViewController()
                    .frame(height: geo.size.height * (1/2))
                    .cornerRadius(25.0)

                VStack (alignment: .leading) {
                    HStack (alignment: .top) {
                        Button (action: toggleCam) {
                            Image(systemName: "camera.rotate.fill")
                                .frame(width: 44, height: 44)
                                .foregroundColor(.white)
                                .background(.gray)
                                .cornerRadius(13)
                                .imageScale(.medium)
                        }
                    }
                    .font(.system(size: 25, weight: .regular, design: .rounded))
                    .frame(width: geo.size.width)
                }
                .frame(width: geo.size.width)
                .frame(height: geo.size.height * (1/2))
            }
        }
        .padding(.horizontal)
        .onAppear {
            initializeOpenAIHelper()
            audioRecorder.startRecording()
            DispatchQueue.main.asyncAfter(deadline: .now() + TIMER_DELAY) {
                self.isTimerActive = true
                self.timer = Timer.publish(every: TIMER_DELAY, on: .main, in: .common).autoconnect()
            }
            self.fileCheckTimer = Timer.publish(every: FILE_CHECK_DELAY, on: .main, in: .common).autoconnect()
        }
        .onDisappear {
            audioRecorder.finishRecording()
            self.fileCheckTimer.upstream.connect().cancel()
        }
        .onReceive(timer) { _ in
            if isTimerActive {
                Task {
                    await runPeriodic()
                }
            }
            printFileSize()
        }
    }
    
    private func initializeOpenAIHelper() {
        do {
            openAIHelper = try OpenAIHelper.create()
            // Continue with what you need to do after successful initialization
        } catch {
            helperInitializationError = error
            // Handle the error, possibly show an alert or a message to the user
        }
    }

    private func toggleCam() {
        vc.setupVideoInput()
    }
    
    private func runPeriodic() async {
        let fileURL = audioRecorder.getRecordingURL()
        print(fileURL)

        do {
            guard let helper = openAIHelper else {
                print("OpenAIHelper is not initialized")
                return
            }
            
//            let transcript = try await helper.transcribe(fileURL: fileURL).text
            let transcript = "This is a test for testing purposes. My name is Bob Gendron."
            print(transcript)
            
            let completion = try await helper.sendChatCompletion(prompt: transcript).choices[0].message.content ?? "unknown"
            print(completion)
        } catch {
            print("Error: \(error.localizedDescription)")
        }
    }
    
    private func printFileSize() {
        let fileURL = audioRecorder.getRecordingURL()
        do {
            let attributes = try FileManager.default.attributesOfItem(atPath: fileURL.path)
            if let fileSize = attributes[.size] as? UInt64 {
                print("File size: \(fileSize) bytes")
            }
        } catch {
            print("Error getting file size: \(error.localizedDescription)")
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
