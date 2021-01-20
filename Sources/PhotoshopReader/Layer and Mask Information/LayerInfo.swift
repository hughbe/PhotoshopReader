//
//  LayerInfo.swift
//  
//
//  Created by Hugh Bellamy on 18/01/2021.
//

import DataStream

/// Layer info
public struct LayerInfo {
    public let length: UInt64
    public let layerCount: Int16
    public let layers: [Layer]
    public let channelImageData: [ChannelImageData]
    
    public init(dataStream: inout DataStream, psb: Bool) throws {
        /// 4 Length of the layers info section, rounded up to a multiple of 2. (**PSB** length is 8 bytes.)
        if psb {
            self.length = try dataStream.read(endianess: .bigEndian)
        } else {
            self.length = UInt64(try dataStream.read(endianess: .bigEndian) as UInt32)
        }
        guard self.length <= dataStream.remainingCount else {
            throw PhotoshopReadError.corrupted
        }
        
        if self.length == 0 {
            self.layerCount = 0
            self.layers = []
            self.channelImageData = []
            return
        }
        
        let startPosition = dataStream.position
        var dataDataStream = DataStream(slicing: dataStream, startIndex: dataStream.position, count: Int(self.length))
        
        /// 2 Layer count. If it is a negative number, its absolute value is the number of layers and the first alpha channel contains the
        /// transparency data for the merged result.
        self.layerCount = try dataDataStream.read(endianess: .bigEndian)
        let actualLayerCount = Int(abs(layerCount))
        
        /// Variable Information about each layer. See Layer records describes the structure of this information for each layer.
        var layers: [Layer] = []
        layers.reserveCapacity(actualLayerCount)
        for _ in 0..<actualLayerCount {
            layers.append(try Layer(dataStream: &dataDataStream, psb: psb))
        }
        
        self.layers = layers
        
        /// Variable Channel image data. Contains one or more image data records (see See Channel image data for structure) for
        /// each layer. The layers are in the same order as in the layer information (previous row of this table).
        var channelImageData: [ChannelImageData] = []
        channelImageData.reserveCapacity(actualLayerCount)
        for i in 0..<Int(actualLayerCount) {
            for channel in layers[i].channels {
                guard channel.length <= dataDataStream.remainingCount else {
                    throw PhotoshopReadError.corrupted
                }
                
                var channelDataStream = DataStream(slicing: dataDataStream, startIndex: dataDataStream.position, count: Int(channel.length))
                channelImageData.append(try ChannelImageData(dataStream: &channelDataStream, layer: layers[Int(i)], channel: channel, psb: psb))
                dataDataStream.position += Int(channel.length)
            }
        }
        
        self.channelImageData = channelImageData

        if dataDataStream.remainingCount != 0 {
            try dataDataStream.readTwoByteAlignmentPadding(startPosition: startPosition)
        }

        dataStream.position += Int(self.length)
    }
}
