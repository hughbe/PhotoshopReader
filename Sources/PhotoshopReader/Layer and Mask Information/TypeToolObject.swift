//
//  TypeToolObject.swift
//  
//
//  Created by Hugh Bellamy on 19/01/2021.
//

import DataStream

/// Type tool object setting (Photoshop 6.0)
/// This supersedes the type tool info in Photoshop 5.0 (see See Type tool Info).
/// Key is 'TySh' . Data is as follows:
public struct TypeToolObject {
    public let version: UInt16
    public let transform: TypeToolTransform
    public let textVersion: UInt16
    public let textDescriptor: VersionedDescriptor
    public let warpVersion: UInt16
    public let warpDescriptor: VersionedDescriptor
    public let left: Int32
    public let top: Int32
    public let right: Int32
    public let bottom: Int32
    
    public init(dataStream: inout DataStream) throws {
        /// 2 Version ( =1 for Photoshop 6.0)
        self.version = try dataStream.read(endianess: .bigEndian)
        guard self.version == 1 else {
            throw PhotoshopReadError.corrupted
        }
        
        /// 6 * 8 Transform: xx, xy, yx, yy, tx, and ty respectively.
        self.transform = try TypeToolTransform(dataStream: &dataStream)
        
        /// 2 Text version ( = 50 for Photoshop 6.0)
        self.textVersion = try dataStream.read(endianess: .bigEndian)
        guard self.textVersion == 50 else {
            throw PhotoshopReadError.corrupted
        }
        
        /// 4 Descriptor version ( = 16 for Photoshop 6.0)
        /// Variable Text data (see See Descriptor structure)
        self.textDescriptor = try VersionedDescriptor(dataStream: &dataStream)
        
        /// 2 Warp version ( = 1 for Photoshop 6.0)
        self.warpVersion = try dataStream.read(endianess: .bigEndian)
        guard self.warpVersion == 1 else {
            throw PhotoshopReadError.corrupted
        }

        /// 4 Descriptor version ( = 16 for Photoshop 6.0)
        /// Variable Warp data (see See Descriptor structure)
        self.warpDescriptor = try VersionedDescriptor(dataStream: &dataStream)
        
        /// 4 * 8 left, top, right, bottom respectively.
        self.left = try dataStream.read(endianess: .bigEndian)
        self.top = try dataStream.read(endianess: .bigEndian)
        self.right = try dataStream.read(endianess: .bigEndian)
        self.bottom = try dataStream.read(endianess: .bigEndian)
    }
}
