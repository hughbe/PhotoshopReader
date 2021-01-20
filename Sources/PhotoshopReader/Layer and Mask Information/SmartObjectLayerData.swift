//
//  SmartObjectLayerData.swift
//  
//
//  Created by Hugh Bellamy on 19/01/2021.
//

import DataStream

/// Smart Object Layer Data (Photoshop CC 2015)
/// Key is 'SoLE' . Data is as follows:
public struct SmartObjectLayerData {
    public let type: String
    public let version: UInt32
    public let descriptor: VersionedDescriptor
    
    public init(dataStream: inout DataStream) throws {
        guard dataStream.remainingCount >= 8 else {
            throw PhotoshopReadError.corrupted
        }
        
        /// 4 Type ( = 'soLD' )
        guard let type = try dataStream.readString(count: 4, encoding: .ascii) else {
            throw PhotoshopReadError.corrupted
        }
        guard type == "soLD" else {
            throw PhotoshopReadError.corrupted
        }
        
        self.type = type
        
        /// 4 Version ( = 4 or 5 )
        let version: UInt32 = try dataStream.read(endianess: .bigEndian)
        guard version == 4 || version == 5 else {
            throw PhotoshopReadError.corrupted
        }
        
        self.version = version
        
        /// Variable Descriptor. Based on the Action file format structure (see See Descriptor structure)
        self.descriptor = try VersionedDescriptor(dataStream: &dataStream)
    }
}
