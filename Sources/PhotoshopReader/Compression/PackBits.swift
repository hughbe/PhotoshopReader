//
//  PackBits.swift
//  
//
//  Created by Hugh Bellamy on 19/01/2021.
//

import DataStream

/// https://www.fileformat.info/format/tiff/corion-packbits.htm
public struct PackBits {
    public static func decompress(dataStream: inout DataStream, into destination: inout [UInt8]) throws {
        while dataStream.remainingCount > 0 {
            /// A pseudo code fragment to unpack might look like this:
            /// Loop  until  you  get  the  number  of  unpacked  bytes  you  are expecting:
            /// Read the next source byte into n.
            ///     If n is between 0 and 127 inclusive, copy the next n+1 bytes literally.
            ///     Else if  n is  between -127  and -1 inclusive, copy the next byte -n+1 times.
            ///     Else if n is 128, noop.
            /// Endloop
            let header: Int8 = try dataStream.read()
            if header >= 0 && header <= 127 {
                let count = Int(header)
                destination.reserveCapacity(destination.capacity + count)
                destination.append(contentsOf: try dataStream.readBytes(count: count))
            } else if header >= -127 && header <= -1 {
                let count = Int(abs(header)) + 1
                let nextByte: UInt8 = try dataStream.read()
                
                destination.reserveCapacity(destination.capacity + count)
                for _ in 0..<count {
                    destination.append(nextByte)
                }
            } else {
                return
            }
        }
    }
}
