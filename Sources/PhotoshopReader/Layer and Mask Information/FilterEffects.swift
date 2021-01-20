//
//  FilterEffects.swift
//  
//
//  Created by Hugh Bellamy on 20/01/2021.
//

import DataStream

/// Filter Effects
/// Key is 'FXid' or 'FEid' .
public struct FilterEffects {
    public let version: UInt32
    public let length: UInt64
    public let effects: [FilterEffect]
    public let hasData: Bool
    public let compression: PhotoshopCompression?
    public let data: DataStream?
    
    public init(dataStream: inout DataStream) throws {
        guard dataStream.remainingCount >= 12 else {
            throw PhotoshopReadError.corrupted
        }
        
        /// 4 Version ( =1, 2 or 3)
        let version: UInt32 = try dataStream.read(endianess: .bigEndian)
        guard version == 1 || version == 2 || version == 3 else {
            throw PhotoshopReadError.corrupted
        }
        
        self.version = version
        
        /// 8 Length of data to follow
        self.length = try dataStream.read(endianess: .bigEndian)
        guard self.length <= dataStream.remainingCount else {
            throw PhotoshopReadError.corrupted
        }
        
        let startPosition = dataStream.position
        
        /// The following is repeated for the given length.
        var effects: [FilterEffect] = []
        while dataStream.position - startPosition < self.length {
            effects.append(try FilterEffect(dataStream: &dataStream))
        }
        
        self.effects = effects
        
        guard dataStream.position - startPosition == self.length else {
            throw PhotoshopReadError.corrupted
        }
        
        /// 1 Next two items present or not
        self.hasData = try dataStream.read() as UInt8 != 0
        if !self.hasData {
            self.compression = nil
            self.data = nil
            return
        }
        
        /// 2 Compression mode of data to follow
        self.compression = try PhotoshopCompression(dataStream: &dataStream)
        
        /// Variable Actual data based on compression
        self.data = DataStream(slicing: dataStream, startIndex: dataStream.position, count: dataStream.remainingCount)
        dataStream.position += dataStream.remainingCount
    }
    
    public struct FilterEffect {
        public let identifier: String
        public let version: UInt32
        public let top: Int32
        public let left: Int32
        public let bottom: Int32
        public let right: Int32
        public let length: UInt64
        public let depth: UInt32
        public let maxChannels: UInt32
        public let data: [Data]
        
        public init(dataStream: inout DataStream) throws {
            guard dataStream.remainingCount >= 37 else {
                throw PhotoshopReadError.corrupted
            }
            
            /// Variable Pascal string as identifier
            self.identifier = try dataStream.readPascalString()
            
            /// 4 Version ( = 1 )
            self.version = try dataStream.read(endianess: .bigEndian)
            guard self.version == 1 else {
                throw PhotoshopReadError.corrupted
            }
            
            /// 8 Length
            self.length = try dataStream.read(endianess: .bigEndian)
            guard self.length <= dataStream.remainingCount else {
                throw PhotoshopReadError.corrupted
            }
            
            let startPosition = dataStream.position
            
            /// 16 Rectangle: top, left, bottom, right
            self.top = try dataStream.read(endianess: .bigEndian)
            self.left = try dataStream.read(endianess: .bigEndian)
            self.bottom = try dataStream.read(endianess: .bigEndian)
            self.right = try dataStream.read(endianess: .bigEndian)
            
            /// 4 Depth
            self.depth = try dataStream.read(endianess: .bigEndian)

            /// 4 Max channels
            self.maxChannels = try dataStream.read(endianess: .bigEndian)
            
            /// The following is repeated for number of channels + a user mask + a sheet mask.
            var data: [Data] = []
            while dataStream.position - startPosition < self.length {
                data.append(try Data(dataStream: &dataStream))
            }
            
            self.data = data
            
            /// End of repeating for channels
            
            guard dataStream.position - startPosition == self.length else {
                throw PhotoshopReadError.corrupted
            }
        }
        
        /// The following is repeated for number of channels + a user mask + a sheet mask.
        public struct Data {
            public let written: Bool
            public let length: UInt64
            public let compression: PhotoshopCompression
            public let data: DataStream
            
            public init(dataStream: inout DataStream) throws {
                guard dataStream.remainingCount >= 12 else {
                    throw PhotoshopReadError.corrupted
                }
                
                /// 4 Boolean indicating whether array is written
                self.written = try dataStream.read(endianess: .bigEndian) as UInt32 != 0
                
                /// 8 Length
                let length: UInt64 = try dataStream.read(endianess: .bigEndian)
                guard length >= 2 && length <= dataStream.remainingCount else {
                    throw PhotoshopReadError.corrupted
                }
                
                self.length = length
                
                let startPosition = dataStream.position
                
                /// 2 Compression mode of data to follow.
                self.compression = try PhotoshopCompression(dataStream: &dataStream)
                
                /// Variable Actual data based on compression
                self.data = DataStream(slicing: dataStream, startIndex: dataStream.position, count: Int(self.length - 2))
                dataStream.position += Int(self.length) - 2
                
                guard dataStream.position - startPosition == self.length else {
                    throw PhotoshopReadError.corrupted
                }
            }
        }
    }
}
