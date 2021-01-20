//
//  DataStream+ReadPascalString.swift
//  
//
//  Created by Hugh Bellamy on 18/01/2021.
//

import DataStream

internal extension DataStream {
    mutating func readPascalString() throws -> String {
        guard remainingCount >= 1 else {
            throw PhotoshopReadError.corrupted
        }
        
        let length: UInt8 = try read()
        guard length <= remainingCount else {
            throw PhotoshopReadError.corrupted
        }
        
        guard let value = try readString(count: Int(length), encoding: .ascii) else {
            throw PhotoshopReadError.corrupted
        }
        
        return value
    }
}

