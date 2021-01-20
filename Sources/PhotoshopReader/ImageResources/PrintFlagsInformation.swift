//
//  PrintFlagsInformation.swift
//  
//
//  Created by Hugh Bellamy on 18/01/2021.
//


import DataStream

/// 0x2710 10000 Print flags information. 2 bytes version ( = 1), 1 byte center crop marks, 1 byte ( = 0), 4 bytes bleed width value, 2 bytes bleed
/// width scale.
public struct PrintFlagsInformation {
    public let version: UInt16
    public let centerCropMarks: UInt8
    public let reserved: UInt8
    public let bleedWidthValue: UInt32
    public let bleedWidthScale: UInt16
    
    public init(dataStream: inout DataStream) throws {
        guard dataStream.remainingCount >= 10 else {
            throw PhotoshopReadError.corrupted
        }
        
        self.version = try dataStream.read(endianess: .bigEndian)
        guard self.version == 1 else {
            throw PhotoshopReadError.corrupted
        }

        self.centerCropMarks = try dataStream.read()
        self.reserved = try dataStream.read()
        self.bleedWidthValue = try dataStream.read(endianess: .bigEndian)
        self.bleedWidthScale = try dataStream.read(endianess: .bigEndian)
    }
}
