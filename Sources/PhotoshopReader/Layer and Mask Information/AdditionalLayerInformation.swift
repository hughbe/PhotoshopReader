//
//  AdditionalLayerInformation.swift
//  
//
//  Created by Hugh Bellamy on 19/01/2021.
//

import DataStream

public struct AdditionalLayerInformation {
    public let signature: String
    public let key: String
    public let data: DataStream
    public let psb: Bool
    
    public init(dataStream: inout DataStream, psb: Bool) throws {
        /// 4 Signature: '8BIM' or '8B64'
        guard let signature = try dataStream.readString(count: 4, encoding: .ascii) else {
            throw PhotoshopReadError.corrupted
        }
        guard signature == "8BIM" else {
            throw PhotoshopReadError.corrupted
        }
        
        self.signature = signature
        
        /// 4 Key: a 4-character code (See individual sections)
        guard let key = try dataStream.readString(count: 4, encoding: .ascii) else {
            throw PhotoshopReadError.corrupted
        }
        
        self.key = key
        
        /// 4 Length data below, rounded up to an even byte count.
        /// (**PSB**, the following keys have a length count of 8 bytes: LMsk, Lr16, Lr32, Layr, Mt16, Mt32, Mtrn,
        /// Alph, FMsk, lnk2, FEid, FXid, PxSD.
        let length: UInt32 = try dataStream.read(endianess: .bigEndian)
        guard length % 2 == 0 && length <= dataStream.remainingCount else {
            throw PhotoshopReadError.corrupted
        }
                        
        let dataStartPosition = dataStream.position
        
        /// Variable Data (See individual sections)
        self.data = DataStream(slicing: dataStream, startIndex: dataStream.position, count: Int(length))

        self.psb = psb
        
        dataStream.position += Int(length)
        guard dataStream.position - dataStartPosition == length else {
            throw PhotoshopReadError.corrupted
        }
    }
}
