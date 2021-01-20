//
//  DataStream+ReadKey.swift
//  
//
//  Created by Hugh Bellamy on 19/01/2021.
//

import DataStream

internal extension DataStream {
    mutating func readKey() throws -> Key {
        let length: UInt32 = try read(endianess: .bigEndian)
        if length == 0 {
            guard remainingCount >= 4 else {
                throw PhotoshopReadError.corrupted
            }

            return .number(try read(endianess: .bigEndian))
        } else {
            guard length <= remainingCount else {
                throw PhotoshopReadError.corrupted
            }

            guard let value = try readString(count: Int(length), encoding: .ascii) else {
                throw PhotoshopReadError.corrupted
            }

            return .string(value)
        }
    }
}

public enum Key {
    case string(_: String)
    case number(_: UInt32)
}
