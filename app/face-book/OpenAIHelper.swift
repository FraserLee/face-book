//
//  OpenAIHelper.swift
//  face-book
//
//  Created by Henri Lemoine on 2024-01-28.
//

//import Foundation
//import OpenAIKit
//
//public let openAI = OpenAIKit(apiToken: apiToken, organization: organizationName)
//
//openAI.sendChatCompletion(newMessage: AIMessage(role: .user, content: prompt), previousMessages: [], model: .gptV3_5(.gptTurbo), maxTokens: 2048, n: 1, completion: { [weak self] result in
//    DispatchQueue.main.async { self?.stopLoading() }
//
//    switch result {
//        case .success(let aiResult):
//            // Handle result actions
//            if let text = aiResult.choices.first?.message?.content {
//                print(text)
//            }
//        case .failure(let error):
//            // Handle error actions
//            print(error.localizedDescription)
//    }
//})
//
//import Speech
//import XCAOpenAIClient
//
//// Get API key
//import SwiftDotenv
//try Dotenv.configure()
//let apiToken: String = Dotenv.OPENAI_API_KEY


// import Foundation
// import XCAOpenAIClient
// import SwiftDotenv


// class OpenAIHelper {

//     private let client: OpenAIClient

//     init() {
//         let apiToken = self.loadAPIToken()
//         self.client = OpenAIClient(apiKey: apiToken)
//     }

//     private func loadAPIToken() -> String {
//         // Implement logic to load API token from .env or other configuration
//         try { Dotenv.configure() }
//         catch {
//             print("no :(")
//         }
//         let apiToken: String = Dotenv.OPENAI_API_KEY
//         return apiToken
//     }
    
//     // ...
// }

// extension OpenAIHelper {
//     func generateAudioTranscription(audioData: Data, fileName: String = "recording.m4a") async throws -> String {
//         do {
//             let transcription = try await client.generateAudioTransciptions(audioData: audioData, fileName: fileName)
//             return transcription
//         } catch {
//             // Handle or rethrow the error appropriately
//             throw error
//         }
//     }
// }

// extension OpenAIHelper {
//     func sendChatCompletion(prompt: String) async throws -> String {
//         do {
//             let completion = try await client.promptChatGPT(prompt: prompt, ...)
//             return completion
//         } catch {
//             // Handle or rethrow the error appropriately
//             throw error
//         }
//     }
// }
