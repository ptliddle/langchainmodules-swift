//
//  OpenAI.swift
//  
//
//  Created by 顾艳华 on 2023/6/10.
//

import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif
import NIOPosix
import AsyncHTTPClient
import OpenAIKit

enum OpenAIError: Error {
    case noApiKey
}

public class OpenAI: LLM {
    
    let temperature: Double
    let model: ModelID
    
    let apiKey: String?
    let baseUrl: String
    
    
    public init(apiKey: String? = nil, baseUrl: String? = nil, temperature: Double = 0.0, model: ModelID = Model.GPT3.gpt3_5Turbo16K, callbacks: [BaseCallbackHandler] = [], cache: BaseCache? = nil) {
        self.temperature = temperature
        self.model = model
        
        self.apiKey = apiKey ?? {
            let env = Env.loadEnv()
            return env["OPENAI_API_KEY"]
        }()

        self.baseUrl = baseUrl ?? {
            let env = Env.loadEnv()
            return env["OPENAI_API_BASE"] ?? "api.openai.com"
        }()
        
        super.init(callbacks: callbacks, cache: cache)
    }
    
    internal func initiateChat(_ httpClient: HTTPClient) throws -> OpenAIKit.Client {
        guard let apiKey = apiKey else {
            print("Please set openai api key.")
            throw OpenAIError.noApiKey
        }
        
        let configuration = Configuration(apiKey: apiKey, api: API(scheme: .https, host: baseUrl))

        let openAIClient = OpenAIKit.Client(httpClient: httpClient, configuration: configuration)
        
        return openAIClient
    }
    
    public override func _send(text: String, stops: [String] = []) async throws -> LLMResult {
        
        let eventLoopGroup = ThreadManager.thread
        let httpClient = HTTPClient(eventLoopGroupProvider: .shared(eventLoopGroup))
        defer {
            // it's important to shutdown the httpClient after all requests are done, even if one failed. See: https://github.com/swift-server/async-http-client
            try? httpClient.syncShutdown()
        }
        
        let openAIClient = try initiateChat(httpClient)
        
        do {
            let completion = try await openAIClient.chats.create(model: model, messages: [.user(content: text)], temperature: temperature, stops: stops)
            return LLMResult(llm_output: completion.choices.first!.message.content, usage: Usage(completion.usage))
        }
        catch let error as OpenAIKit.APIErrorResponse {
            throw LLMChainError.remote(error.error.message)
        }
        catch {
            throw LLMChainError.remote(error.localizedDescription)
        }
    }
}
