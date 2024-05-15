//
//  File.swift
//  
//
//  Created by 顾艳华 on 2023/9/6.
//

import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif
public class BaseCallbackHandler: LLMManagerMixin, ChainManagerMixin, CallbackManagerMixin, LoaderManagerMixin {
    // Loader
    public func on_loader_start(type: String, metadata: [String : String]) throws {
        
    }
    
    public func on_loader_error(type: String, cause: String, metadata: [String : String]) throws {
        
    }
    
    public func on_loader_end(type: String, metadata: [String : String]) throws {
        
    }
    
    // Agent
    public func on_agent_start(prompt: String, metadata: [String : String]) throws {
        
    }
    
    public func on_llm_error(error: Error, metadata: [String: String]) throws {
        
    }
    
    public func on_llm_start(prompt: String, metadata: [String: String]) throws {
        
    }
    
    // Manage callback
    public func on_chain_start(prompts: String, metadata: [String: String]) throws {
        
    }
    
    // Chain callback
    public func on_chain_end(output: String, metadata: [String: String]) throws {
        
    }
    
    public func on_chain_error(error: Error, metadata: [String: String]) throws {
        
    }
    
    public func on_agent_action(action: AgentAction, metadata: [String: String]) throws {
        
    }
    
    public func on_agent_finish(action: AgentFinish, metadata: [String: String]) throws {
        
    }

    
    // LLM callback
    public func on_llm_new_token(metadata: [String: String]) {
        
    }
    
    public func on_llm_end(output: String, metadata: [String: String]) throws {
        
    }
}
public protocol LoaderManagerMixin {
    func on_loader_start(type: String, metadata: [String: String]) throws
    
    func on_loader_error(type: String, cause: String, metadata: [String: String]) throws
    
    func on_loader_end(type: String, metadata: [String: String]) throws
}
public protocol LLMManagerMixin {
    func on_llm_new_token(metadata: [String: String])
    
    func on_llm_end(output: String, metadata: [String: String]) throws
    
    func on_llm_error(error: Error, metadata: [String: String]) throws
}

public protocol ChainManagerMixin {
    func on_chain_end(output: String, metadata: [String: String]) throws
    
    func on_chain_error(error: Error, metadata: [String: String]) throws
    
    func on_agent_action(action: AgentAction, metadata: [String: String]) throws
    
    func on_agent_finish(action: AgentFinish, metadata: [String: String]) throws
}

public protocol CallbackManagerMixin {
    func on_chain_start(prompts: String, metadata: [String: String]) throws
    
    func on_llm_start(prompt: String, metadata: [String: String]) throws
    
    func on_agent_start(prompt: String, metadata: [String: String]) throws
}
