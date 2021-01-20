//
//  EffectsLayer.swift
//  
//
//  Created by Hugh Bellamy on 19/01/2021.
//

import DataStream

/// Effects Layer (Photoshop 5.0)
/// The key for the effects layer is 'lrFX' . The data has the following format:
/// Effects Layer info
public struct EffectsLayer {
    public let version: UInt16
    public let effects: [Effect]
    
    public init(dataStream: inout DataStream) throws {
        let startPosition = dataStream.position
        
        /// 2 Version: 0
        self.version = try dataStream.read(endianess: .bigEndian)
        guard self.version == 0 else {
            throw PhotoshopReadError.corrupted
        }
        
        /// 2 Effects count: may be 6 (for the 6 effects in Photoshop 5 and 6) or 7 (for Photoshop 7.0)
        let effectsCount: UInt16 = try dataStream.read(endianess: .bigEndian)
        
        /// The next three items are repeated for each of the effects.
        var effects: [Effect] = []
        effects.reserveCapacity(Int(effectsCount))
        for _ in 0..<effectsCount {
            effects.append(try Effect(dataStream: &dataStream))
        }
        
        self.effects = effects
        
        try dataStream.readFourByteAlignmentPadding(startPosition: startPosition)
    }
    
    public struct Effect {
        public let signature: String
        public let effectsSignature: String
        public let data: EffectsData
        
        public init(dataStream: inout DataStream) throws {
            /// 4 Signature: '8BIM'
            guard let signature = try dataStream.readString(count: 4, encoding: .ascii) else {
                throw PhotoshopReadError.corrupted
            }
            
            self.signature = signature
            
            /// 4 Effects signatures: OSType key for which effects type to use:
            guard let effectsSignature = try dataStream.readString(count: 4, encoding: .ascii) else {
                throw PhotoshopReadError.corrupted
            }
            
            self.effectsSignature = effectsSignature
            
            /// Variable See appropriate tables.
            self.data = try EffectsData(dataStream: &dataStream, signature: self.effectsSignature)
        }
        
        /// 4 Effects signatures: OSType key for which effects type to use:
        public enum EffectsSignature: String {
            /// 'cmnS' = common state (see See Effects layer, common state info)
            case commonState = "cmmS"
            
            /// 'dsdw' = drop shadow (see See Effects layer, drop shadow and inner shadow info)
            case dropShadow = "dsdw"
            
            /// 'isdw' = inner shadow (see See Effects layer, drop shadow and inner shadow info)
            case innerShadow = "isdw"
            
            /// 'oglw' = outer glow (see See Effects layer, outer glow info)
            case outerGlow = "oglw"
            
            /// 'iglw' = inner glow (see See Effects layer, inner glow info)
            case innerGlow = "iglw"
            
            /// 'bevl' = bevel (see See Effects layer, bevel info)
            case bevel = "bevl"
            
            /// 'sofi' = solid fill ( Photoshop 7.0) (see See Effects layer, solid fill (added in Photoshop 7.0))
            case solidFill = "sofi"
        }
        
        public enum EffectsData {
            case commonState(_: CommonStateInfo)
            case dropShadow(_: ShadowInfo)
            case innerShadow(_: ShadowInfo)
            case outerGlow(_: OuterGlowInfo)
            case innerGlow(_: InnerGlowInfo)
            case bevel(_: BevelInfo)
            case solidFill(_: SolidFill)
            case unknown(_: [UInt8])
            
