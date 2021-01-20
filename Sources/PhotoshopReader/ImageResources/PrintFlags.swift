//
//  PrintFlags.swift
//  
//
//  Created by Hugh Bellamy on 18/01/2021.
//


import DataStream

/// 0x03F3 1011 Print flags. A series of one-byte boolean values (see Page Setup dialog): labels, crop marks, color bars, registration marks,
/// negative, flip, interpolate, caption, print flags.
public struct PrintFlags {
    public let label: Bool
    public let cropMark: Bool
    public let colorBars: Bool
    public let registrationMarks: Bool
    public let negative: Bool
    public let flip: Bool
    public let interpolate: Bool
    public let caption: Bool?
    public let printFlags: Bool?
    
    public init(dataStream: inout DataStream) throws {
        guard dataStream.remainingCount >= 7 else {
            throw PhotoshopReadError.corrupted
        }
        
        self.label = try dataStream.read() as UInt8 != 0
        self.cropMark = try dataStream.read() as UInt8 != 0
        self.colorBars = try dataStream.read() as UInt8 != 0
        self.registrationMarks = try dataStream.read() as UInt8 != 0
        self.negative = try dataStream.read() as UInt8 != 0
        self.flip = try dataStream.read() as UInt8 != 0
        self.interpolate = try dataStream.read() as UInt8 != 0
        
        if dataStream.remainingCount == 0 {
            self.caption = nil
            self.printFlags = nil
            return
        }
        
        self.caption = try dataStream.read() as UInt8 != 0
        if dataStream.remainingCount == 0 {
            self.printFlags = nil
            return
        }

        self.printFlags = try dataStream.read() as UInt8 != 0
    }
}
