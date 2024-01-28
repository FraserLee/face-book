//
//  ContentView.swift
//  face-book
//
//  Created by Fraser Lee on 2024-01-27.
//

import SwiftUI
import SwiftData

let TIMER_DELAY = 8.0
var personView: UIImageView! = nil

let DISPLAY_PORT_SIZE = 140.0

struct PersonView: UIViewRepresentable{
    var image: UIImage

    func makeUIView(context: Context) -> UIView {
        let mainView: UIView = UIView()
        let imageView: UIImageView = UIImageView()
        imageView.image = image
        imageView.frame.size.width = DISPLAY_PORT_SIZE
        imageView.frame.size.height = DISPLAY_PORT_SIZE
        imageView.contentMode = .scaleAspectFill
        mainView.addSubview(imageView)
        personView = imageView
        return mainView
    }

    func updateUIView(_ uiView: UIView, context: Context) {
    }
}


var outputDisplay = UIView()

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @StateObject var audioRecorder = AudioRecorder()
    
    @State private var isTimerActive = false
    @State private var timer = Timer.publish(every: TIMER_DELAY, on: .main, in: .common).autoconnect()

    @State private var openAIHelper: OpenAIHelper?
    @State private var helperInitializationError: Error?

    var body: some View {
        // rounded rect taking up the top half of the screen with padding
        GeometryReader { geo in
            VStack(spacing:10){
                
                GeometryReader{ geo1 in
                    VStack (alignment: .trailing) {

                        HStack {
                            VStack{
                                Text("name goes here.")
                                    .font(.system(size: 25, weight: .regular, design: .rounded))

                                PersonView(image: UIImage(systemName: "faceid")!)
                                    .frame(width: DISPLAY_PORT_SIZE, height: DISPLAY_PORT_SIZE)
                                    .cornerRadius(15)
                                
                            }.frame(width: geo.size.width)
                        }
                        
                        HStack (alignment: .bottom) {

                            Button (action: toggleCam) {
                                Image(systemName: "camera.rotate.fill")
                                    .frame(width: 44, height: 44)
                                    .foregroundColor(.white)
                                    .background(.gray)
                                    .cornerRadius(13)
                                    .imageScale(.medium)
                            }
                            
                        }

                    }.frame(width: geo.size.width, height: geo.size.height * (1/2))
                }.frame(height: geo.size.height * (1/2))
                
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
        }
        .onDisappear {
            audioRecorder.finishRecording()
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
            
            let transcript = try await helper.transcribe(fileURL: fileURL).text
//            let transcript = "This is a test for testing purposes. My name is Bob Gendron."
            print(transcript)
            
            let name = try await helper.getName(prompt: transcript).choices[0].message.content ?? "unknown"
            let info = try await helper.getInfo(prompt: transcript).choices[0].message.content ?? "unknown"

            print(name)
            print(info)
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
