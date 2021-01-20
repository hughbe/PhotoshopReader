//
//  PhotoshopCompression.swift
//  
//
//  Created by Hugh Bellamy on 19/01/2021.
//

/// 2 Compression method:
/// 0 = Raw image data
/// 1 = RLE compressed the image data starts with the byte counts for all the scan lines (rows * channels), with each count
/// stored as a two-byte value. The RLE compressed data follows, with each scan line compressed separately. The RLE
/// compression is the same compression algorithm used by the Macintosh ROM routine PackBits , and the TIFF standard.
/// 2 = ZIP without prediction
/// 3 = ZIP with prediction.
public enum PhotoshopCompression: UInt16, DataStreamCreatable {
    case raw = 0
    case rleCompressed = 1
    case zipWithoutPrediction = 2
    case zipWithPrediction = 3
}
