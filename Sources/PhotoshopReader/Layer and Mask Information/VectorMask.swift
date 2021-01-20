//
//  VectorMask.swift
//  
//
//  Created by Hugh Bellamy on 19/01/2021.
//

import DataStream

/// Vector mask setting (Photoshop 6.0)
/// Key is 'vmsk' or 'vsms'. If key is 'vsms' then we are writing for (Photoshop CS6) and the document will have
/// a 'vscg' key. Data is as follows:
/// Vector mask setting
public struct VectorMask {
    public let version: UInt32
    public let flags: Flags
    public let paths: [PathRecord]
    
    public init(dataStream: inout DataStream) throws {
        guard dataStream.remainingCount >= 8 else {
            throw PhotoshopReadError.corrupted
        }
        
        /// 4 Version ( = 3 for Photoshop 6.0)
        self.version = try dataStream.read(endianess: .bigEndian)
        
        /// 4 Flags. bit 1 = invert, bit 2 = not link, bit 3 = disable
        self.flags = try Flags(dataStream: &dataStream)
        
        /// The rest of the data is path components, loop until end of the length.
        /// Variable Paths. See See Path resource format
        var paths: [PathRecord] = []
        while dataStream.remainingCount >= 26 {
            paths.append(try PathRecord(dataStream: &dataStream))
        }
        
        self.paths = paths
    }
    
    /// 4 Flags. bit 1 = invert, bit 2 = not link, bit 3 = disable
    public struct Flags {
        public let invert: Bool
        public let notLink: Bool
        public let disable: Bool
        public let unused: UInt32
        
        public init(dataStream: inout DataStream) throws {
            var flags: BitFieldReader<UInt32> = try dataStream.readBits(endianess: .bigEndian)
            
            self.invert = flags.readBit()
            self.notLink = flags.readBit()
            self.disable = flags.readBit()
            self.unused = flags.readRemainingBits()
        }
    }
}
