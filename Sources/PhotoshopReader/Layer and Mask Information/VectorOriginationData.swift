//
//  VectorOriginationData.swift
//  
//
//  Created by Hugh Bellamy on 19/01/2021.
//

import DataStream

public struct VectorOriginationData {
    public let version: UInt32
    public let descriptor: VersionedDescriptor
    
    public init(dataStream: inout DataStream) throws {
        guard dataStream.remainingCount >= 4 else {
            throw PhotoshopReadError.corrupted
        }
        
        self.version = try dataStream.read(endianess: .bigEndian)
        guard self.version == 1 else {
            throw PhotoshopReadError.corrupted
        }
        
        self.descriptor = try VersionedDescriptor(dataStream: &dataStream)
    }
}
