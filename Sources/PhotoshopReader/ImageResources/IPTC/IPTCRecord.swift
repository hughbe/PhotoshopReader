//
//  IPTCRecord.swift
//  
//
//  Created by Hugh Bellamy on 18/01/2021.
//


import DataStream

/// https://www.iptc.org/std/IIM/4.2/specification/IIMV4.2.pdf
public struct IPTCRecord {
    public let tags: [Tag]
    
    public struct Tag {
        public let tagMarker: UInt8
        public let recordNumber: UInt8
        public let datasetNumber: UInt8
        public let size: UInt16
        public let data: [UInt8]
        
        public init(dataStream: inout DataStream) throws {
            guard dataStream.remainingCount >= 5 else {
                throw PhotoshopReadError.corrupted
            }
            
            /// First byte - IPTC Tag Marker - always 28
            self.tagMarker = try dataStream.read()
            guard self.tagMarker == 0x1C else {
                throw PhotoshopReadError.corrupted
            }
            
            /// Second byte - IPTC Record Number
            self.recordNumber = try dataStream.read()

            /// Third byte - IPTC Dataset Number
            self.datasetNumber = try dataStream.read()
            
            /// Fourth and fifth bytes - two byte size value
            self.size = try dataStream.read(endianess: .bigEndian)
            
            guard self.size <= dataStream.remainingCount else {
                throw PhotoshopReadError.corrupted
            }
            
            /// Data
            self.data = try dataStream.readBytes(count: Int(self.size))
        }
    }
    
    public init(dataStream: inout DataStream) throws {
        var tags: [Tag] = []
        while dataStream.remainingCount > 0 {
            tags.append(try Tag(dataStream: &dataStream))
        }
        
        self.tags = tags
    }
}

