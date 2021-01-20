//
//  DataStream+ReadUnicodeString.swift
//
//
//  Created by Hugh Bellamy on 18/01/2021.
//

import DataStream

internal extension DataStream {
    /// All values defined as Unicode string consist of:
    /// A 4-byte length field, representing the number of UTF-16 code units in the string (not bytes).
    /// The string of Unicode values, two bytes per character and a two byte null for the end of the string.
    mutating func readUnicodeString() throws -> String {
        guard remainingCount >= 1 else {
            throw PhotoshopReadError.corrupted
        }
        
        let length: UInt32 = try read(endianess: .bigEndian)
        guard length * 2 <= remainingCount else {
            throw PhotoshopReadError.corrupted
        }
        
        if length == 0 {
            return ""
        } else {
            guard let value = try readString(count: Int(length) * 2, encoding: .utf16BigEndian) else {
                throw PhotoshopReadError.corrupted
            }
            
            return value.trimmingCharacters(in: ["\0"])
        }
    }
}

