//
//  DisplayInfoObsolete.swift
//
//
//  Created by Hugh Bellamy on 18/01/2021.
//

import DataStream

/// DisplayInfo
/// This structure contains display information about each channel. It is written as an image resource. See the Document file formats
/// chapter for more details.
public struct DisplayInfoObsolete {
    public let colorSpace: UInt16
    public let colorData1: UInt16
    public let colorData2: UInt16
    public let colorData3: UInt16
    public let colorData4: UInt16
    public let opacity: Int16
    public let kind: Kind
    public let padding: UInt8
    
    public init(dataStream: inout DataStream) throws {
        guard dataStream.remainingCount >= 14 else {
            throw PhotoshopReadError.corrupted
        }
        
        self.colorSpace = try dataStream.read(endianess: .bigEndian)
        self.colorData1 = try dataStream.read(endianess: .bigEndian)
        self.colorData2 = try dataStream.read(endianess: .bigEndian)
        self.colorData3 = try dataStream.read(endianess: .bigEndian)
        self.colorData4 = try dataStream.read(endianess: .bigEndian)
                
        let opacity: Int16 = try dataStream.read(endianess: .bigEndian)
        guard opacity >= 0 && opacity <= 100 else {
            throw PhotoshopReadError.corrupted
        }
        
        self.opacity = opacity
        self.kind = try Kind(dataStream: &dataStream)
        self.padding = try dataStream.read()
    }
    
    public enum Kind: UInt8, DataStreamCreatable {
        case selected = 0
        case protected = 1
        case unknown2 = 2
    }
}
