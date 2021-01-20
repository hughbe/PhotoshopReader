//
//  SelectiveColor.swift
//  
//
//  Created by Hugh Bellamy on 19/01/2021.
//

import DataStream

public struct SelectiveColor {
    public let version: UInt16
    public let absoluteMode: UInt16
    public let records: [ColorCorrectionRecord]
    
    public init(dataStream: inout DataStream) throws {
        guard dataStream.remainingCount >= 84 else {
            throw PhotoshopReadError.corrupted
        }
        
        self.version = try dataStream.read(endianess: .bigEndian)
        guard self.version == 1 else {
            throw PhotoshopReadError.corrupted
        }
        
        self.absoluteMode = try dataStream.read(endianess: .bigEndian)
        
        var records: [ColorCorrectionRecord] = []
        records.reserveCapacity(10)
        for _ in 0..<10 {
            records.append(try ColorCorrectionRecord(dataStream: &dataStream))
        }
        
        self.records = records
    }
    
    public struct ColorCorrectionRecord {
        public let cyan: Int16
        public let magenta: Int16
        public let yellow: Int16
        public let black: Int16
        
        public init(dataStream: inout DataStream) throws {
            guard dataStream.remainingCount >= 8 else {
                throw PhotoshopReadError.corrupted
            }
            
            self.cyan = try dataStream.read(endianess: .bigEndian)
            self.magenta = try dataStream.read(endianess: .bigEndian)
            self.yellow = try dataStream.read(endianess: .bigEndian)
            self.black = try dataStream.read(endianess: .bigEndian)
        }
    }
}
