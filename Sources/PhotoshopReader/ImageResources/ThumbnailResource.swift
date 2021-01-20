//
//  ThumbnailResource.swift
//  
//
//  Created by Hugh Bellamy on 18/01/2021.
//

import DataStream

/// Thumbnail resource format
/// Adobe Photoshop (version 5.0 and later) stores thumbnail information for preview display in an image resource block that consists of an initial
/// 28-byte header, followed by a JFIF thumbnail in RGB (red, green, blue) order for both Macintosh and Windows.
/// Adobe Photoshop 4.0 stored the thumbnail information in the same format except the data section is BGR (blue, green, red). The 4.0 format is
/// at resource ID 1033 and the 5.0 format is at resource ID 1036.
public struct ThumbnailResource {
    public let format: Format
    public let width: UInt32
    public let height: UInt32
    public let widthBytes: UInt32
    public let totalSize: UInt32
    public let sizeAfterCompression: UInt32
    public let bitsPerPixel: UInt16
    public let numberOfPlanes: UInt16
    public let data: [UInt8]
    
    public init(dataStream: inout DataStream) throws {
        /// 4 Format. 1 = kJpegRGB . Also supports kRawRGB (0).
        self.format = try Format(dataStream: &dataStream)
        
        /// 4 Width of thumbnail in pixels.
        self.width = try dataStream.read(endianess: .bigEndian)

        /// 4 Height of thumbnail in pixels.
        self.height = try dataStream.read(endianess: .bigEndian)

        /// 4 Widthbytes: Padded row bytes = (width * bits per pixel + 31) / 32 * 4.
        self.widthBytes = try dataStream.read(endianess: .bigEndian)

        /// 4 Total size = widthbytes * height * planes
        self.totalSize = try dataStream.read(endianess: .bigEndian)

        /// 4 Size after compression. Used for consistency check.
        self.sizeAfterCompression = try dataStream.read(endianess: .bigEndian)

        /// 2 Bits per pixel. = 24
        self.bitsPerPixel = try dataStream.read(endianess: .bigEndian)
        guard self.bitsPerPixel == 24 else {
            throw PhotoshopReadError.corrupted
        }
        
        /// 2 Number of planes. = 1
        self.numberOfPlanes = try dataStream.read(endianess: .bigEndian)
        guard self.numberOfPlanes == 1 else {
            throw PhotoshopReadError.corrupted
        }
        
        /// Variable
        /// JFIF data in RGB format.
        /// For resource ID 1033 the data is in BGR format.
        self.data = try dataStream.readBytes(count: Int(self.sizeAfterCompression))
    }
    
    /// 4 Format. 1 = kJpegRGB . Also supports kRawRGB (0).
    public enum Format: UInt32, DataStreamCreatable {
        case jpeg = 1
        case rgb = 0
    }
}
