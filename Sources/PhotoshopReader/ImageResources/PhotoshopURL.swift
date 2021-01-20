//
//  URLList.swift
//  
//
//  Created by Hugh Bellamy on 18/01/2021.
//


import DataStream

/// 0x041E 1054 (Photoshop 6.0) URL List. 4 byte count of URLs, followed by 4 byte long, 4 byte ID, and Unicode string for each count.
public struct PhotoshopURL {
    public let reserved: UInt32
    public let id: UInt32
    public let value: String
    
    public init(dataStream: inout DataStream) throws {
        guard dataStream.remainingCount >= 8 else {
            throw PhotoshopReadError.corrupted
        }
        
        self.reserved = try dataStream.read(endianess: .bigEndian)
        self.id = try dataStream.read(endianess: .bigEndian)
        self.value = try dataStream.readUnicodeString()
    }
}
