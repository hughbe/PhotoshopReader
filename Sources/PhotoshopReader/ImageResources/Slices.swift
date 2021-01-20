//
//  Slices.swift
//  
//
//  Created by Hugh Bellamy on 18/01/2021.
//

import DataStream

/// Slices resource format
/// Adobe Photoshop 6.0 stores slices information for an image in an image resource block.
/// Adobe Photoshop 7.0 added a descriptor at the end of the block for the individual slice info.
/// Adobe Photoshop CS and later changed to version 7 or 8 and uses a Descriptor to defined the Slices data.
public enum Slices {
    case new(_: New)
    case old(_: Old)
    
    public init(dataStream: inout DataStream) throws {
        let version: UInt32 = try dataStream.peek(endianess: .bigEndian)
        switch version {
        case 7, 8:
            self = .new(try New(dataStream: &dataStream))
        case 6:
            self = .old(try Old(dataStream: &dataStream))
        default:
            throw PhotoshopReadError.corrupted
        }
    }
    
    /// Slices header for version 7 or 8
    public struct New {
        public let version: UInt32
        public let descriptor: VersionedDescriptor
        
        public init(dataStream: inout DataStream) throws {
            /// 4 Version ( = 7 and 8)
            let version: UInt32 = try dataStream.read(endianess: .bigEndian)
            guard version == 7 || version == 8 else {
                throw PhotoshopReadError.corrupted
            }
            
            self.version = version
            
            /// 4 Descriptor version ( = 16 for Photoshop 6.0).
            /// Variable Descriptor (see See Descriptor structure)
            self.descriptor = try VersionedDescriptor(dataStream: &dataStream)
        }
    }
    
    /// Slices header for version 6
    public struct Old {
        public let version: UInt32
        public let top: Int32
        public let left: Int32
        public let bottom: Int32
        public let right: Int32
        public let name: String
        public let slices: [Slice]
        public let descriptor: VersionedDescriptor?
        
        public init(dataStream: inout DataStream) throws {
            /// 4 Version ( = 6)
            self.version = try dataStream.read(endianess: .bigEndian)
            guard self.version == 6 else {
                throw PhotoshopReadError.corrupted
            }
            
            /// 4 * 4 Bounding rectangle for all of the slices: top, left, bottom, right of all the slices
            self.top = try dataStream.read(endianess: .bigEndian)
            self.left = try dataStream.read(endianess: .bigEndian)
            self.bottom = try dataStream.read(endianess: .bigEndian)
            self.right = try dataStream.read(endianess: .bigEndian)

            /// Variable Name of group of slices: Unicode string
            self.name = try dataStream.readUnicodeString()

            /// 4 Number of slices to follow. See Slices resource block in the next table.
            let numberOfSlices: UInt32 = try dataStream.read(endianess: .bigEndian)
            
            var slices: [Slice] = []
            slices.reserveCapacity(Int(numberOfSlices))
            for _ in 0..<numberOfSlices {
                slices.append(try Slice(dataStream: &dataStream))
            }
            
            self.slices = slices
            
            /// Additional data as length allows. See comment above.
            if dataStream.remainingCount == 0 {
                self.descriptor = nil
                return
            }
        
            /// 4 Descriptor version ( = 16 for Photoshop 6.0).
            /// Variable Descriptor (see See Descriptor structure)
            self.descriptor = try VersionedDescriptor(dataStream: &dataStream)
        }
        
        /// Slices resource block
        public struct Slice {
            public let id: UInt32
            public let groupID: UInt32
            public let origin: UInt32
            public let associatedLayerID: UInt32?
            public let name: String
            public let type: UInt32
            public let left: UInt32
            public let top: UInt32
            public let right: UInt32
            public let bottom: UInt32
            public let url: String
            public let message: String
            public let target: String
            public let altTag: String
            public let cellTextIsHTML: Bool
            public let cellText: String
            public let horizontalAlignment: UInt32
            public let verticalAlignment: UInt32
            public let alphaColor: UInt8
            public let red: UInt8
            public let green: UInt8
            public let blue: UInt8
            
            public init(dataStream: inout DataStream) throws {
                /// 4 ID
                self.id = try dataStream.read(endianess: .bigEndian)
                
                /// 4 Group ID
                self.groupID = try dataStream.read(endianess: .bigEndian)

                /// 4 Origin
                self.origin = try dataStream.read(endianess: .bigEndian)
                
                /// 4 Associated Layer ID Only present if Origin = 1
                if self.origin == 1 {
                    self.associatedLayerID = try dataStream.read(endianess: .bigEndian)
                } else {
                    self.associatedLayerID = nil
                }
                
                /// Variable Name: Unicode string
                self.name = try dataStream.readUnicodeString()
                
                /// 4 Type
                self.type = try dataStream.read(endianess: .bigEndian)
                
                /// 4 * 4 Left, top, right, bottom positions
                self.left = try dataStream.read(endianess: .bigEndian)
                self.top = try dataStream.read(endianess: .bigEndian)
                self.right = try dataStream.read(endianess: .bigEndian)
                self.bottom = try dataStream.read(endianess: .bigEndian)
                
                /// Variable URL: Unicode string
                self.url = try dataStream.readUnicodeString()
                
                /// Variable Target: Unicode string
                self.target = try dataStream.readUnicodeString()
                
                /// Variable Message: Unicode string
                self.message = try dataStream.readUnicodeString()
                
                /// Variable Alt Tag: Unicode string
                self.altTag = try dataStream.readUnicodeString()
                
                /// 1 Cell text is HTML: Boolean
                self.cellTextIsHTML = try dataStream.read() as UInt8 != 0
                
                /// Variable Cell text: Unicode string
                self.cellText = try dataStream.readUnicodeString()
                
                /// 4 Horizontal alignment
                self.horizontalAlignment = try dataStream.read(endianess: .bigEndian)
                
                /// 4 Vertical alignment
                self.verticalAlignment = try dataStream.read(endianess: .bigEndian)
                
                /// 1 Alpha color
                self.alphaColor = try dataStream.read()
                
                /// 1 Red
                self.red = try dataStream.read()
                
                /// 1 Green
                self.green = try dataStream.read()
                
                /// 1 Blue
                self.blue = try dataStream.read()
            }
        }
    }
}
