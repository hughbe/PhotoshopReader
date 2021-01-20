//
//  VersionInfo.swift
//  
//
//  Created by Hugh Bellamy on 18/01/2021.
//

import DataStream

/// 0x0421 1057 (Photoshop 6.0) Version Info. 4 bytes version, 1 byte hasRealMergedData , Unicode string: writer name, Unicode string:
/// reader name, 4 bytes file version.
public struct VersionInfo {
    public let version: UInt32
    public let hasRealMergedData: Bool
    public let writerName: String
    public let readerName: String
    public let fileVersion: UInt32
    
    public init(dataStream: inout DataStream) throws {
        guard dataStream.remainingCount >= 5 else {
            throw PhotoshopReadError.corrupted
        }
        
        self.version = try dataStream.read(endianess: .bigEndian)
        self.hasRealMergedData = try dataStream.read() as UInt8 != 0
        self.writerName = try dataStream.readUnicodeString()
        self.readerName = try dataStream.readUnicodeString()
        self.fileVersion = try dataStream.read(endianess: .bigEndian)
        
        // Seen padding
        if dataStream.remainingCount == 1 {
            let _: UInt8 = try dataStream.read()
        }
    }
}
