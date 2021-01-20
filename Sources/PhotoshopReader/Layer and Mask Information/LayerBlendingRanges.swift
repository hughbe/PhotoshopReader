//
//  DataStream.swift
//  
//
//  Created by Hugh Bellamy on 19/01/2021.
//

import DataStream

/// Variable  Layer blending ranges: See See Layer blending ranges data.
public struct LayerBlendingRanges {
    public let length: UInt32
    public let compositeGrayBlendSource: BlackAndWhite?
    public let compositeGrayBlendDestinationRange: BlackAndWhite?
    public let channelInformation: [BlackAndWhite]
    
    public init(dataStream: inout DataStream) throws {
        guard dataStream.remainingCount >= 12 else {
            throw PhotoshopReadError.corrupted
        }
        
        /// 4 Length of layer blending ranges data
        let length: UInt32 = try dataStream.read(endianess: .bigEndian)
        if length == 0 {
            self.length = length
            self.compositeGrayBlendSource = nil
            self.compositeGrayBlendDestinationRange = nil
            self.channelInformation = []
            return
        }
        guard length >= 8 && (length - 8) % 8 == 0 && length <= dataStream.remainingCount else {
            throw PhotoshopReadError.corrupted
        }
        
        self.length = length
        
        let startPosition = dataStream.position
        
        /// 4 Composite gray blend source. Contains 2 black values followed by 2 white values. Present but irrelevant for Lab & Grayscale.
        self.compositeGrayBlendSource = try BlackAndWhite(dataStream: &dataStream)
        
        /// 4 Composite gray blend destination range
        self.compositeGrayBlendDestinationRange = try BlackAndWhite(dataStream: &dataStream)

        /// 4 First channel source range
        /// 4 First channel destination range
        /// 4 Second channel source range
        /// 4 Second channel destination range
        /// ...
        /// ...
        /// 4 Nth channel source range
        /// 4 Nth channel destination range
        var channelInformation: [BlackAndWhite] = []
        while dataStream.position - startPosition < length {
            channelInformation.append(try BlackAndWhite(dataStream: &dataStream))
        }
        
        self.channelInformation = channelInformation
        
        guard dataStream.position - startPosition == self.length else {
            throw PhotoshopReadError.corrupted
        }
    }
    
    public struct BlackAndWhite {
        public let black: UInt16
        public let white: UInt16
        
        public init(dataStream: inout DataStream) throws {
            self.black = try dataStream.read(endianess: .bigEndian)
            self.white = try dataStream.read(endianess: .bigEndian)
        }
    }
}

