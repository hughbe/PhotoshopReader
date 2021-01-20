//
//  TypeToolInfo.swift
//  
//
//  Created by Hugh Bellamy on 19/01/2021.
//

import DataStream

/// Type Tool Info (Photoshop 5.0 and 5.5 only)
/// Has been superseded in Photoshop 6.0 and beyond by a different structure with the key 'TySh' (see See
/// Type tool object setting (Photoshop 6.0) See Type tool object setting ).
/// Key is 'tySh' . Data is as follows:
public struct TypeToolInfo {
    public let version: UInt16
    public let transform: TypeToolTransform
    public let fontInformation: FontInformation
    public let styleInformation: [Style]
    public let textInformation: TextInformation
    public let colorInformation: ColorInformation
    
    public init(dataStream: inout DataStream) throws {
        guard dataStream.remainingCount >= 50 else {
            throw PhotoshopReadError.corrupted
        }
        
        /// 2 Version ( = 1)
        self.version = try dataStream.read(endianess: .bigEndian)
        
        /// 48 6 * 8 double precision numbers for the transform information
        self.transform = try TypeToolTransform(dataStream: &dataStream)
        
        /// Font information
        self.fontInformation = try FontInformation(dataStream: &dataStream)
        
        /// Style information
        /// 2 Count of styles
        let styleCount: UInt16 = try dataStream.read(endianess: .bigEndian)
        guard styleCount * (26 + version <= 5 ? 1 : 0) <= dataStream.remainingCount else {
            throw PhotoshopReadError.corrupted
        }
        
        /// The next 10 fields are repeated for each count specified above
        var styleInformation: [Style] = []
        styleInformation.reserveCapacity(Int(styleCount))
        for _ in 0..<styleCount {
            styleInformation.append(try Style(dataStream: &dataStream, version: self.version))
        }
        
        self.styleInformation = styleInformation
        
        /// Text information
        self.textInformation = try TextInformation(dataStream: &dataStream)
        
        /// Color information
        self.colorInformation = try ColorInformation(dataStream: &dataStream)
        
        /// Remaining information.
        dataStream.position = dataStream.count
    }
    
    /// Font information
    public struct FontInformation {
        public let version: UInt16
        public let faces: [FontFace]
        
        public init(dataStream: inout DataStream) throws {
            guard dataStream.remainingCount >= 4 else {
                throw PhotoshopReadError.corrupted
            }
            
            /// 2 Version ( = 6)
            self.version = try dataStream.read(endianess: .bigEndian)
            
            /// 2 Count of faces
            let faceCount: UInt16 = try dataStream.read(endianess: .bigEndian)
            guard faceCount * 18 <= dataStream.remainingCount else {
                throw PhotoshopReadError.corrupted
            }
            
            /// The next 8 fields are repeated for each count specified above
            var faces: [FontFace] = []
            faces.reserveCapacity(Int(faceCount))
            for _ in 0..<faceCount {
                faces.append(try FontFace(dataStream: &dataStream))
            }

            self.faces = faces
        }
        
        /// The next 8 fields are repeated for each count specified above
        public struct FontFace {
            public let mark: UInt16
            public let fontTypeData: UInt32
            public let name: String
            public let familyName: String
            public let styleName: String
            public let script: UInt16
            public let designVectors: [UInt32]
            
            public init(dataStream: inout DataStream) throws {
                guard dataStream.remainingCount >= 15 else {
                    throw PhotoshopReadError.corrupted
                }
                
                /// 2 Mark value
                self.mark = try dataStream.read(endianess: .bigEndian)
                
                /// 4 Font type data
                self.fontTypeData = try dataStream.read(endianess: .bigEndian)
    
                /// Variable Pascal string of font name
                self.name = try dataStream.readPascalString()
                
                /// Variable Pascal string of font family name
                self.familyName = try dataStream.readPascalString()
                
                /// Variable Pascal string of font style name
                self.styleName = try dataStream.readPascalString()
                
                /// 2 Script value
                self.script = try dataStream.read(endianess: .bigEndian)
                
                /// 4 Number of design axes vector to follow
                let numberOfDesignAxesVectors: UInt32 = try dataStream.read(endianess: .bigEndian)
                guard numberOfDesignAxesVectors * 4 <= dataStream.remainingCount else {
                    throw PhotoshopReadError.corrupted
                }
                
                /// 4 Design vector value
                var designVectors: [UInt32] = []
                designVectors.reserveCapacity(Int(numberOfDesignAxesVectors))
                for _ in 0..<numberOfDesignAxesVectors {
                    designVectors.append(try dataStream.read(endianess: .bigEndian))
                }
                
                self.designVectors = designVectors
            }
        }
    }
    
