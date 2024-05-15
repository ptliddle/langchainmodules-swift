//
//  LangChainModules.swift
//
//
//  Created by Peter Liddle 15 May 2024
//


import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

enum LangChainError: Error {
    case LoaderError(String)
    case ChainError
    case ToolError
}

