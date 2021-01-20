//
//  ChannelInfo.swift
//  
//
//  Created by Hugh Bellamy on 18/01/2021.
//

import DataStream

/// 0x03E8 1000 (Obsolete--Photoshop 2.0 only ) Contains five 2-byte values: number of channels, rows, columns, depth, and mode
public struct ChannelInfo {
    public let numberOfChannels: UInt16
    public let rows: UInt16
    public let columns: UInt16
    public let depth: UInt16
    public let mode: UInt16
    
    public init(dataStream: inout DataStream) throws {
        guard dataStream.remainingCount >= 10 else {
            throw PhotoshopReadError.corrupted
        }
        
        self.numberOfChannels = try dataStream.read(endianess: .bigEndian)
        self.rows = try dataStream.read(endianess: .bigEndian)
        self.columns = try dataStream.read(endianess: .bigEndian)
        self.depth = try dataStream.read(endianess: .bigEndian)
        self.mode = try dataStream.read(endianess: .bigEndian)
    }
}