            public init(dataStream: inout DataStream, signature: String) throws {
                guard let knownSignature = EffectsSignature(rawValue: signature) else {
                    let size: UInt32 = try dataStream.read(endianess: .bigEndian)
                    self = .unknown(try dataStream.readBytes(count: Int(size)))
                    return
                }
                
                switch knownSignature {
                case .commonState:
                    /// 'cmnS' = common state (see See Effects layer, common state info)
                    self = .commonState(try CommonStateInfo(dataStream: &dataStream))
                case .dropShadow:
                    /// 'dsdw' = drop shadow (see See Effects layer, drop shadow and inner shadow info)
                    self = .dropShadow(try ShadowInfo(dataStream: &dataStream))
                case .innerShadow:
                    /// 'isdw' = inner shadow (see See Effects layer, drop shadow and inner shadow info)
                    self = .innerShadow(try ShadowInfo(dataStream: &dataStream))
                case .outerGlow:
                    /// 'oglw' = outer glow (see See Effects layer, outer glow info)
                    self = .outerGlow(try OuterGlowInfo(dataStream: &dataStream))
                case .innerGlow:
                    /// 'iglw' = inner glow (see See Effects layer, inner glow info)
                    self = .innerGlow(try InnerGlowInfo(dataStream: &dataStream))
                case .bevel:
                    /// 'bevl' = bevel (see See Effects layer, bevel info)
                    self = .bevel(try BevelInfo(dataStream: &dataStream))
                case .solidFill:
                    /// 'sofi' = solid fill ( Photoshop 7.0) (see See Effects layer, solid fill (added in Photoshop 7.0))
                    self = .solidFill(try SolidFill(dataStream: &dataStream))
                }
            }
        }
        
        /// Effects layer, common state info
        public struct CommonStateInfo {
            public let size: UInt32
            public let version: UInt32
            public let visible: Bool
            public let unused: UInt16
            
            public init(dataStream: inout DataStream) throws {
                /// 4 Size of next three items: 7
                let size: UInt32 = try dataStream.read(endianess: .bigEndian)
                guard size == 7 && size <= dataStream.remainingCount else {
                    throw PhotoshopReadError.corrupted
                }
                
                self.size = size
                
                let startPosition = dataStream.position

                /// 4 Version: 0
                self.version = try dataStream.read(endianess: .bigEndian)
                guard self.version == 0 else {
                    throw PhotoshopReadError.corrupted
                }

                /// 1 Visible: always true
                self.visible = try dataStream.read() as UInt8 != 0

                /// 2 Unused: always 0
                self.unused = try dataStream.read(endianess: .bigEndian)
                
                guard dataStream.position - startPosition == self.size else {
                    throw PhotoshopReadError.corrupted
                }
            }
        }
        
        /// Effects layer, drop shadow and inner shadow info
        public struct ShadowInfo {
            public let size: UInt32
            public let version: UInt32
            public let blurValue: UInt32
            public let intensity: UInt32
            public let angle: UInt32
            public let distance: UInt32
            public let color: Color
            public let blendModeSignature: String
            public let blendModeKey: String
            public let enabled: Bool
            public let useAngleInAllLayerEffects: Bool
            public let opacity: UInt8
            public let nativeColor: Color?
            
            public init(dataStream: inout DataStream) throws {
                /// 4 Size of the remaining items: 41 or 51 (depending on version)
                let size: UInt32 = try dataStream.read(endianess: .bigEndian)
                guard (size == 41 || size == 51) && size <= dataStream.remainingCount else {
                    throw PhotoshopReadError.corrupted
                }
                
                self.size = size
                
                let startPosition = dataStream.position
                
                /// 4 Version: 0 ( Photoshop 5.0) or 2 ( Photoshop 5.5)
                let version: UInt32 = try dataStream.read(endianess: .bigEndian)
                guard (version == 0 && size == 41) || (version == 2 && size == 51) else {
                    throw PhotoshopReadError.corrupted
                }
                
                self.version = version
                
                /// 4 Blur value in pixels
                self.blurValue = try dataStream.read(endianess: .bigEndian)

                /// 4 Intensity as a percent
                self.intensity = try dataStream.read(endianess: .bigEndian)

                /// 4 Angle in degrees
                self.angle = try dataStream.read(endianess: .bigEndian)

                /// 4 Distance in pixels
                self.distance = try dataStream.read(endianess: .bigEndian)

                /// 10 Color: 2 bytes for space followed by 4 * 2 byte color component
                self.color = try Color(dataStream: &dataStream)

                /// 8 Blend mode: 4 bytes for signature and 4 bytes for key
                guard let blendModeSignature = try dataStream.readString(count: 4, encoding: .ascii) else {
                    throw PhotoshopReadError.corrupted
                }
                guard blendModeSignature == "8BIM" else {
                    throw PhotoshopReadError.corrupted
                }
                
                self.blendModeSignature = blendModeSignature
    
                guard let blendModeKey = try dataStream.readString(count: 4, encoding: .ascii) else {
                    throw PhotoshopReadError.corrupted
                }
                
                self.blendModeKey = blendModeKey
                
                /// 1 Effect enabled
                self.enabled = try dataStream.read() as UInt8 != 0

                /// 1 Use this angle in all of the layer effects
                self.useAngleInAllLayerEffects = try dataStream.read() as UInt8 != 0

                /// 1 Opacity as a percent
                self.opacity = try dataStream.read()

                if self.version == 0 {
                    self.nativeColor = nil
                    return
                }
                
                /// 10 Native color: 2 bytes for space followed by 4 * 2 byte color component
                self.nativeColor = try Color(dataStream: &dataStream)
                
                guard dataStream.position - startPosition == self.size else {
                    throw PhotoshopReadError.corrupted
                }
            }
        }
        
