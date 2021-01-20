//
//  ColorLookup.swift
//  
//
//  Created by Hugh Bellamy on 19/01/2021.
//

import DataStream

/// Color Lookup (Photoshop CS6)
/// Key is 'clrL' . Data is as follows:
public struct ColorLookup {
    public let version: UInt16
    public let descriptor: VersionedDescriptor
    
    public init(dataStream: inout DataStream) throws {
        guard dataStream.remainingCount >= 2 else {
            throw PhotoshopReadError.corrupted
        }
        
        /// 2 Version ( = 1)
        self.version = try dataStream.read(endianess: .bigEndian)
        
        /// 4 Descriptor Version ( = 16)
        /// Variable Descriptor of black and white information
        self.descriptor = try VersionedDescriptor(dataStream: &dataStream)
    }
}
