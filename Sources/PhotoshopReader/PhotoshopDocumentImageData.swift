//
//  PhotoshopDocumentImageData.swift
//  
//
//  Created by Hugh Bellamy on 19/01/2021.
//

import DataStream

public struct PhotoshopDocumentImageData {
    public let length: UInt32
    public let data: DataStream
    
    public init(dataStream: inout DataStream) throws {
        /// 4 Length of image resource section. The length may be zero.
        let length: UInt32 = try dataStream.read(endianess: .bigEndian)
        self.length = min(length, UInt32(dataStream.remainingCount))
        
        let startPosition = dataStream.position

        /// Variable The image data. Planar order = RRR GGG BBB, etc.
        self.data = DataStream(slicing: dataStream, startIndex: dataStream.position, count: Int(self.length))
        
        dataStream.position += Int(self.length)
        
        guard dataStream.position - startPosition == self.length else {
            throw PhotoshopReadError.corrupted
        }
    }
}
