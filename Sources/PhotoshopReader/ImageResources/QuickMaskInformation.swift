//
//  QuickMaskInformation.swift
//  
//
//  Created by Hugh Bellamy on 18/01/2021.
//

import DataStream

/// 0x03FE 1022 Quick Mask information. 2 bytes containing Quick Mask channel ID; 1- byte boolean indicating whether the mask was
/// initially empty.
public struct QuickMaskInformation {
    public let channelID: UInt16
    public let maskInitiallyEmpty: Bool
    
    public init(dataStream: inout DataStream) throws {
        guard dataStream.remainingCount >= 3 else {
            throw PhotoshopReadError.corrupted
        }
        
        self.channelID = try dataStream.read(endianess: .bigEndian)
        self.maskInitiallyEmpty = try dataStream.read() as UInt8 != 0
    }
}
