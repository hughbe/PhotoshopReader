//
//  LayerMetadata.swift
//  
//
//  Created by Hugh Bellamy on 19/01/2021.
//

import DataStream

/// Metadata setting (Photoshop 6.0)
/// Key is 'shmd' . Data is as follows:
/// The following is repeated the number of times specified by the count above:
public struct MetadataItem {
    public let signature: String
    public let key: String
    public let copyOnSheetDuplication: Bool
    public let data: [UInt8]
    
    public init(dataStream: inout DataStream) throws {
        guard dataStream.remainingCount >= 12 else {
            throw PhotoshopReadError.corrupted
        }
        
        /// 4 Signature of the data
        guard let signature = try dataStream.readString(count: 4, encoding: .ascii)else {
            throw PhotoshopReadError.corrupted
        }
        
        self.signature = signature
        
        /// 4 Key of the data
        guard let key = try dataStream.readString(count: 4, encoding: .ascii)else {
            throw PhotoshopReadError.corrupted
        }
        
        self.key = key
        
        /// 1 Copy on sheet duplication
        self.copyOnSheetDuplication = try dataStream.read() as UInt8 != 0
        
        /// 3 Padding
        dataStream.position += 3
        
        /// 4 Length of data to follow
        let length: UInt32 = try dataStream.read(endianess: .bigEndian)
        guard length <= dataStream.remainingCount else {
            throw PhotoshopReadError.corrupted
        }
        
        /// Variable Undocumented data
        self.data = try dataStream.readBytes(count: Int(length))
    }
}
