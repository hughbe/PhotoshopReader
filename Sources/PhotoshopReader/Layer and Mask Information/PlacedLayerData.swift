//
//  PlacedLayerData.swift
//  
//
//  Created by Hugh Bellamy on 19/01/2021.
//

import DataStream

/// Placed Layer Data (Photoshop CS3)
/// Key is 'SoLd' . See also 'PlLd' key. Data is as follows:
public struct PlacedLayerData {
    public let identifier: String
    public let version: UInt32
    public let descriptor: VersionedDescriptor
    
    public init(dataStream: inout DataStream) throws {
        /// 4 Identifier ( = 'soLD' )
        guard let identifier = try dataStream.readString(count: 4, encoding: .ascii) else {
            throw PhotoshopReadError.corrupted
        }
        guard identifier == "soLD" else {
            throw PhotoshopReadError.corrupted
        }
        
        self.identifier = identifier
        
        /// 4 Version ( = 4 )
        self.version = try dataStream.read(endianess: .bigEndian)
        guard self.version == 4 else {
            throw PhotoshopReadError.corrupted
        }

        /// 4 Descriptor Version ( = 16)
        /// Variable Descriptor of placed layer information
        self.descriptor = try VersionedDescriptor(dataStream: &dataStream)
    }
}
