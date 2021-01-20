//
//  PhotoFilter.swift
//  
//
//  Created by Hugh Bellamy on 19/01/2021.
//

import DataStream

/// Photo Filter
/// Key is 'phfl' . Data is as follows:
public struct PhotoFilter {
    public let version: UInt16
    public let xyzColor: [UInt32]?
    public let color: Color?
    public let density: UInt32?
    public let preserveLuminosity: Bool
    
    public init(dataStream: inout DataStream) throws {
        guard dataStream.remainingCount >= 17 else {
            throw PhotoshopReadError.corrupted
        }
        
        /// 2 Version ( = 3) or ( = 2 )
        let version: UInt16 = try dataStream.read(endianess: .bigEndian)
        guard version == 3 || version == 2 else {
            throw PhotoshopReadError.corrupted
        }
        self.version = version
        
        /// 12 4 bytes each for XYZ color (Only in Version 3)
        if version == 3 {
            self.xyzColor = [
                try dataStream.read(endianess: .bigEndian),
                try dataStream.read(endianess: .bigEndian),
                try dataStream.read(endianess: .bigEndian)
            ]
        } else {
            self.xyzColor = nil
        }
        
        /// 10 2 bytes color space followed by 4 * 2 bytes color component (Only in Version 2)
        if version == 2 {
            self.color = try Color(dataStream: &dataStream)
        } else {
            self.color = nil
        }
        
        /// 4 Density
        self.density = try dataStream.read(endianess: .bigEndian)
        
        /// 1 Preserve Luminosity
        self.preserveLuminosity = try dataStream.read() as UInt8 != 0
    }
}
