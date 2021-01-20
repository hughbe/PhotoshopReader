//
//  ResolutionInfo.swift
//  
//
//  Created by Hugh Bellamy on 18/01/2021.
//


import DataStream

/// ResolutionInfo
/// This structure contains information about the resolution of an image. It is written as an image resource.
/// See the Document file formats chapter for more details.
/// https://usermanual.wiki/Document/Photoshop20API20Guide.1445764450/view
public struct ResolutionInfo {
    public let hRes: UInt32
    public let hResUnit: ResolutionUnit
    public let widthUnit: DimensionUnit
    public let vRes: UInt32
    public let vResUnit: ResolutionUnit
    public let heightUnit: DimensionUnit
    
    public init(dataStream: inout DataStream) throws {
        guard dataStream.remainingCount >= 16 else {
            throw PhotoshopReadError.corrupted
        }
        
        /// Fixed hRes Horizontal resolution in pixels per inch.
        self.hRes = try dataStream.read(endianess: .bigEndian)
        
        /// int16 hResUnit 1=display horitzontal resolution in pixels per inch; 2=dis-play horitzontal resolution in pixels per cm.
        self.hResUnit = try ResolutionUnit(dataStream: &dataStream)
        
        /// int16 widthUnit Display width as 1=inches; 2=cm; 3=points; 4=picas; 5=columns.
        self.widthUnit = try DimensionUnit(dataStream: &dataStream)
        
        /// Fixed vRes Vertial resolution in pixels per inch.
        self.vRes = try dataStream.read(endianess: .bigEndian)
        
        /// int16 vResUnit 1=display vertical resolution in pixels per inch; 2=display vertical resolution in pixels per cm.
        self.vResUnit = try ResolutionUnit(dataStream: &dataStream)
        
        /// int16 heightUnit Display height as 1=inches; 2=cm; 3=points; 4=picas; 5=columns.
        self.heightUnit = try DimensionUnit(dataStream: &dataStream)
    }
    
    public enum ResolutionUnit: UInt16, DataStreamCreatable {
        case pixelsPerInch = 1
        case pixelsPerCm = 2
    }
}
