//
//  OpenAIHelper.swift
//  face-book
//
//  Created by Henri Lemoine on 2024-01-28.
//

import Foundation
import SwiftOpenAI

enum OpenAIHelperError: Error {
    case apiKeyNotFound
    case invalidApiKey
}

class OpenAIHelper {
    private var apiKey: String
    private var service: OpenAIService

    private init(apiKey: String) {
        self.apiKey = apiKey
        self.service = OpenAIServiceFactory.service(apiKey: apiKey)
    }

    static func create() throws -> OpenAIHelper {
        guard let path = Bundle.main.path(forResource: "Config", ofType: "plist"),
              let dict = NSDictionary(contentsOfFile: path) as? [String: AnyObject],
              let apiKey = dict["OPENAI_API_KEY"] as? String, !apiKey.isEmpty else {
            throw OpenAIHelperError.apiKeyNotFound
        }
        print("Successfully initialized OpenAI Helper.")

        return OpenAIHelper(apiKey: apiKey)
    }
}

extension OpenAIHelper {
    func transcribe(fileURL: URL) async throws -> AudioObject {
        do {
            let data = try Data(contentsOf: fileURL) // Data retrieved from the file URL.
            let parameters = AudioTranscriptionParameters(fileName: fileURL.lastPathComponent, file: data)
            let audioObject = try await service.createTranscription(parameters: parameters)
            return audioObject
        } catch {
            throw error
        }
    }
}

extension OpenAIHelper {
    func sendChatCompletion(prompt: String) async throws -> ChatCompletionObject {
        do {
            let prompt = "You are a name-extraction bot. Read the following transcript carefully. It should contain a conversation between people. Extract the names of the people in the conversation. If no names were said in the conversation, only output \"unknown\"; otherwise, output a list of all names.\nText: " + prompt
            let parameters = ChatCompletionParameters(messages: [.init(role: .user, content: .text(prompt))], model: .gpt41106Preview)
            let chatCompletionObject = try await service.startChat(parameters: parameters)
            return chatCompletionObject
        } catch {
            // Handle or rethrow the error appropriately
            throw error
        }
    }
    
//    func sendChatCompletion(prompt: String) async throws -> ChatCompletionObject {
//        do {
//            let prompt = "You are a name-extraction bot. Read the following transcript carefully. It should contain a conversation between people. Extract the names of the people in the conversation. If no names were said in the conversation, only output \"unknown\"; otherwise, output a list of all names.\nText: " + prompt
//            let parameters = ChatCompletionParameters(messages: [.init(role: .user, content: .text(prompt))], model: .gpt41106Preview)
//            let chatCompletionObject = try await service.startChat(parameters: parameters)
//            return chatCompletionObject
//        } catch {
//            // Handle or rethrow the error appropriately
//            throw error
//        }
//    }
}
