//
//  LayerMaskData.swift
//  
//
//  Created by Hugh Bellamy on 19/01/2021.
//

import DataStream

/// Variable Layer mask data: See See Layer mask / adjustment layer data for structure. Can be 40 bytes, 24 bytes,
/// or 4 bytes if no layer mask.
public struct LayerMaskData {
    public let size: UInt32
    public let top: Int32?
    public let left: Int32?
    public let bottom: Int32?
    public let right: Int32?
    public let defaultColor: UInt8?
    public let flags: Flags?
    public let maskParameters: MaskParameters?
    public let realFlags: Flags?
    public let realUserMaskBackground: UInt8?
    public let realTop: Int32?
    public let realLeft: Int32?
    public let realBottom: Int32?
    public let realRight: Int32?
    
    public init(dataStream: inout DataStream) throws {
        guard dataStream.remainingCount >= 4 else {
            throw PhotoshopReadError.corrupted
        }
        
        /// 4 Size of the data: Check the size and flags to determine what is or is not present. If zero, the
        /// following fields are not present
        let size: UInt32 = try dataStream.read(endianess: .bigEndian)
        guard (size == 0 || size >= 20) && size <= dataStream.remainingCount else {
            throw PhotoshopReadError.corrupted
        }
        
        self.size = size
        
        if self.size == 0 {
            self.top = nil
            self.left = nil
            self.bottom = nil
            self.right = nil
            self.defaultColor = nil
            self.flags = nil
            self.maskParameters = nil
            self.realFlags = nil
            self.realUserMaskBackground = nil
            self.realTop = nil
            self.realLeft = nil
            self.realBottom = nil
            self.realRight = nil
            return
        }
        
        var dataDataStream = DataStream(slicing: dataStream, startIndex: dataStream.position, count: Int(self.size))
        
        /// 4 * 4 Rectangle enclosing layer mask: Top, left, bottom, right
        self.top = try dataDataStream.read(endianess: .bigEndian)
        self.left = try dataDataStream.read(endianess: .bigEndian)
        self.bottom = try dataDataStream.read(endianess: .bigEndian)
        self.right = try dataDataStream.read(endianess: .bigEndian)
        
        /// 1 Default color. 0 or 255
        self.defaultColor = try dataDataStream.read()
        
        /// 1 Flags.
        /// bit 0 = position relative to layer
        /// bit 1 = layer mask disabled
        /// bit 2 = invert layer mask when blending (Obsolete)
        /// bit 3 = indicates that the user mask actually came from rendering other data
        /// bit 4 = indicates that the user and/or vector masks have parameters applied to them
        let flags = try Flags(dataStream: &dataDataStream)
        self.flags = flags
        
        /// 2 Padding. Only present if size = 20. Otherwise the following is present
        if self.size == 20 {
            let _: UInt16 = try dataDataStream.read(endianess: .bigEndian)
            dataStream.position += Int(self.size)
            self.maskParameters = nil
            self.realFlags = nil
            self.realUserMaskBackground = nil
            self.realTop = nil
            self.realLeft = nil
            self.realBottom = nil
            self.realRight = nil
            return
        }
        
        /// 1 Mask Parameters. Only present if bit 4 of Flags set above.
        /// Variable
        /// Mask Parameters bit flags present as follows:
        /// bit 0 = user mask density, 1 byte
        /// bit 1 = user mask feather, 8 byte, double
        /// bit 2 = vector mask density, 1 byte
        /// bit 3 = vector mask feather, 8 bytes, double
        if flags.masksHaveParametersAppliedToThem {
            self.maskParameters = try MaskParameters(dataStream: &dataDataStream)
        } else {
            self.maskParameters = nil
        }
        
        if dataDataStream.remainingCount == 0 {
            dataStream.position += Int(self.size)
            self.realFlags = nil
            self.realUserMaskBackground = nil
            self.realTop = nil
            self.realLeft = nil
            self.realBottom = nil
            self.realRight = nil
            return
        }
        
        /// 1 Real Flags. Same as Flags information above.
        self.realFlags = try Flags(dataStream: &dataDataStream)

        /// 1 Real user mask background. 0 or 255.
        self.realUserMaskBackground = try dataDataStream.read()

        /// 4 * 4 Rectangle enclosing layer mask: Top, left, bottom, right.
        self.realTop = try dataDataStream.read(endianess: .bigEndian)
        self.realLeft = try dataDataStream.read(endianess: .bigEndian)
        self.realBottom = try dataDataStream.read(endianess: .bigEndian)
        self.realRight = try dataDataStream.read(endianess: .bigEndian)
        
        dataStream.position += Int(self.size)
    }
    
