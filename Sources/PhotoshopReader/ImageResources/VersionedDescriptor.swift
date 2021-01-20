//
//  VersionedDescriptor.swift
//  
//
//  Created by Hugh Bellamy on 18/01/2021.
//


import DataStream

public struct VersionedDescriptor {
    public let version: UInt32
    public let descriptor: Descriptor
    
    public init(dataStream: inout DataStream) throws {
        guard dataStream.remainingCount >= 4 else {
            throw PhotoshopReadError.corrupted
        }
        
        let version: UInt32 = try dataStream.read(endianess: .bigEndian)
        guard version == 16 || version == 0 else {
            throw PhotoshopReadError.corrupted
        }
        
        self.version = version
        
        self.descriptor = try Descriptor(dataStream: &dataStream)
    }
}
