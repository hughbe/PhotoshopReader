//
//  JumpToXPEP.swift
//  
//
//  Created by Hugh Bellamy on 18/01/2021.
//

import DataStream

/// 0x041C 1052 (Photoshop 6.0) Jump To XPEP. 2 bytes major version, 2 bytes minor version, 4 bytes count. Following is repeated
/// for count: 4 bytes block size, 4 bytes key, if key = 'jtDd' , then next is a Boolean for the dirty flag; otherwise it's a 4 byte entry for
/// the mod date.
public struct JumpToXPEP {
    public let majorVersion: UInt16
    public let minorVersion: UInt16
    public let blocks: [Block]
    
    public init(dataStream: inout DataStream) throws {
        guard dataStream.remainingCount >= 12 else {
            throw PhotoshopReadError.corrupted
        }
        
        self.majorVersion = try dataStream.read(endianess: .bigEndian)
        self.minorVersion = try dataStream.read(endianess: .bigEndian)
        
        let count: UInt32 = try dataStream.read(endianess: .bigEndian)
        var blocks: [Block] = []
        blocks.reserveCapacity(Int(count))
        for _ in 0..<count {
            blocks.append(try Block(dataStream: &dataStream))
        }
        
        self.blocks = blocks
    }
    
    public struct Block {
        public let blockSize: UInt32
        public let key: String
        public let data: Data
        
        public init(dataStream: inout DataStream) throws {
            self.blockSize = try dataStream.read(endianess: .bigEndian)
            guard self.blockSize <= dataStream.remainingCount else {
                throw PhotoshopReadError.corrupted
            }
            
            guard let key = try dataStream.readString(count: 4, encoding: .ascii) else {
                throw PhotoshopReadError.corrupted
            }
            
            self.key = key
            
            if self.key == "jtDd" {
                self.data = .boolean(try dataStream.read() as UInt8 != 0)
            } else {
                self.data = .date(try dataStream.read(endianess: .bigEndian))
            }
        }
        
        public enum Data {
            case boolean(_: Bool)
            case date(_: UInt32)
        }
    }
}
