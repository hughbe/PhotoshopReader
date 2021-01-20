//
//  PhotoshopDocumentColorModeData.swift
//  
//
//  Created by Hugh Bellamy on 18/01/2021.
//

import DataStream

/// Color Mode Data Section
/// The color mode data section is structured as follows:
/// Only indexed color and duotone (see the mode field in the File header section) have color mode data. For all other modes, this section is just the 4-byte length field, which is set to zero.
/// Indexed color images: length is 768; color data contains the color table for the image, in non-interleaved order.
/// Duotone images: color data contains the duotone specification (the format of which is not documented). Other applications that read
/// Photoshop files can treat a duotone image as a gray image, and just preserve the contents of the duotone information when reading and writing the file.
public struct PhotoshopDocumentColorModeData {
    public let length: UInt32
    public let data: [UInt8]
    
    public init(dataStream: inout DataStream) throws {
        /// 4 The length of the following color data.
        self.length = try dataStream.read(endianess: .bigEndian)
        guard self.length <= dataStream.remainingCount else {
            throw PhotoshopReadError.corrupted
        }
        
        let startPosition = dataStream.position

        /// Variable The color data.
        self.data = try dataStream.readBytes(count: Int(self.length))
        
        guard dataStream.position - startPosition == self.length else {
            throw PhotoshopReadError.corrupted
        }
    }
}

