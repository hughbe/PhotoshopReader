//
//  PatternData.swift
//  
//
//  Created by Hugh Bellamy on 19/01/2021.
//

import DataStream

/// Pattern data (Photoshop 6.0)
/// Key is 'shpa' . Data is as follows:
public struct PatternData {
    public let version: UInt32
    public let sets: [PatternSet]

    public init(dataStream: inout DataStream) throws {
        guard dataStream.remainingCount >= 8 else {
            throw PhotoshopReadError.corrupted
        }
        
        /// 4 Version ( = 0 for Photoshop 6.0)
        self.version = try dataStream.read(endianess: .bigEndian)
        guard self.version == 0 else {
            throw PhotoshopReadError.corrupted
        }
        
        /// 4 Count of sets to follow
        let count: UInt32 = try dataStream.read(endianess: .bigEndian)
        guard count * 12 <= dataStream.remainingCount else {
            throw PhotoshopReadError.corrupted
        }
        
        /// The following is repeated for the count above.
        var sets: [PatternSet] = []
        sets.reserveCapacity(Int(count))
        for _ in 0..<count {
            sets.append(try PatternSet(dataStream: &dataStream))
        }
        
        self.sets = sets
    }
    
    /// The following is repeated for the count above.
    public struct PatternSet {
        public let signature: String
        public let key: UInt32
        public let copyOnSheetDuplication: Bool
        public let padding1: UInt8
        public let padding2: UInt8
        public let padding3: UInt8
        public let patterns: [Pattern]
        
        public init(dataStream: inout DataStream) throws {
            guard dataStream.remainingCount >= 12 else {
                throw PhotoshopReadError.corrupted
            }
            
            /// 4 Pattern signature
            guard let signature = try dataStream.readString(count: 4, encoding: .ascii) else {
                throw PhotoshopReadError.corrupted
            }
            
            self.signature = signature
            
            /// 4 Pattern key
            self.key = try dataStream.read(endianess: .bigEndian)
            
            /// 4 Count of patterns in this set
            let count: UInt32 = try dataStream.read(endianess: .bigEndian)
            guard 4 + count * 7 <= dataStream.remainingCount else {
                throw PhotoshopReadError.corrupted
            }
            
            /// 1 Copy on sheet duplication
            self.copyOnSheetDuplication = try dataStream.read() as UInt8 != 0
            
            /// 3 Padding
            self.padding1 = try dataStream.read()
            self.padding2 = try dataStream.read()
            self.padding3 = try dataStream.read()
            
            /// The following is repeated for the count of patterns above.
            var patterns: [Pattern] = []
            patterns.reserveCapacity(Int(count))
            for _ in 0..<count {
                patterns.append(try Pattern(dataStream: &dataStream))
            }
            
            self.patterns = patterns
        }
        
        /// The following is repeated for the count of patterns above.
        public struct Pattern {
            public let colorHandling: ColorHandling
            public let pascalName: String
            public let unicodeName: String
            public let uniqueID: String
            
            public init(dataStream: inout DataStream) throws {
                guard dataStream.remainingCount >= 7 else {
                    throw PhotoshopReadError.corrupted
                }

                /// 4 Color handling. Prefer convert = 'conv' , avoid conversion = 'avod' , luminance only = 'lumi'
                guard let colorHandlingRaw = try dataStream.readString(count: 4, encoding: .ascii) else {
                    throw PhotoshopReadError.corrupted
                }
                guard let colorHandling = ColorHandling(rawValue: colorHandlingRaw) else {
                    throw PhotoshopReadError.corrupted
                }
                
                self.colorHandling = colorHandling
                
                /// Variable Pascal string name of the pattern
                self.pascalName = try dataStream.readPascalString()
                
                /// Variable Unicode string name of the pattern
                self.unicodeName = try dataStream.readUnicodeString()
                
                /// Variable Pascal string of the unique identifier for the pattern
                self.uniqueID = try dataStream.readPascalString()
            }
            
            /// 4 Color handling. Prefer convert = 'conv' , avoid conversion = 'avod' , luminance only = 'lumi'
            public enum ColorHandling: String {
                case preferConvert = "conv"
                case avoidConversion = "avod"
                case luminanceOnly = "lumi"
            }
        }
    }
}
