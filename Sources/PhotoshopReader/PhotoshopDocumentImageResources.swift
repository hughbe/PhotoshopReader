//
//  PhotoshopDocumentImageResources.swift
//  
//
//  Created by Hugh Bellamy on 18/01/2021.
//


import DataStream

/// Image Resources Section
/// The third section of the file contains image resources. It starts with a length field, followed by a series of resource blocks.
public struct PhotoshopDocumentImageResources {
    public let length: UInt32
    public let resources: [ImageResourceBlock]
    
    public init(dataStream: inout DataStream) throws {
        /// 4 Length of image resource section. The length may be zero.
        self.length = try dataStream.read(endianess: .bigEndian)
        guard self.length <= dataStream.remainingCount else {
            throw PhotoshopReadError.corrupted
        }
        
        let startPosition = dataStream.position
        
        /// Variable Image resources (Image Resource Blocks ).
        var resources: [ImageResourceBlock] = []
        var resourcesDataStream = DataStream(slicing: dataStream, startIndex: dataStream.position, count: Int(self.length))
        while resourcesDataStream.remainingCount > 0 {
            resources.append(try ImageResourceBlock(dataStream: &resourcesDataStream))
        }
        
        self.resources = resources
        
        dataStream.position += Int(self.length)
        
        guard dataStream.position - startPosition == self.length else {
            throw PhotoshopReadError.corrupted
        }
    }
}
