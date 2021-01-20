//
//  Exposure.swift
//  
//
//  Created by Hugh Bellamy on 19/01/2021.
//

import DataStream

/// Exposure
/// Key is 'expA' .
public struct Exposure {
    public let version: UInt16
    public let exposure: UInt32
    public let offset: UInt32
    public let gamma: UInt32
    
    public init(dataStream: inout DataStream) throws {
        guard dataStream.remainingCount >= 14 else {
            throw PhotoshopReadError.corrupted
        }
        
        /// 2 Version (= 1)
        self.version = try dataStream.read(endianess: .bigEndian)
        guard self.version == 1 else {
            throw PhotoshopReadError.corrupted
        }
        
        /// 4 Exposure
        self.exposure = try dataStream.read(endianess: .bigEndian)
        
        /// 4 Offset
        self.offset = try dataStream.read(endianess: .bigEndian)
        
        /// 4 Gamma
        self.gamma = try dataStream.read(endianess: .bigEndian)
    }
}
