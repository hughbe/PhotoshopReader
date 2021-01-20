//
//  ChannelMixer.swift
//  
//
//  Created by Hugh Bellamy on 19/01/2021.
//

import DataStream

/// Channel Mixer
/// Key is 'mixr' . Data is as follows:
public struct ChannelMixer {
    public let version: UInt16
    public let monochrome: UInt16
    public let colors: [UInt8]
    
    public init(dataStream: inout DataStream) throws {
        /// 2 Version ( = 1)
        let version: UInt16 = try dataStream.read(endianess: .bigEndian)
        guard version == 0 || version == 1 else {
            throw PhotoshopReadError.corrupted
        }
        
        self.version = version
        
        /// 2 Monochrome
        self.monochrome = try dataStream.read(endianess: .bigEndian)
        
        /// 20 RGB or CMYK color plus constant for the mixer settings. 4 * 2 bytes of color with 2 bytes of constant.
        self.colors = try dataStream.readBytes(count: dataStream.remainingCount)
    }
}
