//
//  UserMask.swift
//  
//
//  Created by Hugh Bellamy on 19/01/2021.
//

import DataStream

/// User Mask
/// Key is 'LMsk' . Data is as follows:
public struct UserMask {
    public let color: Color
    public let opacity: UInt16
    public let flag: UInt8
    
    public init(dataStream: inout DataStream) throws {
        guard dataStream.remainingCount >= 13 else {
            throw PhotoshopReadError.corrupted
        }
        
        /// 10 Color space
        self.color = try Color(dataStream: &dataStream)
        
        /// 2 Opacity
        self.opacity = try dataStream.read(endianess: .bigEndian)
        
        /// 1 Flag ( = 128 )
        self.flag = try dataStream.read()
    }
}
