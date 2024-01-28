//
//  ContentView.swift
//  face-book
//
//  Created by Fraser Lee on 2024-01-27.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @StateObject var audioRecorder = AudioRecorder()
    let openAIHelper = OpenAIHelper()

    @State private var timer = Timer.publish(every: 20, on: .main, in: .common).autoconnect()

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
            audioRecorder.startRecording()
        }
        .onDisappear {
            audioRecorder.finishRecording()
        }
        .onReceive(timer) { _ in
            Task {
                await runPeriodic()
            }
        }
    }

    private func toggleCam() {
        vc.setupVideoInput()
    }
    
    private func runPeriodic() async {
        let fileURL = audioRecorder.getRecordingURL()
        do {
//            let transcript = try await openAIHelper.transcribe(fileURL: fileURL).text
            let transcript = "This is a test for testing purposes. My name is Bob Gendron."
            print(transcript)

            let completion = try await openAIHelper.sendChatCompletion(prompt: transcript).choices[0].message.content ?? "unknown"
            print(completion)
        } catch {
            print("Error: \(error.localizedDescription)")
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
