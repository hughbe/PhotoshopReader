//
//  AlternateSpotColors.swift
//  
//
//  Created by Hugh Bellamy on 18/01/2021.
//

import DataStream

/// 0x042B 1067 (Photoshop CS)Alternate Spot Colors. 2 bytes (version = 1), 2 bytes channel count, following is repeated for each count:
/// 4 bytes channel ID, Color: 2 bytes for space followed by 4 * 2 byte color component. This resource is not read or used by Photoshop.
public struct AlternateSpotColors {
    public let version: UInt16
    public let channels: [Channel]
    
    public init(dataStream: inout DataStream) throws {
        guard dataStream.remainingCount >= 4 else {
            throw PhotoshopReadError.corrupted
        }

        self.version = try dataStream.read(endianess: .bigEndian)
        
        let count: UInt16 = try dataStream.read(endianess: .bigEndian)
        guard count * 14 <= dataStream.remainingCount else {
            throw PhotoshopReadError.corrupted
        }
        
        var channels: [Channel] = []
        channels.reserveCapacity(Int(count))
        for _ in 0..<count {
            channels.append(try Channel(dataStream: &dataStream))
        }
        
        self.channels = channels
    }
    
    public struct Channel {
        public let channelID: UInt32
        public let color: Color
        
        public init(dataStream: inout DataStream) throws {
            self.channelID = try dataStream.read(endianess: .bigEndian)
            self.color = try Color(dataStream: &dataStream)
        }
    }
}
