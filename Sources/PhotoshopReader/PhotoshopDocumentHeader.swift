//
//  PhotoshopDocumentHeader.swift
//  
//
//  Created by Hugh Bellamy on 18/01/2021.
//

import DataStream

/// File Header Section
/// The file header contains the basic properties of the image.
public struct PhotoshopDocumentHeader {
    public let signature: UInt32
    public let version: UInt16
    public let reserved: (UInt8, UInt8, UInt8, UInt8, UInt8, UInt8)
    public let numberOfChannels: UInt16
    public let height: UInt32
    public let width: UInt32
    public let depth: UInt16
    public let colorMode: ColorMode
    
    public var psb: Bool { version != 1 }
    
    public init(dataStream: inout DataStream) throws {
        /// 4 Signature: always equal to '8BPS' . Do not try to read the file if the signature does not match this value.
        self.signature = try dataStream.read(endianess: .bigEndian)
        guard self.signature == 0x38425053 else {
            throw PhotoshopReadError.corrupted
        }
        
        /// 2 Version: always equal to 1. Do not try to read the file if the version does not match this value. (**PSB** version is 2.)
        let version: UInt16 = try dataStream.read(endianess: .bigEndian)
        guard version == 1 || version == 2 else {
            throw PhotoshopReadError.corrupted
        }
        
        self.version = version
        
        /// 6 Reserved: must be zero.
        self.reserved = try dataStream.read(type: type(of: self.reserved))

        /// 2 The number of channels in the image, including any alpha channels. Supported range is 1 to 56.
        let numberOfChannels: UInt16 = try dataStream.read(endianess: .bigEndian)
        guard numberOfChannels >= 1 && numberOfChannels <= 56 else {
            throw PhotoshopReadError.corrupted
        }
        
        self.numberOfChannels = numberOfChannels

        /// 4 The height of the image in pixels. Supported range is 1 to 30,000.
        /// (**PSB** max of 300,000.)
        let height: UInt32 = try dataStream.read(endianess: .bigEndian)
        guard height >= 1 && (height <= 30000 || (version == 1 && height <= 300000)) else {
            throw PhotoshopReadError.corrupted
        }
        
        self.height = height

        /// 4 The width of the image in pixels. Supported range is 1 to 30,000.
        /// (*PSB** max of 300,000)
        let width: UInt32 = try dataStream.read(endianess: .bigEndian)
        guard width >= 1 && (width <= 30000 || (version == 1 && width <= 300000)) else {
            throw PhotoshopReadError.corrupted
        }
        
        self.width = width

        /// 2 Depth: the number of bits per channel. Supported values are 1, 8, 16 and 32.
        let depth: UInt16 = try dataStream.read(endianess: .bigEndian)
        guard depth == 1 || depth == 8 || depth == 16 || depth == 32 else {
            throw PhotoshopReadError.corrupted
        }
        
        self.depth = depth
        
        /// 2 The color mode of the file. Supported values are: Bitmap = 0; Grayscale = 1; Indexed = 2; RGB = 3; CMYK = 4; Multichannel = 7;
        /// Duotone = 8; Lab = 9.
        self.colorMode = try ColorMode(dataStream: &dataStream)
    }
    
    public enum ColorMode: UInt16, DataStreamCreatable {
        case bitmap = 0
        case grayscale = 1
        case indexed = 2
        case rgb = 3
        case cmyk = 4
        case multichannel = 7
        case duotone = 8
        case lab = 9
    }
}
