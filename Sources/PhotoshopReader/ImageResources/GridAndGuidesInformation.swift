//
//  GridAndGuidesInformation.swift
//  
//
//  Created by Hugh Bellamy on 18/01/2021.
//


import DataStream

/// Grid and guides resource format
/// Photoshop stores grid and guides information for an image in an image resource block. Each of these resource blocks consists of an initial
/// 16-byte grid and guide header, which is always present, followed by 5-byte blocks of specific guide information for guide direction and
/// location, which are present if there are guides ( fGuideCount > 0).
/// Grid and guide information may be modified using the Property suite. See the Callbacks chapter in Photoshop API Guide.pdf for more information.
public struct GridAndGuidesInformation {
    public let version: UInt32
    public let horizontalDocumentSpecificGrid: UInt32
    public let verticalDocumentSpecificGrid: UInt32
    public let guides: [Guide]
    
    public init(dataStream: inout DataStream) throws {
        guard dataStream.remainingCount >= 16 else {
            throw PhotoshopReadError.corrupted
        }
        
        /// 4 Version ( = 1)
        self.version = try dataStream.read(endianess: .bigEndian)
        guard self.version == 1 else {
            throw PhotoshopReadError.corrupted
        }
        
        /// 8 Future implementation of document-specific grids (4 bytes horizontal, 4 bytes vertical). Currently, sets the grid cycle to every
        /// quarter inch, i.e. 576 for both horizontal & vertical (at 72 dpi, that is 18 * 32 = 576)
        self.horizontalDocumentSpecificGrid = try dataStream.read(endianess: .bigEndian)
        self.verticalDocumentSpecificGrid = try dataStream.read(endianess: .bigEndian)

        /// 4 fGuideCount : Number of guide resource blocks (can be 0).
        let fGuideCount: UInt32 = try dataStream.read(endianess: .bigEndian)
        guard 5 * fGuideCount <= dataStream.remainingCount else {
            throw PhotoshopReadError.corrupted
        }
        
        var guides: [Guide] = []
        guides.reserveCapacity(Int(fGuideCount))
        for _ in 0..<fGuideCount {
            guides.append(try Guide(dataStream: &dataStream))
        }

        self.guides = guides
    }
    
    public struct Guide {
        public let location: UInt32
        public let direction: Direction
        
        public init(dataStream: inout DataStream) throws {
            /// 4 Location of guide in document coordinates. Since the guide is either vertical or horizontal, this only has to be one
            /// component of the coordinate.
            self.location = try dataStream.read(endianess: .bigEndian)
            
            /// 1 Direction of guide. VHSelect is a system type of unsigned char where 0 = vertical, 1 = horizontal.
            self.direction = try Direction(dataStream: &dataStream)
        }
        
        public enum Direction: UInt8, DataStreamCreatable {
            case vertical = 0
            case horizontal = 1
        }
    }
}
