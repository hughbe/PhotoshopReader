//
//  ColorSamplersResource.swift
//  
//
//  Created by Hugh Bellamy on 18/01/2021.
//

import DataStream

/// Color samplers resource format
/// Adobe Photoshop (version 5.0 and later) stores color samplers information for an image in an image resource block that consists
/// of an initial 8-byte color samplers header followed by a variable length block of specific color samplers information.
public struct ColorSamplersResource {
    public let version: UInt32
    public let samplers: ColorSamplers
    
    public init(dataStream: inout DataStream) throws {
        /// 4 Version ( = 1, 2 or 3)
        let version: UInt32 = try dataStream.read(endianess: .bigEndian)
        guard version == 1 || version == 2 || version == 3 else {
            throw PhotoshopReadError.corrupted
        }
        
        self.version = version

        /// 4 Number of color samplers to follow. See See Color Samplers resource block.
        let count: UInt32 = try dataStream.read(endianess: .bigEndian)
        guard (version == 1 && 10 * count <= dataStream.remainingCount) ||
                (version == 2 && 12 * count <= dataStream.remainingCount) ||
                (version == 2 && 16 * count <= dataStream.remainingCount) else {
            throw PhotoshopReadError.corrupted
        }
        
        if version == 1 {
            var samplers: [ColorSamplerVersion1] = []
            samplers.reserveCapacity(Int(count))
            for _ in 0..<count {
                samplers.append(try ColorSamplerVersion1(dataStream: &dataStream))
            }
            
            self.samplers = .version1(samplers)
        } else if version == 2 {
            var samplers: [ColorSamplerVersion2] = []
            samplers.reserveCapacity(Int(count))
            for _ in 0..<count {
                samplers.append(try ColorSamplerVersion2(dataStream: &dataStream))
            }
            
            self.samplers = .version2(samplers)
        } else {
            var samplers: [ColorSamplerVersion3] = []
            samplers.reserveCapacity(Int(count))
            for _ in 0..<count {
                samplers.append(try ColorSamplerVersion3(dataStream: &dataStream))
            }
            
            self.samplers = .version3(samplers)
        }
    }
    
    public enum ColorSamplers {
        case version1(_: [ColorSamplerVersion1])
        case version2(_: [ColorSamplerVersion2])
        case version3(_: [ColorSamplerVersion3])
    }
    
    public struct ColorSamplerVersion1 {
        public let horizontalPosition: UInt32
        public let verticalPosition: UInt32
        public let colorSpace: ColorSpace
        
        public init(dataStream: inout DataStream) throws {
            /// 8 The horizontal and vertical position of the point (4 bytes each). Version 1 is a fixed value. Version 2 is a float value.
            self.horizontalPosition = try dataStream.read(endianess: .bigEndian)
            self.verticalPosition = try dataStream.read(endianess: .bigEndian)

            /// 2 Color Space: enum { colorCodeDummy = -1, RGB, HSB, CMYK, Pantone, Focoltone, Trumatch, Toyo, Lab,
            /// Gray, WideCMYK, HKS, DIC, TotalInk, MonitorRGB, Duotone, Opacity, Web, GrayFloat, RGBFloat, OpacityFloat};
            self.colorSpace = try ColorSpace(dataStream: &dataStream)
        }
    }
    
    public struct ColorSamplerVersion2 {
        public let horizontalPosition: Float
        public let verticalPosition: Float
        public let colorSpace: ColorSpace
        public let depth: UInt16
        
        public init(dataStream: inout DataStream) throws {
            /// 8 The horizontal and vertical position of the point (4 bytes each). Version 1 is a fixed value. Version 2 is a float value.
            self.horizontalPosition = try dataStream.readFloat(endianess: .bigEndian)
            self.verticalPosition = try dataStream.readFloat(endianess: .bigEndian)

            /// 2 Color Space: enum { colorCodeDummy = -1, RGB, HSB, CMYK, Pantone, Focoltone, Trumatch, Toyo, Lab,
            /// Gray, WideCMYK, HKS, DIC, TotalInk, MonitorRGB, Duotone, Opacity, Web, GrayFloat, RGBFloat, OpacityFloat};
            self.colorSpace = try ColorSpace(dataStream: &dataStream)
            
            /// 2 Depth ( Version 2 only )
            self.depth = try dataStream.read(endianess: .bigEndian)
        }
    }
    
    public struct ColorSamplerVersion3 {
        public let version: UInt32
        public let horizontalPosition: Float
        public let verticalPosition: Float
        public let colorSpace: ColorSpace
        public let depth: UInt16
        
        public init(dataStream: inout DataStream) throws {
            /// 4 Version of color samplers, 1 for version 3. ( Version 3 only ) .
            self.version = try dataStream.read(endianess: .bigEndian)
            guard self.version == 1 else {
                throw PhotoshopReadError.corrupted
            }

            /// 8 The horizontal and vertical position of the point (4 bytes each). Version 1 is a fixed value. Version 2 is a float value.
            self.horizontalPosition = try dataStream.readFloat(endianess: .bigEndian)
            self.verticalPosition = try dataStream.readFloat(endianess: .bigEndian)

            /// 2 Color Space: enum { colorCodeDummy = -1, RGB, HSB, CMYK, Pantone, Focoltone, Trumatch, Toyo, Lab,
            /// Gray, WideCMYK, HKS, DIC, TotalInk, MonitorRGB, Duotone, Opacity, Web, GrayFloat, RGBFloat, OpacityFloat};
            self.colorSpace = try ColorSpace(dataStream: &dataStream)
            
            /// 2 Depth ( Version 2 only )
            self.depth = try dataStream.read(endianess: .bigEndian)
        }
    }
    
    public enum ColorSpace: Int16, DataStreamCreatable {
        case dummy = -1
        case rgb = 0
        case hsb = 1
        case cmyk = 2
        case pantone = 3
        case focoltone = 4
        case trumatch = 5
        case toyo = 6
        case gray = 7
        case wideCMYK = 8
        case hks = 9
        case dic = 10
        case totalInk = 11
        case monitorRGB = 12
        case duotone = 13
        case opacity = 14
        case web = 15
        case grayFloat = 16
        case rgbFloat = 17
        case opacityFloat = 18
    }
}
