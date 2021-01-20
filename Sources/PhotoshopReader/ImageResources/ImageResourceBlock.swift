//
//  ImageResourceBlock.swift
//  
//
//  Created by Hugh Bellamy on 18/01/2021.
//

import DataStream
import Foundation

/// Image Resource Blocks
/// Image resource blocks are the basic building unit of several file formats, including Photoshop's native file format, JPEG, and TIFF. Image
/// resources are used to store non-pixel data associated with images, such as pen tool paths.
/// They are referred to as resource blocks because they hold data that was stored in the Macintosh's resource fork in early versions of
/// Photoshop.
/// The basic structure of image resource blocks is shown in the Image resource block. The last field is the data area, which varies by
/// resource type. The makeup of each resource type is described in the following sections.
public struct ImageResourceBlock {
    public let signature: String
    public let id: UInt16
    public let name: String
    public let data: DataStream
    
    public init(dataStream: inout DataStream) throws {
        let startPosition = dataStream.position
        guard dataStream.remainingCount >= 10 else {
            throw PhotoshopReadError.corrupted
        }

        /// 4 Signature: '8BIM'
        guard let signature = try dataStream.readString(count: 4, encoding: .ascii) else {
            throw PhotoshopReadError.corrupted
        }
        guard signature == "8BIM" || signature == "MeSa" || signature == "PHUT" || signature == "AgHg" || signature == "DCSR" else {
            throw PhotoshopReadError.corrupted
        }
        
        self.signature = signature
        
        /// 2 Unique identifier for the resource. Image resource IDs contains a list of resource IDs used by Photoshop.
        self.id = try dataStream.read(endianess: .bigEndian)
        
        /// Variable Name: Pascal string, padded to make the size even (a null name consists of two bytes of 0)
        self.name = try dataStream.readPascalString()
        try dataStream.readTwoByteAlignmentPadding(startPosition: startPosition)
        
        /// 4 Actual size of resource data that follows
        let size: UInt32 = try dataStream.read(endianess: .bigEndian)
        guard size <= dataStream.remainingCount else {
            throw PhotoshopReadError.corrupted
        }
        
        /// Variable The resource data, described in the sections on the individual resource types. It is padded to make the size even.
        self.data = DataStream(slicing: dataStream, startIndex: dataStream.position, count: Int(size))
        dataStream.position += Int(size)
        try dataStream.readTwoByteAlignmentPadding(startPosition: startPosition)
    }
}
