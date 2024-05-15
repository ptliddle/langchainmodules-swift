//
//  File.swift
//  
//
//  Created by 顾艳华 on 2023/6/19.
//

import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

public enum LLMChainError: Error, CustomStringConvertible {
    case remote(String)
    
    public var description: String {
        switch self {
        case .remote(let errorMsg): return errorMsg
        }
    }
}

public class LLMChain: DefaultChain {
    let llm: LLM
    let prompt: PromptTemplate?
    let parser: BaseOutputParser?
    let stop: [String]
    
    public init(llm: LLM, prompt: PromptTemplate? = nil, parser: BaseOutputParser? = nil, stop: [String] = [], memory: BaseMemory? = nil, outputKey: String = "output", inputKey: String = "input", callbacks: [BaseCallbackHandler] = []) {
        self.llm = llm
        self.prompt = prompt
        self.parser = parser
        self.stop = stop
        super.init(memory: memory, outputKey: outputKey, inputKey: inputKey, callbacks: callbacks)
    }
    
    func create_outputs(output: LLMResult?) -> Parsed {
        if let output = output {
            if let parser = self.parser {
                return parser.parse(text: output.llm_output!)
            } else {
                return Parsed.str(output.llm_output!)
            }
        } else {
            return Parsed.error
        }
    }
    
    public override func _call(args: String) async throws -> (LLMResult?, Parsed) {
        // ["\\nObservation: ", "\\n\\tObservation: "]
        
        let llmResult = try await generate(input_list: [inputKey: args])
        
        return (llmResult, create_outputs(output: llmResult))
    }
    
    func prep_prompts(input_list: [String: String]) -> String {
        if let prompt = self.prompt {
            return prompt.format(args: input_list)
        } else {
            return input_list.first!.value
        }
    }
    
    func generate(input_list: [String: String]) async throws -> LLMResult? {
        let input_prompt = prep_prompts(input_list: input_list)
        do {
            //call llm
            let llmResult = try await self.llm.generate(text: input_prompt, stops:  stop)
            try await llmResult?.setOutput()
            return llmResult
        }
        catch let error as LLMChainError {
            print("LLM chain generate \(error.description)")
            throw error
        }
        catch {
            print("LLM chain generate \(error.localizedDescription)")
            throw error
        }
    }
    
    public func apply(input_list: [String: String]) async throws -> Parsed {
        let response = try await generate(input_list: input_list)
        return create_outputs(output: response)
    }
    
    public func plan(input: String, agent_scratchpad: String) async throws -> Parsed {
        return try await apply(input_list: ["question": input, "thought": agent_scratchpad])
    }
    
    public func predictWithUsage(args: [String: String] ) async throws -> LLMResult? {
        let inputAndContext = prep_inputs(inputs: args)
        let outputs = try await self.generate(input_list: inputAndContext)
        if let o = outputs {
            let _ = prep_outputs(inputs: args, outputs: [self.outputKey: o.llm_output!])
            return o
        } else {
            return nil
        }
    }
    
    public func predict(args: [String: String] ) async throws -> String? {
        let inputAndContext = prep_inputs(inputs: args)
        let outputs = try await self.generate(input_list: inputAndContext)
        if let o = outputs {
            let _ = prep_outputs(inputs: args, outputs: [self.outputKey: o.llm_output!])
            return o.llm_output!
        } else {
            return nil
        }
    }
}