        /// Effects layer, outer glow info
        public struct OuterGlowInfo {
            public let size: UInt32
            public let version: UInt32
            public let blurValue: UInt32
            public let intensity: UInt32
            public let color: Color
            public let blendModeSignature: String
            public let blendModeKey: String
            public let enabled: Bool
            public let opacity: UInt8
            public let nativeColor: Color?
            
            public init(dataStream: inout DataStream) throws {
                /// 4 Size of the remaining items: 32 for Photoshop 5.0; 42 for 5.5
                let size: UInt32 = try dataStream.read(endianess: .bigEndian)
                guard (size == 32 || size == 42) && size <= dataStream.remainingCount else {
                    throw PhotoshopReadError.corrupted
                }
                
                self.size = size
                
                let startPosition = dataStream.position
                
                /// 4 Version: 0 for Photoshop 5.0; 2 for 5.5.
                let version: UInt32 = try dataStream.read(endianess: .bigEndian)
                guard (version == 0 && size == 32) || (version == 2 && size == 42) else {
                    throw PhotoshopReadError.corrupted
                }
                
                self.version = version
                
                /// 4 Blur value in pixels.
                self.blurValue = try dataStream.read(endianess: .bigEndian)

                /// 4 Intensity as a percent
                self.intensity = try dataStream.read(endianess: .bigEndian)

                /// 10 Color: 2 bytes for space followed by 4 * 2 byte color component
                self.color = try Color(dataStream: &dataStream)

                /// 8 Blend mode: 4 bytes for signature and 4 bytes for key
                guard let blendModeSignature = try dataStream.readString(count: 4, encoding: .ascii) else {
                    throw PhotoshopReadError.corrupted
                }
                guard blendModeSignature == "8BIM" else {
                    throw PhotoshopReadError.corrupted
                }
                
                self.blendModeSignature = blendModeSignature
    
                guard let blendModeKey = try dataStream.readString(count: 4, encoding: .ascii) else {
                    throw PhotoshopReadError.corrupted
                }
                
                self.blendModeKey = blendModeKey
                
                /// 1 Effect enabled
                self.enabled = try dataStream.read() as UInt8 != 0

                /// 1 Opacity as a percent
                self.opacity = try dataStream.read()

                if self.version == 0 {
                    self.nativeColor = nil
                    return
                }
                
                /// 10 (Version 2 only) Native color space. 2 bytes for space followed by 4 * 2 byte color componentw
                self.nativeColor = try Color(dataStream: &dataStream)
                
                guard dataStream.position - startPosition == self.size else {
                    throw PhotoshopReadError.corrupted
                }
            }
        }
        
        /// Effects layer, inner glow info
        public struct InnerGlowInfo {
            public let size: UInt32
            public let version: UInt32
            public let blurValue: UInt32
            public let intensity: UInt32
            public let color: Color
            public let blendModeSignature: String
            public let blendModeKey: String
            public let enabled: Bool
            public let opacity: UInt8
            public let invert: Bool
            public let nativeColor: Color?
            
