//
//  TypeToolTransform.swift
//  
//
//  Created by Hugh Bellamy on 19/01/2021.
//

import DataStream

/// 6 * 8 Transform: xx, xy, yx, yy, tx, and ty respectively.
public struct TypeToolTransform {
    public let xx: Double
    public let xy: Double
    public let yx: Double
    public let yy: Double
    public let tx: Double
    public let ty: Double
    
    public init(dataStream: inout DataStream) throws {
        guard dataStream.remainingCount >= 48 else {
            throw PhotoshopReadError.corrupted
        }
        
        self.xx = try dataStream.readDouble(endianess: .bigEndian)
        self.xy = try dataStream.readDouble(endianess: .bigEndian)
        self.yx = try dataStream.readDouble(endianess: .bigEndian)
        self.yy = try dataStream.readDouble(endianess: .bigEndian)
        self.tx = try dataStream.readDouble(endianess: .bigEndian)
        self.ty = try dataStream.readDouble(endianess: .bigEndian)
    }
}
