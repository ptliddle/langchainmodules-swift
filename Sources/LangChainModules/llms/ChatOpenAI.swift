//
//  ChatOpenAI.swift
//  
//
//  Created by 顾艳华 on 2023/8/31.
//

import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif
import NIOPosix
import AsyncHTTPClient
import OpenAIKit

public class ChatOpenAI: OpenAI {
    
    let httpClient: HTTPClient
    
    public init(apiKey: String? = nil, baseUrl: String? = nil, httpClient: HTTPClient, temperature: Double = 0.0, model: ModelID = Model.GPT3.gpt3_5Turbo16K, callbacks: [BaseCallbackHandler] = [], cache: BaseCache? = nil) {
        self.httpClient = httpClient
        super.init(apiKey: apiKey, baseUrl: baseUrl, temperature: temperature, model: model, callbacks: callbacks, cache: cache)
    }
    
    public override func _send(text: String, stops: [String] = []) async throws -> LLMResult {

        let openAIClient = try initiateChat(httpClient)
        
        let buffer = try await openAIClient.chats.stream(model: model, messages: [.user(content: text)], temperature: temperature)
        return OpenAIResult(generation: buffer)
    }
}
