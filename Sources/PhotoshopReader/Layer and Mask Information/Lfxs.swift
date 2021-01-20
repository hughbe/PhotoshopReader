//
//  Lfxs.swift
//  
//
//  Created by Hugh Bellamy on 19/01/2021.
//

import DataStream

public struct Lfxs {
    public let version: UInt32
    public let descriptor: VersionedDescriptor
    
    public init(dataStream: inout DataStream) throws {
        self.version = try dataStream.read(endianess: .bigEndian)
        self.descriptor = try VersionedDescriptor(dataStream: &dataStream)
    }
}
