//
//  GradientMap.swift
//  
//
//  Created by Hugh Bellamy on 19/01/2021.
//

import DataStream

/// Gradient settings (Photoshop 6.0)
/// Key is 'grdm' . Data is as follows:
public struct GradientMap {
    public let version: UInt16
    public let name: String
    public let reversed: Bool
    public let dithered: Bool
    public let colorStops: [ColorStop]
    public let transparencyStops: [TransparencyStop]
    public let expansionCount: UInt16
    public let interpolation: UInt16?
    public let length: UInt16
    public let mode: UInt16
    public let randomSeed: UInt32
    public let transparencyFlag: UInt16
    public let vectorColorFlag: UInt16
    public let roughnessFactor: UInt32
    public let colorModel: UInt16
    public let minimumColorModels: [UInt16]
    public let maximumColorModels: [UInt16]
    public let unused: UInt16
    
    public init(dataStream: inout DataStream) throws {
        guard dataStream.remainingCount >= 4 else {
            throw PhotoshopReadError.corrupted
        }
        
        /// 2 Version ( =1 for Photoshop 6.0)
        self.version = try dataStream.read(endianess: .bigEndian)
        
        /// 1 Is gradient reversed
        self.reversed = try dataStream.read() as UInt8 != 0

        /// 1 Is gradient dithered
        self.dithered = try dataStream.read() as UInt8 != 0
        
        /// Variable Name of the gradient: Unicode string, padded
        let nameStartPosition = dataStream.position
        self.name = try dataStream.readUnicodeString()
        try dataStream.readTwoByteAlignmentPadding(startPosition: nameStartPosition)
        
        /// 2 Number of color stops to follow
        let numberOfColorStops: UInt16 = try dataStream.read(endianess: .bigEndian)
        guard numberOfColorStops * 18 <= dataStream.remainingCount else {
            throw PhotoshopReadError.corrupted
        }
        
        /// Following is repeated for each color stop
        var colorStops: [ColorStop] = []
        colorStops.reserveCapacity(Int(numberOfColorStops))
        for _ in 0..<numberOfColorStops {
            colorStops.append(try ColorStop(dataStream: &dataStream))
        }
        
        self.colorStops = colorStops
        
        /// 2 Number of transparency stops to follow
        let numberOfTransparencyStops: UInt16 = try dataStream.read(endianess: .bigEndian)
        guard numberOfTransparencyStops * 10 <= dataStream.remainingCount else {
            throw PhotoshopReadError.corrupted
        }
        
        /// Following is repeated for each transparency stop
        var transparencyStops: [TransparencyStop] = []
        transparencyStops.reserveCapacity(Int(numberOfTransparencyStops))
        for _ in 0..<numberOfTransparencyStops {
            transparencyStops.append(try TransparencyStop(dataStream: &dataStream))
        }
        
        self.transparencyStops = transparencyStops
        
        /// 2 Expansion count ( = 2 for Photoshop 6.0)
        self.expansionCount = try dataStream.read(endianess: .bigEndian)
        
        /// 2 Interpolation if length above is non-zero
        if expansionCount != 0 {
            self.interpolation = try dataStream.read(endianess: .bigEndian)
        } else {
            self.interpolation = nil
        }
        
        /// 2 Length (= 32 for Photoshop 6.0)
        self.length = try dataStream.read(endianess: .bigEndian)
        
        /// 2 Mode for this gradient
        self.mode = try dataStream.read(endianess: .bigEndian)
        
        /// 4 Random number seed
        self.randomSeed = try dataStream.read(endianess: .bigEndian)
        
        /// 2 Flag for showing transparency
        self.transparencyFlag = try dataStream.read(endianess: .bigEndian)
        
        /// 2 Flag for using vector color
        self.vectorColorFlag = try dataStream.read(endianess: .bigEndian)
        
        /// 4 Roughness factor
        self.roughnessFactor = try dataStream.read(endianess: .bigEndian)
        
        /// 2 Color model
        self.colorModel = try dataStream.read(endianess: .bigEndian)
        
        /// 4 * 2 Minimum color values
        self.minimumColorModels = [
            try dataStream.read(endianess: .bigEndian),
            try dataStream.read(endianess: .bigEndian),
            try dataStream.read(endianess: .bigEndian),
            try dataStream.read(endianess: .bigEndian)
        ]
    
        /// 4 * 2 Maximum color values
        self.maximumColorModels = [
            try dataStream.read(endianess: .bigEndian),
            try dataStream.read(endianess: .bigEndian),
            try dataStream.read(endianess: .bigEndian),
            try dataStream.read(endianess: .bigEndian)
        ]

        /// 2 Dummy: not used in Photoshop 6.0
        self.unused = try dataStream.read(endianess: .bigEndian)
    }
    
    public struct ColorStop {
        public let location: UInt32
        public let midpoint: UInt32
        public let mode: UInt16
        public let color: [UInt16]
        public let unknown: UInt16
        
        public init(dataStream: inout DataStream) throws {
            guard dataStream.remainingCount >= 18 else {
                throw PhotoshopReadError.corrupted
            }
            
            /// 4 Location of color stop
            self.location = try dataStream.read(endianess: .bigEndian)
            
            /// 4 Midpoint of color stop
            self.midpoint = try dataStream.read(endianess: .bigEndian)
            
            /// 2 Mode for the color to follow
            self.mode = try dataStream.read(endianess: .bigEndian)
            
            /// 4 * 2 Actual color for the stop
            self.color = [
                try dataStream.read(endianess: .bigEndian),
                try dataStream.read(endianess: .bigEndian),
                try dataStream.read(endianess: .bigEndian),
                try dataStream.read(endianess: .bigEndian)
            ]
            
            self.unknown = try dataStream.read(endianess: .bigEndian)
        }
    }
        
    public struct TransparencyStop {
        public let location: UInt32
        public let midpoint: UInt32
        public let opacity: UInt16
        
        public init(dataStream: inout DataStream) throws {
            guard dataStream.remainingCount >= 12 else {
                throw PhotoshopReadError.corrupted
            }
            
            /// 4 Location of transparency stop
            self.location = try dataStream.read(endianess: .bigEndian)

            /// 4 Midpoint of transparency stop
            self.midpoint = try dataStream.read(endianess: .bigEndian)
            
            /// 2 Opacity of transparency stop
            self.opacity = try dataStream.read(endianess: .bigEndian)
        }
    }
}
