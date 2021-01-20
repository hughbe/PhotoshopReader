//
//  ChannelImageData.swift
//  
//
//  Created by Hugh Bellamy on 19/01/2021.
//

import DataStream

/// Channel image data
public struct ChannelImageData {
    public let compression: PhotoshopCompression
    public let data: DataStream
    public let layer: Layer
    public let psb: Bool
    
    public init(dataStream: inout DataStream, layer: Layer, channel: Layer.Channel, psb: Bool) throws {
        if channel.length == 0 {
            self.compression = .raw
            self.data = DataStream([])
            self.layer = layer
            self.psb = psb
            return
        }

        guard channel.length >= 2 && channel.length <= dataStream.remainingCount else {
            throw PhotoshopReadError.corrupted
        }

        /// 2 Compression. 0 = Raw Data, 1 = RLE compressed, 2 = ZIP without prediction, 3 = ZIP with prediction.
        self.compression = try PhotoshopCompression(dataStream: &dataStream)
        
        /// Variable Image data.
        /// If the compression code is 0, the image data is just the raw image data, whose size is calculated as
        /// (LayerBottom-LayerTop)* (LayerRight-LayerLeft) (from the first field in See Layer records).
        /// If the compression code is 1, the image data starts with the byte counts for all the scan lines in the channel
        /// (LayerBottom-LayerTop) , with each count stored as a two-byte value.(**PSB** each count stored as a four-byte value.)
        /// The RLE compressed data follows, with each scan line compressed separately. The RLE compression is the same
        /// compression algorithm used by the Macintosh ROM routine PackBits, and the TIFF standard.
        /// If the layer's size, and therefore the data, is odd, a pad byte will be inserted at the end of the row.
        /// If the layer is an adjustment layer, the channel data is undefined (probably all white.)
        self.data = DataStream(slicing: dataStream, startIndex: dataStream.position, count: Int(channel.length - 2))
        dataStream.position += Int(channel.length - 2)
        
        self.layer = layer
        self.psb = psb
    }
    
    public func decompressedData() throws -> [UInt8] {
        switch self.compression {
        case .rleCompressed:
            var dataStream = data
            let scans = layer.bottom - layer.top
            let byteCountsSize = scans * (psb ? 4 : 2)
            guard byteCountsSize <= dataStream.remainingCount else {
                throw PhotoshopReadError.corrupted
            }
            
            func readByteCount(scanLine: UInt32) throws -> Int {
                let oldPosition = dataStream.position
                let newPosition = Int(scanLine) * (psb ? 4 : 2)
                guard newPosition <= dataStream.count else {
                    throw PhotoshopReadError.corrupted
                }
                
                dataStream.position = newPosition
                let value: UInt32
                if psb {
                    value = try dataStream.read(endianess: .bigEndian)
                } else {
                    value = UInt32(try dataStream.read(endianess: .bigEndian) as UInt16)
                }
                
                dataStream.position = oldPosition
                return Int(value)
            }
            
            dataStream.position = Int(byteCountsSize)
            
            var data: [UInt8] = []
            for i in 0..<scans {
                let byteCount = try readByteCount(scanLine: i)
                guard byteCount <= dataStream.remainingCount else {
                    throw PhotoshopReadError.corrupted
                }
                
                var scanDataStream = DataStream(slicing: dataStream, startIndex: dataStream.position, count: byteCount)
                try PackBits.decompress(dataStream: &scanDataStream, into: &data)
                dataStream.position += byteCount
            }
            
            return data
        default:
            fatalError("NYI: \(self.compression)")
        }
    }
}