    /// Style information
    /// The next 10 fields are repeated for each count specified above
    public struct Style {
        public let mark: UInt16
        public let faceMark: UInt16
        public let size: UInt32
        public let tracking: UInt32
        public let kerning: UInt32
        public let leading: UInt32
        public let baseShift: UInt32
        public let autoKernOn: Bool
        public let reserved: Bool?
        public let rotateUpDown: Bool?
        
        public init(dataStream: inout DataStream, version: UInt16) throws {
            guard dataStream.remainingCount >= 26 + (version <= 5 ? 1 : 10) else {
                throw PhotoshopReadError.corrupted
            }

            /// 2 Mark value
            self.mark = try dataStream.read(endianess: .bigEndian)
            
            /// 2 Face mark value
            self.faceMark = try dataStream.read(endianess: .bigEndian)
            
            /// 4 Size value
            self.size = try dataStream.read(endianess: .bigEndian)
            
            /// 4 Tracking value
            self.tracking = try dataStream.read(endianess: .bigEndian)
            
            /// 4 Kerning value
            self.kerning = try dataStream.read(endianess: .bigEndian)
            
            /// 4 Leading value
            self.leading = try dataStream.read(endianess: .bigEndian)
            
            /// 4 Base shift value
            self.baseShift = try dataStream.read(endianess: .bigEndian)
            
            /// 1 Auto kern on/off
            self.autoKernOn = try dataStream.read() as UInt8 != 0
            
            /// 1 Only present in version <= 5
            if version <= 5 {
                self.reserved = try dataStream.read() as UInt8 != 0
            } else {
                self.reserved = nil
            }

            /// 1 Rotate up/down
            self.rotateUpDown = try dataStream.read() as UInt8 != 0
        }
    }
    
    /// Text information
    public struct TextInformation {
        public let type: UInt16
        public let scalingFactor: UInt32
        public let sharacterCount: UInt32
        public let horizontalPlacement: UInt32
        public let verticalPlacement: UInt32
        public let selectStart: UInt32
        public let selectEnd: UInt32
        public let lines: [Line]
        
        public init(dataStream: inout DataStream) throws {
            guard dataStream.remainingCount >= 28 else {
                throw PhotoshopReadError.corrupted
            }

            /// 2 Type value
            self.type = try dataStream.read(endianess: .bigEndian)
            
            /// 4 Scaling factor value
            self.scalingFactor = try dataStream.read(endianess: .bigEndian)
            
            /// 4 Sharacter count value
            self.sharacterCount = try dataStream.read(endianess: .bigEndian)
            
            /// 4 Horizontal placement
            self.horizontalPlacement = try dataStream.read(endianess: .bigEndian)
            
            /// 4 Vertical placement
            self.verticalPlacement = try dataStream.read(endianess: .bigEndian)
            
            /// 4 Select start value
            self.selectStart = try dataStream.read(endianess: .bigEndian)
            
            /// 4 Select end value
            self.selectEnd = try dataStream.read(endianess: .bigEndian)
            
            /// 2 Line count, i.e. the number of items to follow.
            let lineCount: UInt16 = try dataStream.read(endianess: .bigEndian)
            guard lineCount * 12 <= dataStream.remainingCount else {
                throw PhotoshopReadError.corrupted
            }
            
            /// The next 5 fields are repeated for each item in line count.
            var lines: [Line] = []
            lines.reserveCapacity(Int(lineCount))
            for _ in 0..<lineCount {
                lines.append(try Line(dataStream: &dataStream))
            }

            self.lines = lines
        }
        
        /// The next 5 fields are repeated for each item in line count.
        public struct Line {
            public let characterCount: UInt32
            public let orientation: UInt16
            public let alignment: UInt16
            public let actualCharacter: UInt16
            public let style: UInt16
            
            public init(dataStream: inout DataStream) throws {
                guard dataStream.remainingCount >= 12 else {
                    throw PhotoshopReadError.corrupted
                }

                /// 4 Character count value
                self.characterCount = try dataStream.read(endianess: .bigEndian)
                
                /// 2 Orientation value
                self.orientation = try dataStream.read(endianess: .bigEndian)
                
                /// 2 Alignment value
                self.alignment = try dataStream.read(endianess: .bigEndian)
                
                /// 2 Actual character as a double byte character
                self.actualCharacter = try dataStream.read(endianess: .bigEndian)
                
                /// 2 Style value
                self.style = try dataStream.read(endianess: .bigEndian)
            }
        }
    }
    
    /// Color information
    public struct ColorInformation {
        public let color: Color
        public let antiAlias: Bool
        
        public init(dataStream: inout DataStream) throws {
            guard dataStream.remainingCount >= 9 else {
                throw PhotoshopReadError.corrupted
            }
            
            /// 2 Color space value
            /// 8 4 * 2 byte color component
            self.color = try Color(dataStream: &dataStream)
            
            /// 1 Anti alias on/off
            self.antiAlias = try dataStream.read() as UInt8 != 0
        }
    }
}
