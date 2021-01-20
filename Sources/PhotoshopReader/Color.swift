//
//  Color.swift
//  
//
//  Created by Hugh Bellamy on 18/01/2021.
//


import DataStream

/// Color structure
public struct Color {
    public let id: UInt16
    public let colorData1: UInt16
    public let colorData2: UInt16
    public let colorData3: UInt16
    public let colorData4: UInt16
    
    public init(dataStream: inout DataStream) throws {
        guard dataStream.remainingCount >= 10 else {
            throw PhotoshopReadError.corrupted
        }
        
        /// 2 The color space the color belongs to (see See Color space IDs).
        self.id = try dataStream.read(endianess: .bigEndian)
        
        /// 8 Four short unsigned integers with the actual color data. If the color does not require four values, the extra values are undefined
        /// and should be written as zeros. See See Color space IDs.
        self.colorData1 = try dataStream.read(endianess: .bigEndian)
        self.colorData2 = try dataStream.read(endianess: .bigEndian)
        self.colorData3 = try dataStream.read(endianess: .bigEndian)
        self.colorData4 = try dataStream.read(endianess: .bigEndian)
    }
    
    /// Color space IDs
    /// Photoshop allows the specification of custom colors, such as those colors that are defined in a set of custom inks provided by a printing
    /// ink manufacturer. These colors can be stored in the Colors palette and streamed to and from load files. The details of a custom color's color data fields are not public and should be treated as a black box.
    /// See Custom color spaces gives the color space IDs currently defined by Photoshop for some custom color spaces.
    public enum ColorSpaceID: UInt16, DataStreamCreatable {
        /// 0 RGB. The first three values in the color data are red , green , and blue . They are full unsigned 16-bit values as in Apple's
        /// RGBColor data structure. Pure red = 65535, 0, 0.
        case rgb = 0

        /// 1 HSB. The first three values in the color data are hue , saturation , and brightness . They are full unsigned 16-bit values as in
        /// Apple's HSVColor data structure. Pure red = 0,65535, 65535.
        case hsb = 1
        
        /// 2 CMYK. The four values in the color data are cyan , magenta , yellow , and black . They are full unsigned 16-bit values.
        /// 0 = 100% ink. For example, pure cyan = 0,65535,65535,65535.
        case cmyk = 2
        
        /// 7 Lab. The first three values in the color data are lightness , a chrominance , and b chrominance .
        /// Lightness is a 16-bit value from 0...10000. Chrominance components are each 16-bit values from -12800...12700. Gray values are represented by chrominance components of 0. Pure white = 10000,0,0.
        case lab = 7
        
        /// 8 Grayscale. The first value in the color data is the gray value, from 0...10000.
        case grayscale = 8
        
        /// 3 Pantone matching system
        case pantoneMatchingSystem = 3

        /// 4 Focoltone colour system
        case focoltoneColorSystem = 4

        /// 5 Trumatch color
        case trumatchColor = 5

        /// 6 Toyo 88 colorfinder 1050
        case toyo88ColorFinder1050 = 6

        /// 10 HKS colors
        case hks = 10
    }
}
