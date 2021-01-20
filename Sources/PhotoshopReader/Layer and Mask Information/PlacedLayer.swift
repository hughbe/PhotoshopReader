//
//  PlacedLayer.swift
//  
//
//  Created by Hugh Bellamy on 19/01/2021.
//

import DataStream

/// Placed Layer (replaced by SoLd in Photoshop CS3)
/// Key is 'plLd' . Data is as follows:
/// Placed Layer
/// Length Description
public struct PlacedLayer {
    public let type: String
    public let version: UInt32
    public let id: String
    public let pageNumber: UInt32
    public let totalPages: UInt32
    public let antiAliasPolicy: UInt32
    public let placedLayerType: PlacedLayerType
    public let transformation: [(Double, Double)]
    public let warpVersion: UInt32
    public let warpDescriptor: VersionedDescriptor
    
    public init(dataStream: inout DataStream) throws {
        /// 4 Type ( = 'plcL' )
        guard let type = try dataStream.readString(count: 4, encoding: .ascii) else {
            throw PhotoshopReadError.corrupted
        }
        guard type == "plcL" else {
            throw PhotoshopReadError.corrupted
        }
        
        self.type = type
        
        /// 4 Version ( = 3 )
        self.version = try dataStream.read(endianess: .bigEndian)
        guard self.version == 3 else {
            throw PhotoshopReadError.corrupted
        }
        
        /// Variable Unique ID as a pascal string
        self.id = try dataStream.readPascalString()
        
        /// 4 Page number
        self.pageNumber = try dataStream.read(endianess: .bigEndian)
        
        /// 4 Total pages
        self.totalPages = try dataStream.read(endianess: .bigEndian)
        
        /// 4 Anit alias policy
        self.antiAliasPolicy = try dataStream.read(endianess: .bigEndian)
        
        /// 4 Placed layer type: 0 = unknown, 1 = vector, 2 = raster, 3 = image stack
        self.placedLayerType = try PlacedLayerType(dataStream: &dataStream)
        
        /// 4 * 8 Transformation: 8 doubles for x,y location of transform points
        self.transformation = [
            (try dataStream.readDouble(endianess: .bigEndian), try dataStream.readDouble(endianess: .bigEndian)),
            (try dataStream.readDouble(endianess: .bigEndian), try dataStream.readDouble(endianess: .bigEndian)),
            (try dataStream.readDouble(endianess: .bigEndian), try dataStream.readDouble(endianess: .bigEndian)),
            (try dataStream.readDouble(endianess: .bigEndian), try dataStream.readDouble(endianess: .bigEndian))
        ]
        
        /// 4 Warp version ( = 0 )
        self.warpVersion = try dataStream.read(endianess: .bigEndian)
        
        /// 4 Warp descriptor version ( = 16 )
        /// Variable Descriptor for warping information
        self.warpDescriptor = try VersionedDescriptor(dataStream: &dataStream)
    }
    
    /// 4 Placed layer type: 0 = unknown, 1 = vector, 2 = raster, 3 = image stack
    public enum PlacedLayerType: UInt32, DataStreamCreatable {
        case unknown = 0
        case vector = 1
        case raster = 2
        case imageStack = 3
    }
}
