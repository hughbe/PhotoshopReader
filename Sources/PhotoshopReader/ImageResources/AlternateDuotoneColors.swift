//
//  AlternateDuotoneColors
//  
//
//  Created by Hugh Bellamy on 18/01/2021.
//

import DataStream

/// 0x042A 1066 (Photoshop CS) Alternate Duotone Colors. 2 bytes (version = 1), 2 bytes count, following is repeated for each count:
/// [ Color: 2 bytes for space followed by 4 * 2 byte color component ], following this is another 2 byte count, usually 256, followed by Lab colors one byte each for L, a, b. This resource is not read or used by Photoshop.
public struct AlternateDuotoneColors {
    public let version: UInt16
    public let colors: [Color]
    public let labColors: [(UInt8, UInt8, UInt8)]

    public init(dataStream: inout DataStream) throws {
        guard dataStream.remainingCount >= 4 else {
            throw PhotoshopReadError.corrupted
        }
        
        self.version = try dataStream.read(endianess: .bigEndian)
        guard self.version == 1 else {
            throw PhotoshopReadError.corrupted
        }
        
        let count: UInt16 = try dataStream.read(endianess: .bigEndian)
        guard 10 * count <= dataStream.remainingCount else {
            throw PhotoshopReadError.corrupted
        }
        
        var colors: [Color] = []
        colors.reserveCapacity(Int(count))
        for _ in 0..<count {
            colors.append(try Color(dataStream: &dataStream))
        }
        
        self.colors = colors
        
        let labCount: UInt16 = try dataStream.read(endianess: .bigEndian)
        guard 3 * labCount <= dataStream.remainingCount else {
            throw PhotoshopReadError.corrupted
        }
        
        var labColors: [(UInt8, UInt8, UInt8)] = []
        labColors.reserveCapacity(Int(labCount))
        for _ in 0..<labCount {
            labColors.append((try dataStream.read(), try dataStream.read(), try dataStream.read()))
        }
        
        self.labColors = labColors
    }
}
