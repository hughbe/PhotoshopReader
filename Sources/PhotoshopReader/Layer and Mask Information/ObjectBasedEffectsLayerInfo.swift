//
//  ObjectBasedEffectsLayerInfo.swift
//  
//
//  Created by Hugh Bellamy on 19/01/2021.
//

import DataStream

/// Object-based effects layer info (Photoshop 6.0)
/// Key is 'lfx2' . Data is as follows:
public struct ObjectBasedEffectsLayerInfo {
    public let version: UInt32
    public let descriptor: VersionedDescriptor
    
    public init(dataStream: inout DataStream) throws {
        guard dataStream.remainingCount >= 4 else {
            throw PhotoshopReadError.corrupted
        }
        
        /// 4 Object effects version: 0
        self.version = try dataStream.read(endianess: .bigEndian)
        guard self.version == 0 else {
            throw PhotoshopReadError.corrupted
        }
        
        let startPosition = dataStream.position
        
        /// 4 Descriptor version ( = 16 for Photoshop 6.0).
        /// Variable Descriptor (see See Descriptor structure)
        self.descriptor = try VersionedDescriptor(dataStream: &dataStream)
        
        try dataStream.readFourByteAlignmentPadding(startPosition: startPosition)
    }
}