            public init(dataStream: inout DataStream) throws {
                /// 4 Size of the remaining items: 33 for Photoshop 5.0; 43 for 5.5
                let size: UInt32 = try dataStream.read(endianess: .bigEndian)
                guard (size == 33 || size == 43) && size <= dataStream.remainingCount else {
                    throw PhotoshopReadError.corrupted
                }
                
                self.size = size
                
                let startPosition = dataStream.position
                
                /// 4 Version: 0 for Photoshop 5.0; 2 for 5.5.
                let version: UInt32 = try dataStream.read(endianess: .bigEndian)
                guard (version == 0 && size == 33) || (version == 2 && size == 43) else {
                    throw PhotoshopReadError.corrupted
                }
                
                self.version = version
                
                /// 4 Blur value in pixels.
                self.blurValue = try dataStream.read(endianess: .bigEndian)

                /// 4 Intensity as a percent
                self.intensity = try dataStream.read(endianess: .bigEndian)

                /// 10 Color: 2 bytes for space followed by 4 * 2 byte color component
                self.color = try Color(dataStream: &dataStream)

                /// 8 Blend mode: 4 bytes for signature and 4 bytes for key
                guard let blendModeSignature = try dataStream.readString(count: 4, encoding: .ascii) else {
                    throw PhotoshopReadError.corrupted
                }
                guard blendModeSignature == "8BIM" else {
                    throw PhotoshopReadError.corrupted
                }
                
                self.blendModeSignature = blendModeSignature
    
                guard let blendModeKey = try dataStream.readString(count: 4, encoding: .ascii) else {
                    throw PhotoshopReadError.corrupted
                }
                
                self.blendModeKey = blendModeKey
                
                /// 1 Effect enabled
                self.enabled = try dataStream.read() as UInt8 != 0

                /// 1 Opacity as a percent
                self.opacity = try dataStream.read()
                
                /// 1 Opacity as a percent
                self.invert = try dataStream.read() as UInt8 != 0

                if self.version == 0 {
                    self.nativeColor = nil
                    return
                }
                
                /// 10 (Version 2 only) Native color space. 2 bytes for space followed by 4 * 2 byte color componentw
                self.nativeColor = try Color(dataStream: &dataStream)
                
                guard dataStream.position - startPosition == self.size else {
                    throw PhotoshopReadError.corrupted
                }
            }
        }
        
        /// Effects layer, bevel info
        public struct BevelInfo {
            public let size: UInt32
            public let version: UInt32
            public let angle: UInt32
            public let strength: UInt32
            public let blurValue: UInt32
            public let highlightBlendModeSignature: String
            public let highlightBlendModeKey: String
            public let shadowBlendModeSignature: String
            public let shadowBlendModeKey: String
            public let highlightColor: Color
            public let shadowColor: Color
            public let bevelStyle: UInt8
            public let highlightOpacity: UInt8
            public let shadowOpacity: UInt8
            public let enabled: Bool
            public let useAngleInAllLayerEffects: Bool
            public let upOrDown: Bool
            public let realHighlightColor: Color?
            public let realShadowColor: Color?
            