    /// 1 Flags.
    /// bit 0 = position relative to layer
    /// bit 1 = layer mask disabled
    /// bit 2 = invert layer mask when blending (Obsolete)
    /// bit 3 = indicates that the user mask actually came from rendering other data
    /// bit 4 = indicates that the user and/or vector masks have parameters applied to them
    public struct Flags {
        public let positionRelativeToLayer: Bool
        public let layerMaskDisabled: Bool
        public let invertLayerMaskWhenBlending: Bool
        public let userMaskCameFromRenderingOtherData: Bool
        public let masksHaveParametersAppliedToThem: Bool
        public let unused: UInt8
        
        public init(dataStream: inout DataStream) throws {
            var flags: BitFieldReader<UInt8> = try dataStream.readBits()
            
            self.positionRelativeToLayer = flags.readBit()
            self.layerMaskDisabled = flags.readBit()
            self.invertLayerMaskWhenBlending = flags.readBit()
            self.userMaskCameFromRenderingOtherData = flags.readBit()
            self.masksHaveParametersAppliedToThem = flags.readBit()
            self.unused = flags.readRemainingBits()
        }
    }
    
    /// 1 Mask Parameters. Only present if bit 4 of Flags set above.
    /// Variable
    /// Mask Parameters bit flags present as follows:
    /// bit 0 = user mask density, 1 byte
    /// bit 1 = user mask feather, 8 byte, double
    /// bit 2 = vector mask density, 1 byte
    /// bit 3 = vector mask feather, 8 bytes, double
    public struct MaskParameters {
        public let flags: BitFlags
        public let userMaskDensity: UInt8?
        public let userMaskFeather: Double?
        public let vectorMaskDensity: UInt8?
        public let vectorMaskFeather: Double?
        
        public init(dataStream: inout DataStream) throws {
            self.flags = try BitFlags(dataStream: &dataStream)
            
            if self.flags.userMaskDensity {
                self.userMaskDensity = try dataStream.read()
            } else {
                self.userMaskDensity = nil
            }
    
            if self.flags.userMaskFeather {
                self.userMaskFeather = try dataStream.readDouble(endianess: .littleEndian)
            } else {
                self.userMaskFeather = nil
            }
            
            if self.flags.vectorMaskDensity {
                self.vectorMaskDensity = try dataStream.read()
            } else {
                self.vectorMaskDensity = nil
            }
            
            if self.flags.vectorMaskFeather {
                self.vectorMaskFeather = try dataStream.readDouble(endianess: .littleEndian)
            } else {
                self.vectorMaskFeather = nil
            }
        }
        
        public struct BitFlags {
            public let userMaskDensity: Bool
            public let userMaskFeather: Bool
            public let vectorMaskDensity: Bool
            public let vectorMaskFeather: Bool
            public let unused: UInt8
            
            public init(dataStream: inout DataStream) throws {
                var flags: BitFieldReader<UInt8> = try dataStream.readBits()
                self.userMaskDensity = flags.readBit()
                self.userMaskFeather = flags.readBit()
                self.vectorMaskDensity = flags.readBit()
                self.vectorMaskFeather = flags.readBit()
                self.unused = flags.readRemainingBits()
            }
        }
    }
}
