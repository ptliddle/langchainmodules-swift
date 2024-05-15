//
//  File.swift
//  
//
//  Created by 顾艳华 on 2023/8/31.
//

import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

import OpenAIKit

public struct Usage {
    
    public static let none = Usage(promptTokens: 0, completionTokens: 0, totalTokens: 0)
    
    public let promptTokens: Int
    public let completionTokens: Int
    public let totalTokens: Int
    
    public init(promptTokens: Int, completionTokens: Int, totalTokens: Int) {
        self.promptTokens = promptTokens
        self.completionTokens = completionTokens
        self.totalTokens = totalTokens
    }
}

extension Usage {
    init(_ from: OpenAIKit.Usage) {
        self.init(promptTokens: from.promptTokens, completionTokens: from.completionTokens ?? 0, totalTokens: from.totalTokens)
    }
}

public class LLMResult {
    public init(llm_output: String? = nil, stream: Bool = false, usage: Usage = .none) {
        self.llm_output = llm_output
        self.stream = stream
        self.usage = usage
    }
    
    public var llm_output: String?
    
    public var stream: Bool
    
    public var usage: Usage
    
    public func setOutput() async throws {
        
    }
    public func getGeneration() -> AsyncThrowingStream<String?, Error>? {
        nil
    }
}

public class OpenAIResult: LLMResult {
    public let generation: AsyncThrowingStream<ChatStream, Error>?

    init(generation: AsyncThrowingStream<ChatStream, Error>? = nil, llm_output: String? = nil) {
        self.generation = generation
        super.init(llm_output: llm_output, stream: generation != nil && llm_output == nil)
    }
    
    public override func setOutput() async throws {
        if stream {
            llm_output = ""
            for try await c in generation! {
                if let message = c.choices.first?.delta.content {
                    llm_output! += message
                }
            }
        }
    }
    
    public override func getGeneration() -> AsyncThrowingStream<String?, Error> {
        return AsyncThrowingStream { continuation in    
            Task {
                do {
                    for try await c in generation! {
                        if let message = c.choices.first?.delta.content {
                            continuation.yield(message)
                        }
                    }
                    continuation.finish()
                } catch {
                    continuation.finish(throwing: error)
                }
            }
            
        }
    }
}