            public init(dataStream: inout DataStream) throws {
                /// 4 Size of the remaining items (58 for version 0, 78 for version 20
                let size: UInt32 = try dataStream.read(endianess: .bigEndian)
                guard (size == 58 || size == 78) && size <= dataStream.remainingCount else {
                    throw PhotoshopReadError.corrupted
                }
                
                self.size = size
                
                let startPosition = dataStream.position
                
                /// 4 Version: 0 for Photoshop 5.0; 2 for 5.5.
                let version: UInt32 = try dataStream.read(endianess: .bigEndian)
                guard (version == 0 && size == 58) || (version == 2 && size == 78) else {
                    throw PhotoshopReadError.corrupted
                }
                
                self.version = version
                
                /// 4 Angle in degrees
                self.angle = try dataStream.read(endianess: .bigEndian)

                /// 4 Strength. Depth in pixels
                self.strength = try dataStream.read(endianess: .bigEndian)
                
                /// 4 Blur value in pixels.
                self.blurValue = try dataStream.read(endianess: .bigEndian)
                
                /// 8 Highlight blend mode: 4 bytes for signature and 4 bytes for the key
                guard let highlightBlendModeSignature = try dataStream.readString(count: 4, encoding: .ascii) else {
                    throw PhotoshopReadError.corrupted
                }
                guard highlightBlendModeSignature == "8BIM" else {
                    throw PhotoshopReadError.corrupted
                }
                
                self.highlightBlendModeSignature = highlightBlendModeSignature
    
                guard let highlightBlendModeKey = try dataStream.readString(count: 4, encoding: .ascii) else {
                    throw PhotoshopReadError.corrupted
                }
                
                self.highlightBlendModeKey = highlightBlendModeKey
                
                /// 8 Shadow blend mode: 4 bytes for signature and 4 bytes for the key
                guard let shadowBlendModeSignature = try dataStream.readString(count: 4, encoding: .ascii) else {
                    throw PhotoshopReadError.corrupted
                }
                guard shadowBlendModeSignature == "8BIM" else {
                    throw PhotoshopReadError.corrupted
                }
                
                self.shadowBlendModeSignature = shadowBlendModeSignature
    
                guard let shadowBlendModeKey = try dataStream.readString(count: 4, encoding: .ascii) else {
                    throw PhotoshopReadError.corrupted
                }
                
                self.shadowBlendModeKey = shadowBlendModeKey
                
                /// 10 Highlight color: 2 bytes for space followed by 4 * 2 byte color component
                self.highlightColor = try Color(dataStream: &dataStream)
                
                /// 10 Shadow color: 2 bytes for space followed by 4 * 2 byte color component
                self.shadowColor = try Color(dataStream: &dataStream)
                
                /// 1 Bevel style
                self.bevelStyle = try dataStream.read()
                
                /// 1 Hightlight opacity as a percent
                self.highlightOpacity = try dataStream.read()
                
                /// 1 Shadow opacity as a percent
                self.shadowOpacity = try dataStream.read()
                
                /// 1 Effect enabled
                self.enabled = try dataStream.read() as UInt8 != 0

                /// 1 Use this angle in all of the layer effects
                self.useAngleInAllLayerEffects = try dataStream.read() as UInt8 != 0
                
                /// 1 Up or down
                self.upOrDown = try dataStream.read() as UInt8 != 0

                if self.version == 0 {
                    self.realHighlightColor = nil
                    self.realShadowColor = nil
                    return
                }
                
                /// 10 Real highlight color: 2 bytes for space; 4 * 2 byte color component
                self.realHighlightColor = try Color(dataStream: &dataStream)
                
                /// 10 Real shadow color: 2 bytes for space; 4 * 2 byte color component
                self.realShadowColor = try Color(dataStream: &dataStream)
                
                guard dataStream.position - startPosition == self.size else {
                    throw PhotoshopReadError.corrupted
                }
            }
        }
        
        /// Effects layer, solid fill (added in Photoshop 7.0)
        public struct SolidFill {
            public let size: UInt32
            public let version: UInt32
            public let blendModeSignature: String
            public let blendModeKey: String
            public let color: Color
            public let opacity: UInt8
            public let enabled: Bool
            public let nativeColor: Color
            
            public init(dataStream: inout DataStream) throws {
                /// 4 Size: 34
                let size: UInt32 = try dataStream.read(endianess: .bigEndian)
                guard size == 34 && size <= dataStream.remainingCount else {
                    throw PhotoshopReadError.corrupted
                }
                
                self.size = size
                
                let startPosition = dataStream.position
                
                /// 4 Version: 2
                self.version = try dataStream.read(endianess: .bigEndian)
                guard self.version == 2 else {
                    throw PhotoshopReadError.corrupted
                }
                
                /// 8 Blend mode: 4 bytes for signature and 4 bytes for key
                guard let blendModeSignature = try dataStream.readString(count: 4, encoding: .ascii) else {
                    throw PhotoshopReadError.corrupted
                }
                guard blendModeSignature == "8BIM" else {
                    throw PhotoshopReadError.corrupted
                }
                
                self.blendModeSignature = blendModeSignature
                
                guard let blendModeKey = try dataStream.readString(count: 4, encoding: .ascii) else {
                    throw PhotoshopReadError.corrupted
                }

                self.blendModeKey = blendModeKey
                
                /// 10 Color: 2 bytes for space followed by 4 * 2 byte color component
                self.color = try Color(dataStream: &dataStream)
                
                /// 1 Opacity
                self.opacity = try dataStream.read()
                
                /// 1 Enabled
                self.enabled = try dataStream.read() as UInt8 != 0
                
                /// 10 Native color: 2 bytes for space followed by 4 * 2 byte color component
                self.nativeColor = try Color(dataStream: &dataStream)
                
                guard dataStream.position - startPosition == self.size else {
                    throw PhotoshopReadError.corrupted
                }
            }
        }
    }
}
