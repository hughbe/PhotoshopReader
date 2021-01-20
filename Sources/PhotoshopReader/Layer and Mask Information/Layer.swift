//
//  Layer.swift
//  
//
//  Created by Hugh Bellamy on 19/01/2021.
//

import DataStream

/// Layer records
public struct Layer {
    public let top: UInt32
    public let left: UInt32
    public let bottom: UInt32
    public let right: UInt32
    public let channels: [Channel]
    public let blendModeSignature: String
    public let blendModeKey: String
    public let opacity: UInt8
    public let clippingNonBase: Bool
    public let flags: Flags
    public let filler: UInt8
    public let extraDataLength: UInt32
    public let maskData: LayerMaskData
    public let blendingRanges: LayerBlendingRanges
    public let name: String
    public let additionalLayerInformation: [AdditionalLayerInformation]
    
    public init(dataStream: inout DataStream, psb: Bool) throws {
        /// 4 * 4 Rectangle containing the contents of the layer. Specified as top, left, bottom, right coordinates
        self.top = try dataStream.read(endianess: .bigEndian)
        self.left = try dataStream.read(endianess: .bigEndian)
        self.bottom = try dataStream.read(endianess: .bigEndian)
        self.right = try dataStream.read(endianess: .bigEndian)
        
        /// 2 Number of channels in the layer
        let numberOfChannels: UInt16 = try dataStream.read(endianess: .bigEndian)

        /// 6 * Number of channels Channel information. Six bytes per channel, consisting of:
        /// 2 bytes for Channel ID: 0 = red, 1 = green, etc.; -1 = transparency mask; -2 = user supplied layer mask, -3 real user
        /// supplied layer mask (when both a user mask and a vector mask are present)
        /// 4 bytes for length of corresponding channel data. (**PSB** 8 bytes for length of corresponding channel data.) See
        /// See Channel image data for structure of channel data.
        var channels: [Channel] = []
        channels.reserveCapacity(Int(numberOfChannels))
        for _ in 0..<numberOfChannels {
            channels.append(try Channel(dataStream: &dataStream, psb: psb))
        }
        
        self.channels = channels
        
        /// 4 Blend mode signature: '8BIM'
        guard let blendModeSignature = try dataStream.readString(count: 4, encoding: .ascii) else {
            throw PhotoshopReadError.corrupted
        }
        guard blendModeSignature == "8BIM" else {
            throw PhotoshopReadError.corrupted
        }
        
        self.blendModeSignature = blendModeSignature

        /// 4 Blend mode key: 'pass' = pass through, 'norm' = normal, 'diss' = dissolve, 'dark' = darken, 'mul ' = multiply,
        /// 'idiv' = color burn, 'lbrn' = linear burn, 'dkCl' = darker color, 'lite' = lighten, 'scrn' = screen, 'div ' = color dodge,
        /// 'lddg' = linear dodge, 'lgCl' = lighter color, 'over' = overlay, 'sLit' = soft light, 'hLit' = hard light, 'vLit' = vivid light,
        /// 'lLit' = linear light, 'pLit' = pin light, 'hMix' = hard mix, 'diff' = difference, 'smud' = exclusion, 'fsub' = subtract,
        /// 'fdiv' = divide 'hue ' = hue, 'sat ' = saturation, 'colr' = color, 'lum ' = luminosity,
        guard let blendModeKey = try dataStream.readString(count: 4, encoding: .ascii) else {
            throw PhotoshopReadError.corrupted
        }
        
        self.blendModeKey = blendModeKey

        /// 1 Opacity. 0 = transparent ... 255 = opaque
        self.opacity = try dataStream.read()

        /// 1 Clipping: 0 = base, 1 = non-base
        self.clippingNonBase = try dataStream.read() as UInt8 != 0

        /// 1 Flags:
        /// bit 0 = transparency protected;
        /// bit 1 = visible;
        /// bit 2 = obsolete;
        /// bit 3 = 1 for Photoshop 5.0 and later, tells if bit 4 has useful information;
        /// bit 4 = pixel data irrelevant to appearance of document
        self.flags = try Flags(dataStream: &dataStream)

        /// 1 Filler (zero)
        self.filler = try dataStream.read()

        /// 4 Length of the extra data field ( = the total length of the next five fields).
        let extraDataLength: UInt32 = try dataStream.read(endianess: .bigEndian)
        guard extraDataLength >= 4 && extraDataLength <= dataStream.remainingCount else {
            throw PhotoshopReadError.corrupted
        }
        
        self.extraDataLength = extraDataLength
        
        let extraDataStartPosition = dataStream.position

        /// Variable Layer mask data: See See Layer mask / adjustment layer data for structure. Can be 40 bytes, 24 bytes,
        /// or 4 bytes if no layer mask.
        self.maskData = try LayerMaskData(dataStream: &dataStream)

        /// Variable  Layer blending ranges: See See Layer blending ranges data.
        self.blendingRanges = try LayerBlendingRanges(dataStream: &dataStream)

        /// Variable Layer name: Pascal string, padded to a multiple of 4 bytes.
        self.name = try dataStream.readPascalString()
        try dataStream.readFourByteAlignmentPadding(startPosition: extraDataStartPosition)
        
        /// Additional Layer Information
        /// There are several types of layer information that have been added in Photoshop 4.0 and later. These exist at the
        /// end of the layer records structure (see the last row of See Layer records). They have the following structure:
        var additionalLayerInformation: [AdditionalLayerInformation] = []
        while dataStream.position - extraDataStartPosition < self.extraDataLength {
            additionalLayerInformation.append(try AdditionalLayerInformation(dataStream: &dataStream, psb: psb))
        }
        
        self.additionalLayerInformation = additionalLayerInformation
        
        guard dataStream.position - extraDataStartPosition == self.extraDataLength else {
            throw PhotoshopReadError.corrupted
        }
    }
    
