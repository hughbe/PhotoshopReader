//
//  VectorStrokeContent.swift
//  
//
//  Created by Hugh Bellamy on 19/01/2021.
//

import DataStream

/// Vector Stroke Content Data (Photoshop CS6)
/// Key is 'vscg' . Data is as follows:
public struct VectorStrokeContent {
    public let key: UInt32
    public let descriptor: VersionedDescriptor
    
    public init(dataStream: inout DataStream) throws {
        guard dataStream.remainingCount >= 4 else {
            throw PhotoshopReadError.corrupted
        }
        
        /// 4 Key for data
        self.key = try dataStream.read(endianess: .bigEndian)
        
        /// 4 Version ( = 16 )
        /// Variable Descriptor. Based on the Action file format structure (see See Descriptor structure)
        self.descriptor = try VersionedDescriptor(dataStream: &dataStream)
    }
}