    /// 6 * Number of channels Channel information. Six bytes per channel, consisting of:
    /// 2 bytes for Channel ID: 0 = red, 1 = green, etc.; -1 = transparency mask; -2 = user supplied layer mask, -3 real user
    /// supplied layer mask (when both a user mask and a vector mask are present)
    /// 4 bytes for length of corresponding channel data. (**PSB** 8 bytes for length of corresponding channel data.) See
    /// See Channel image data for structure of channel data.
    public struct Channel {
        public let id: Int16
        public let length: UInt64

        public init(dataStream: inout DataStream, psb: Bool) throws {
            guard dataStream.remainingCount >= 6 else {
                throw PhotoshopReadError.corrupted
            }
            
            self.id = try dataStream.read(endianess: .bigEndian)
            
            if psb {
                self.length = try dataStream.read(endianess: .bigEndian)
            } else {
                self.length = UInt64(try dataStream.read(endianess: .bigEndian) as UInt32)
            }
        }
    }
    
    /// 4 Blend mode key: 'pass' = pass through, 'norm' = normal, 'diss' = dissolve, 'dark' = darken, 'mul ' = multiply,
    /// 'idiv' = color burn, 'lbrn' = linear burn, 'dkCl' = darker color, 'lite' = lighten, 'scrn' = screen, 'div ' = color dodge,
    /// 'lddg' = linear dodge, 'lgCl' = lighter color, 'over' = overlay, 'sLit' = soft light, 'hLit' = hard light, 'vLit' = vivid light,
    /// 'lLit' = linear light, 'pLit' = pin light, 'hMix' = hard mix, 'diff' = difference, 'smud' = exclusion, 'fsub' = subtract,
    /// 'fdiv' = divide 'hue ' = hue, 'sat ' = saturation, 'colr' = color, 'lum ' = luminosity,
    public enum BlendModeKey: String {
        case passThrough = "pass"
        case normal = "norm"
        case dissolve = "diss"
        case darken = "dark"
        case multiply = "mul "
        case colorBurn = "idiv"
        case linearBurn = "lbrn"
        case darkerColor = "dkCl"
        case lighten = "lite"
        case screen = "scrn"
        case colorDodge = "div "
        case linearDodge = "lddg"
        case lighterColor = "lgCl"
        case overlay = "over"
        case softLight = "sLit"
        case hardLight = "hLit"
        case vividLight = "vLit"
        case linearLight = "lLit"
        case pinLight = "pLit"
        case hardMix = "hMix"
        case difference = "diff"
        case exclusion = "smud"
        case subtract = "fsub"
        case divid = "fdiv"
        case hue = "hue "
        case saturatio = "sat "
        case color = "colr"
        case luminosity = "lum "
    }
    
    /// 1 Flags:
    /// bit 0 = transparency protected;
    /// bit 1 = visible;
    /// bit 2 = obsolete;
    /// bit 3 = 1 for Photoshop 5.0 and later, tells if bit 4 has useful information;
    /// bit 4 = pixel data irrelevant to appearance of document
    public struct Flags {
        public let transparencyProtected: Bool
        public let visible: Bool
        public let obsolete: Bool
        public let photoshop5OrLater: Bool
        public let pixelDataIrrelevantToAppearanceOfDocument: Bool
        public let unused: UInt8
        
        public init(dataStream: inout DataStream) throws {
            var flags: BitFieldReader<UInt8> = try dataStream.readBits()
            
            self.transparencyProtected = flags.readBit()
            self.visible = flags.readBit()
            self.obsolete = flags.readBit()
            self.photoshop5OrLater = flags.readBit()
            self.pixelDataIrrelevantToAppearanceOfDocument = flags.readBit()
            self.unused = flags.readRemainingBits()
        }
    }
}
