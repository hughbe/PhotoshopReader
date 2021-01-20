//
//  AdditionalLayerInformationData.swift
//  
//
//  Created by Hugh Bellamy on 20/01/2021.
//

import DataStream

public enum AdditionalLayerInformationData {
    case effectsLayer(_: EffectsLayer)
    case typeToolInfo(_: TypeToolInfo)
    case unicodeLayerName(_: String)
    case layerID(_: UInt32)
    case objectBasedEffectsLayerInfo(_: ObjectBasedEffectsLayerInfo)
    case blendClippingElements(_: Bool)
    case blendInteriorElements(_: Bool)
    case knockout(_: Bool)
    case protected(_: Bool)
    case sheetColor(_: [UInt16])
    case referencePoint((Double, Double))
    case gradientMap(_: GradientMap)
    case sectionDivider(_: SectionDivider)
    case channelBlendingRestrictions(_: [UInt32])
    case solidColorSheet(_: VersionedDescriptor)
    case patternFill(_: VersionedDescriptor)
    case gradientFill(_: VersionedDescriptor)
    case vectorMask(key: AdditionalLayerInformationKey, _: VectorMask)
    case typeToolObject(_: TypeToolObject)
    case foreignEffectID(_: UInt32)
    case layerNameSource(_: UInt32)
    case patternData(_: PatternData)
    case metadata(_: [MetadataItem])
    case layerVersion(_: UInt32)
    case transparencyShapesLayer(_: Bool)
    case layerMaskAsGlobalMask(_: Bool)
    case vectorMaskAsGlobalMask(_: Bool)
    case brightnessAndContrast(_: BrightnessAndContrast)
    case channelMixer(_: ChannelMixer)
    case colorLookup(_: ColorLookup)
    case placedLayer(_: PlacedLayer)
    case linkedLayer(key: AdditionalLayerInformationKey, _: LinkedLayer)
    case photoFilter(_: PhotoFilter)
    case blackAndWhite(_: VersionedDescriptor)
    case contentGeneratorExtraData(_: VersionedDescriptor)
    case textEngineData(_: [UInt8])
    case vibrance(_: VersionedDescriptor)
    case unicodePathNames(_: VersionedDescriptor)
    case animationEffects(_: VersionedDescriptor)
    case filterMask(_: FilterMask)
    case placedLayerData(_: PlacedLayerData)
    case vectorStrokeData(_: VersionedDescriptor)
    case vectorStrokeContent(_: VectorStrokeContent)
    case usingAlignedRendering(_: Bool)
    case pixelSourceData(key: AdditionalLayerInformationKey, _: VersionedDescriptor)
    case compositorUsed(_: VersionedDescriptor)
    case vectorOriginationData(_: VectorOriginationData)
    case artboardData(key: AdditionalLayerInformationKey, _: VersionedDescriptor)
    case smartObjectLayerData(_: SmartObjectLayerData)
    case savingMergedTransparency(key: AdditionalLayerInformationKey)
    case userMask(_: UserMask)
    case exposure(_: Exposure)
    case filterEffects(key: AdditionalLayerInformationKey, _: FilterEffects)
    case opacity(_: Bool)
    case hueSaturation2(_: [UInt8])
    case colorBalance(_: [UInt8])
    case levels(_: [UInt8])
    case curves(_: [UInt8])
    case invert
    case posterize(_: UInt16)
    case threshold(_: UInt16)
    case selectiveColor(_: SelectiveColor)
    case lfxs(_: Lfxs)
    case unknown(key: String, _: DataStream)
    
    public init(layer: AdditionalLayerInformation) throws {
        var layerData = layer.data
        try self.init(dataStream: &layerData, key: layer.key, psb: layer.psb)
    }
    
    public init(dataStream: inout DataStream, key: String, psb: Bool) throws {
        guard let knownKey = AdditionalLayerInformationKey(rawValue: key) else {
            #if DEBUG
            fatalError("NYI: \(key) (\(dataStream.count) bytes)")
            #else
            self = .unknown(key: key, dataStream)
            return
            #endif
        }
        
        switch knownKey {
        case .effectsLayer:
            /// Effects Layer (Photoshop 5.0)
            /// The key for the effects layer is 'lrFX' . The data has the following format:
            /// Effects Layer info
            /// Length Description
            /// 2 Version: 0
            /// 2 Effects count: may be 6 (for the 6 effects in Photoshop 5 and 6) or 7 (for Photoshop 7.0)
            /// The next three items are repeated for each of the effects.
            /// 4 Signature: '8BIM'
            /// 4 Effects signatures: OSType key for which effects type to use:
            /// 'cmnS' = common state (see See Effects layer, common state info)
            /// 'dsdw' = drop shadow (see See Effects layer, drop shadow and inner shadow info)
            /// 'isdw' = inner shadow (see See Effects layer, drop shadow and inner shadow info)
            /// 'oglw' = outer glow (see See Effects layer, outer glow info)
            /// 'iglw' = inner glow (see See Effects layer, inner glow info)
            /// 'bevl' = bevel (see See Effects layer, bevel info)
            /// 'sofi' = solid fill ( Photoshop 7.0) (see See Effects layer, solid fill (added in Photoshop 7.0))
            /// Variable See appropriate tables.
            self = .effectsLayer(try EffectsLayer(dataStream: &dataStream))
        case .typeToolInfo:
            /// Type Tool Info (Photoshop 5.0 and 5.5 only)
            /// Has been superseded in Photoshop 6.0 and beyond by a different structure with the key 'TySh' (see See
            /// Type tool object setting (Photoshop 6.0) See Type tool object setting ).
            /// Key is 'tySh' . Data is as follows:
            /// Type tool Info
            /// Length Description
            /// 2 Version ( = 1)
            /// 48 6 * 8 double precision numbers for the transform information
            /// Font information
            /// 2 Version ( = 6)
            /// 2 Count of faces
            /// The next 8 fields are repeated for each count specified above
            /// 2 Mark value
            /// 4 Font type data
            /// Variable Pascal string of font name
            /// Variable Pascal string of font family name
            /// Variable Pascal string of font style name
            /// 2 Script value
            /// 4 Number of design axes vector to follow
            /// 4 Design vector value
            /// Style information
            /// 2 Count of styles
            /// The next 10 fields are repeated for each count specified above
            /// 2 Mark value
            /// 2 Face mark value
            /// 4 Size value
            /// 4 Tracking value
            /// 4 Kerning value
            /// 4 Leading value
            /// 4 Base shift value
            /// 1 Auto kern on/off
            /// 1 Only present in version <= 5
            /// 1 Rotate up/down
            /// Text information
            /// 2 Type value
            /// 4 Scaling factor value
            /// 4 Sharacter count value
            /// 4 Horizontal placement
            /// 4 Vertical placement
            /// 4 Select start value
            /// 4 Select end value
            /// 2 Line count, i.e. the number of items to follow.
            /// The next 5 fields are repeated for each item in line count.
            /// 4 Character count value
            /// 2 Orientation value
            /// 2 Alignment value
            /// 2 Actual character as a double byte character
            /// 2 Style value
            /// Color information
            /// 2 Color space value
            /// 8 4 * 2 byte color component
            /// 1 Anti alias on/off
            self = .typeToolInfo(try TypeToolInfo(dataStream: &dataStream))
        case .unicodeLayerName:
            /// Unicode layer name (Photoshop 5.0)
            /// Key is 'luni' . Data is as follows:
            /// Variable Unicode string
            self = .unicodeLayerName(try dataStream.readUnicodeString())
        case .layerID:
            /// Layer ID (Photoshop 5.0)
            /// Key is 'lyid' .
            /// 4 ID.
            guard dataStream.count == 4 else {
                throw PhotoshopReadError.corrupted
            }
            
            self = .layerID(try dataStream.read(endianess: .bigEndian))
        case .objectBasedEffectsLayerInfo:
            /// Object-based effects layer info (Photoshop 6.0)
            /// Key is 'lfx2' . Data is as follows:
            /// Object Based Effects Layer info
            /// Length Description
            /// 4 Object effects version: 0
            /// 4 Descriptor version ( = 16 for Photoshop 6.0).
            /// Variable Descriptor (see See Descriptor structure)
            self = .objectBasedEffectsLayerInfo(try ObjectBasedEffectsLayerInfo(dataStream: &dataStream))
        case .blendClippingElements:
            /// Blend clipping elements (Photoshop 6.0)
            /// Key is 'clbl' . Data is as follows:
            /// Blend clipping elements
            /// Length Description
            /// 1 Blend clipped elements: boolean
            /// 3 Padding
            guard dataStream.count == 4 else {
                throw PhotoshopReadError.corrupted
            }
            
            let startPosition = dataStream.position
            self = .blendClippingElements(try dataStream.read() as UInt8 != 0)
            try dataStream.readFourByteAlignmentPadding(startPosition: startPosition)
        case .blendInteriorElements:
            /// Blend interior elements (Photoshop 6.0)
            /// Key is 'infx' . Data is as follows:
            /// Blend interior elements
            /// Length Description
            /// 1 Blend interior elements: boolean
            /// 3 Padding
            guard dataStream.count == 4 else {
                throw PhotoshopReadError.corrupted
            }
            
            let startPosition = dataStream.position
            self = .blendInteriorElements(try dataStream.read() as UInt8 != 0)
            try dataStream.readFourByteAlignmentPadding(startPosition: startPosition)
        case .knockout:
            /// Knockout setting (Photoshop 6.0)
            /// Key is 'knko' . Data is as follows:
            /// Knockout
            /// Length Description
            /// 1 Knockout: boolean
            /// 3 Padding
            guard dataStream.count == 4 else {
                throw PhotoshopReadError.corrupted
            }
            
            let startPosition = dataStream.position
            self = .knockout(try dataStream.read() as UInt8 != 0)
            try dataStream.readFourByteAlignmentPadding(startPosition: startPosition)
        case .protected:
            /// Protected setting (Photoshop 6.0)
            /// Key is 'lspf' . Data is as follows:
            /// Knockout
            /// Length Description
            /// 1 Protected: boolean
            /// 3 Padding
            guard dataStream.count == 4 else {
                throw PhotoshopReadError.corrupted
            }
            
            let startPosition = dataStream.position
            self = .protected(try dataStream.read() as UInt8 != 0)
            try dataStream.readFourByteAlignmentPadding(startPosition: startPosition)
        case .sheetColor:
            /// Sheet color setting (Photoshop 6.0)
            /// Key is 'lclr' . Data is as follows:
            /// Sheet Color setting
            /// Length Description
            /// 4 * 2 Color. Only the first color setting is used for Photoshop 6.0; the rest are zeros
            guard dataStream.count == 8 else {
                throw PhotoshopReadError.corrupted
            }
            
            self = .sheetColor([try dataStream.read(endianess: .bigEndian),
                                try dataStream.read(endianess: .bigEndian),
                                try dataStream.read(endianess: .bigEndian),
                                try dataStream.read(endianess: .bigEndian)])
        case .referencePoint:
            /// Reference point (Photoshop 6.0)
            /// Key is 'fxrp' . Data is as follows:
            /// Sheet Color setting
            /// Length Description
            /// 2 * 8 2 double values for the reference point
            guard dataStream.count == 16 else {
                throw PhotoshopReadError.corrupted
            }
            
            self = .referencePoint((try dataStream.readDouble(endianess: .bigEndian),
                                    try dataStream.readDouble(endianess: .bigEndian)))
        case .gradientMap:
            /// Gradient settings (Photoshop 6.0)
            /// Key is 'grdm' . Data is as follows:
            /// Gradient settings
            /// Length Description
            /// 2 Version ( =1 for Photoshop 6.0)
            /// 1 Is gradient reversed
            /// 1 Is gradient dithered
            /// Variable Name of the gradient: Unicode string, padded
            /// 2 Number of color stops to follow
            /// Following is repeated for each color stop
            /// 4 Location of color stop
            /// 4 Midpoint of color stop
            /// 2 Mode for the color to follow
            /// 4 * 2 Actual color for the stop
            /// 2 Number of transparency stops to follow
            /// Following is repeated for each transparency stop
            /// 4 Location of transparency stop
            /// 4 Midpoint of transparency stop
            /// 2 Opacity of transparency stop
            /// 2 Expansion count ( = 2 for Photoshop 6.0)
            /// 2 Interpolation if length above is non-zero
            /// 2 Length (= 32 for Photoshop 6.0)
            /// 2 Mode for this gradient
            /// 4 Random number seed
            /// 2 Flag for showing transparency
            /// 2 Flag for using vector color
            /// 4 Roughness factor
            /// 2 Color model
            /// 4 * 2 Minimum color values
            /// 4 * 2 Maximum color values
            /// 2 Dummy: not used in Photoshop 6.0
            self = .gradientMap(try GradientMap(dataStream: &dataStream))
        case .sectionDivider:
            /// Section divider setting (Photoshop 6.0)
            /// Key is 'lsct' . Data is as follows:
            /// Section Divider setting
            /// Length Description
            /// 4 Type. 4 possible values, 0 = any other type of layer, 1 = open "folder", 2 = closed "folder", 3 = bounding section divider, hidden in the UI
            /// Following is only present if length >= 12
            /// 4 Signature: '8BIM'
            /// 4 Key. See blend mode keys in See Layer records.
            /// Following is only present if length >= 16
            /// 4 Sub type. 0 = normal, 1 = scene
            self = .sectionDivider(try SectionDivider(dataStream: &dataStream))
        case .channelBlendingRestrictions:
            /// Channel blending restrictions setting (Photoshop 6.0)
            /// Key is 'brst' . Data is as follows:
            /// Channel blending restrictions setting
            /// Length Description
            /// Following is repeated length / 4 times.
            /// 4 Channel number that is restricted
            guard dataStream.count % 4 == 0 else {
                throw PhotoshopReadError.corrupted
            }
            
            let count = dataStream.count / 4
            var values: [UInt32] = []
            values.reserveCapacity(Int(count))
            for _ in 0..<count {
                values.append(try dataStream.read(endianess: .bigEndian))
            }

            self = .channelBlendingRestrictions(values)
        case .solidColorSheet:
            /// Solid color sheet setting (Photoshop 6.0)
            /// Key is 'SoCo' . Data is as follows:
            /// Solid color sheet setting
            /// Length Description
            /// 4 Version ( = 16 for Photoshop 6.0)
            /// Variable Descriptor. Based on the Action file format structure (see See Descriptor structure)
            self = .solidColorSheet(try VersionedDescriptor(dataStream: &dataStream))
        case .patternFill:
            /// Pattern fill setting (Photoshop 6.0)
            /// Key is 'PtFl' . Data is as follows:
            /// Gradient Fill Setting
            /// Length Description
            /// 4 bytes Version ( = 16 for Photoshop 6.0)
            /// Variable Descriptor. Based on the Action file format structure (see See Descriptor structure)
            self = .patternFill(try VersionedDescriptor(dataStream: &dataStream))
        case .gradientFill:
            /// Gradient fill setting (Photoshop 6.0)
            /// Key is 'GdFl' . Data is as follows:
            /// Gradient Fill Setting
            /// Length Description
            /// 4 bytes Version ( = 16 for Photoshop 6.0)
            /// Variable Descriptor. Based on the Action file format structure (see See Descriptor structure)
            self = .gradientFill(try VersionedDescriptor(dataStream: &dataStream))
        case .vectorMaskSettingVmsk, .vectorMaskSettingVsms:
            /// Vector mask setting (Photoshop 6.0)
            /// Key is 'vmsk' or 'vsms'. If key is 'vsms' then we are writing for (Photoshop CS6) and the document will have
            /// a 'vscg' key. Data is as follows:
            /// Vector mask setting
            /// Length Description
            /// 4 Version ( = 3 for Photoshop 6.0)
            /// 4 Flags. bit 1 = invert, bit 2 = not link, bit 3 = disable
            /// The rest of the data is path components, loop until end of the length.
            /// Variable Paths. See See Path resource format
            self = .vectorMask(key: knownKey, try VectorMask(dataStream: &dataStream))
        case .typeToolObject:
            /// Type tool object setting (Photoshop 6.0)
            /// This supersedes the type tool info in Photoshop 5.0 (see See Type tool Info).
            /// Key is 'TySh' . Data is as follows:
            /// Type tool object setting
            /// Length Description
            /// 2 Version ( =1 for Photoshop 6.0)
            /// 6 * 8 Transform: xx, xy, yx, yy, tx, and ty respectively.
            /// 2 Text version ( = 50 for Photoshop 6.0)
            /// 4 Descriptor version ( = 16 for Photoshop 6.0)
            /// Variable Text data (see See Descriptor structure)
            /// 2 Warp version ( = 1 for Photoshop 6.0)
            /// 4 Descriptor version ( = 16 for Photoshop 6.0)
            /// Variable Warp data (see See Descriptor structure)
            /// 4 * 8 left, top, right, bottom respectively.
            self = .typeToolObject(try TypeToolObject(dataStream: &dataStream))
        case .foreignEffectID:
            /// Foreign effect ID (Photoshop 6.0)
            /// Key is 'ffxi' . Data is as follows:
            /// Foreign effect ID
            /// Length Description
            /// 4 ID of the Foreign effect.
            guard dataStream.count == 4 else {
                throw PhotoshopReadError.corrupted
            }
            
            self = .foreignEffectID(try dataStream.read(endianess: .bigEndian))
        case .layerNameSource:
            /// Layer name source setting (Photoshop 6.0)
            /// Key is 'lnsr' . Data is as follows:
            /// 4 ID for the layer name
            guard dataStream.count == 4 else {
                throw PhotoshopReadError.corrupted
            }
            
            self = .layerNameSource(try dataStream.read(endianess: .bigEndian))
        case .patternData:
            /// Pattern data (Photoshop 6.0)
            /// Key is 'shpa' . Data is as follows:
            /// Pattern data
            /// Length Description
            /// 4 Version ( = 0 for Photoshop 6.0)
            /// 4 Count of sets to follow
            /// The following is repeated for the count above.
            /// 4 Pattern signature
            /// 4 Pattern key
            /// 4 Count of patterns in this set
            /// 1 Copy on sheet duplication
            /// 3 Padding
            /// The following is repeated for the count of patterns above.
            /// 4 Color handling. Prefer convert = 'conv' , avoid conversion = 'avod' , luminance only = 'lumi'
            /// Variable Pascal string name of the pattern
            /// Variable Unicode string name of the pattern
            /// Variable Pascal string of the unique identifier for the pattern
            self = .patternData(try PatternData(dataStream: &dataStream))
        case .metadata:
            /// Metadata setting (Photoshop 6.0)
            /// Key is 'shmd' . Data is as follows:
            /// 4 Count of metadata items to follow
            /// The following is repeated the number of times specified by the count above:
            guard dataStream.count >= 4 else {
                throw PhotoshopReadError.corrupted
            }
            
            let count: UInt32 = try dataStream.read(endianess: .bigEndian)
            guard count * 16 <= dataStream.remainingCount else {
                throw PhotoshopReadError.corrupted
            }
            
            var values: [MetadataItem] = []
            values.reserveCapacity(Int(count))
            for _ in 0..<count {
                values.append(try MetadataItem(dataStream: &dataStream))
            }
            
            self = .metadata(values)
        case .layerVersion:
            /// Layer version (Photoshop 7.0)
            /// Key is 'lyvr' . Data is as follows:
            /// Layer version
            /// Length Description
            /// 4 A 32-bit number representing the version of Photoshop needed to read and interpret the layer without
            /// data loss. 70 = 7.0, 80 = 8.0, etc.
            /// The minimum value is 70, because just having the field present in 6.0 triggers a warning. For the future,
            /// Photoshop 7 checks to see whether this number is larger than the current version -- i.e., 70 -- and if so, warns that it is ignoring some data.
            guard dataStream.count == 4 else {
                throw PhotoshopReadError.corrupted
            }
            
            self = .layerVersion(try dataStream.read(endianess: .bigEndian))
        case .transparencyShapesLayer:
            /// Transparency shapes layer (Photoshop 7.0)
            /// Key is 'tsly' . Data is as follows:
            /// Transparency shapes layer
            /// Length Description
            /// 1 1: the transparency of the layer is used in determining the shape of the effects. This is the default for
            /// behavior like previous versions. 0: treated in the same way as fill opacity including modulating blend modes,
            /// rather than acting as strict transparency. Using this feature is useful for achieving effects that otherwise
            /// would require complex use of clipping groups.
            /// 3 Padding
            guard dataStream.count == 4 else {
                throw PhotoshopReadError.corrupted
            }

            let startPosition = dataStream.position
            self = .transparencyShapesLayer(try dataStream.read() as UInt8 != 0)
            try dataStream.readFourByteAlignmentPadding(startPosition: startPosition)
        case .layerMaskAsGlobalMask:
            /// Layer mask as global mask (Photoshop 7.0)
            /// Key is 'lmgm' . Data is as follows:
            /// Layer mask as global mask
            /// Length Description
            /// 1 1: the layer mask is used in a final crossfade masking the layer and effects rather than being used to shape
            /// the layer and its effects. This behavior was previously tied to the link status flag for the layer mask. (An
            /// unlinked mask acted like a flag value of 1, a linked mask like 0). For old files that lack this key, the link status
            /// is used in order to preserve compositing results.
            /// 3 Padding
            guard dataStream.count == 4 else {
                throw PhotoshopReadError.corrupted
            }

            let startPosition = dataStream.position
            self = .layerMaskAsGlobalMask(try dataStream.read() as UInt8 != 0)
            try dataStream.readFourByteAlignmentPadding(startPosition: startPosition)
        case .vectorMaskAsGlobalMask:
            /// Vector mask as global mask (Photoshop 7.0)
            /// Key is 'vmgm' . Data is as follows:
            /// Vector mask as global mask
            /// Length Description
            /// 1 Same as in See Layer mask as global mask, but applying the vector mask.
            /// 3 Padding
            guard dataStream.count == 4 else {
                throw PhotoshopReadError.corrupted
            }

            let startPosition = dataStream.position
            self = .vectorMaskAsGlobalMask(try dataStream.read() as UInt8 != 0)
            try dataStream.readFourByteAlignmentPadding(startPosition: startPosition)
        case .brightnessAndContrast:
            /// Brightness and Contrast
            /// Key is 'brit' . Data is as follows:
            /// Brightness and Contrast
            /// Length Description
            /// 2 Brightness
            /// 2 Contrast
            /// 2 Mean value for brightness and contrast
            /// 1 Lab color only
            guard dataStream.count == 8 else {
                throw PhotoshopReadError.corrupted
            }
            
            self = .brightnessAndContrast(try BrightnessAndContrast(dataStream: &dataStream))
        case .channelMixer:
            /// Channel Mixer
            /// Key is 'mixr' . Data is as follows:
            /// Channel Mixer
            /// Length Description
            /// 2 Version ( = 1)
            /// 2 Monochrome
            /// 20 RGB or CMYK color plus constant for the mixer settings. 4 * 2 bytes of color with 2 bytes of constant.
            self = .channelMixer(try ChannelMixer(dataStream: &dataStream))
        case .colorLookup:
            /// Color Lookup (Photoshop CS6)
            /// Key is 'clrL' . Data is as follows:
            /// Color Lookup
            /// Length Description
            /// 2 Version ( = 1)
            /// 4 Descriptor Version ( = 16)
            /// Variable Descriptor of black and white information
            self = .colorLookup(try ColorLookup(dataStream: &dataStream))
        case .placedLayer:
            /// Placed Layer (replaced by SoLd in Photoshop CS3)
            /// Key is 'plLd' . Data is as follows:
            /// Placed Layer
            /// Length Description
            /// 4 Type ( = 'plcL' )
            /// 4 Version ( = 3 )
            /// Variable Unique ID as a pascal string
            /// 4 Page number
            /// 4 Total pages
            /// 4 Anit alias policy
            /// 4 Placed layer type: 0 = unknown, 1 = vector, 2 = raster, 3 = image stack
            /// 4 * 8 Transformation: 8 doubles for x,y location of transform points
            /// 4 Warp version ( = 0 )
            /// 4 Warp descriptor version ( = 16 )
            /// Variable Descriptor for warping information
            self = .placedLayer(try PlacedLayer(dataStream: &dataStream))
        case .linkedLayerlnkD, .linkedLayerlnk2, .linkedLayerlnk3:
            /// Linked Layer
            /// Key is 'lnkD' . Also keys 'lnk2' and 'lnk3' . Data is as follows:
            /// Linked Layer
            /// Length Description
            /// The following is repeated for each linked file.
            /// 8 Length of the data to follow
            /// 4 Type ( = 'liFD' linked file data, 'liFE' linked file external or 'liFA' linked file alias )
            /// 4 Version ( = 1 to 7 )
            /// Variable Pascal string. Unique ID.
            /// Variable Unicode string of the original file name
            /// 4 File Type
            /// 4 File Creator
            /// 8 Length of the data to follow
            /// 1 File open descriptor
            /// Variable Descriptor of open parameters. Only present when above is true.
            /// If the type is 'liFE' then a linked file Descriptor is next.
            /// Variable Descriptor of linked file parameters. See comment above.
            /// If the type is 'liFE' and the version is greater than 3 then the following is present. Year, Month, Day, Hour, Minute, Second is next.
            /// 4 Year
            /// 1 Month
            /// 1 Day
            /// 1 Hour
            /// 1 Minute
            /// 8 Double for the seconds
            /// If the type is 'liFE' then a file size is next.
            /// 8 File size
            /// If the type is 'liFA' then 4 zeros are next.
            /// 8 All zeros
            /// If the type is 'liFE' then they bytes of the file are next.
            /// Variable Raw bytes of the file.
            /// If the version is greater than or equal to 5 then the following is next.
            /// UnicodeString Child Document ID.
            /// If the version is greater than or equal to 6 then the following is next.
            /// Double Asset mod time.
            /// If the version is greater than or equal to 7 then the following is next.
            /// 1 Asset locked state, for Libraries assets.
            /// If the type is 'liFE' and the version is 2 then the following is next.
            /// Variable Raw bytes of the file.
            self = .linkedLayer(key: knownKey, try LinkedLayer(dataStream: &dataStream))
        case .photoFilter:
            /// Photo Filter
            /// Key is 'phfl' . Data is as follows:
            /// Photo Filter
            /// Length Description
            /// 2 Version ( = 3) or ( = 2 )
            /// 12 4 bytes each for XYZ color (Only in Version 3)
            /// 10 2 bytes color space followed by 4 * 2 bytes color component (Only in Version 2)
            /// 4 Density
            /// 1 Preserve Luminosity
            guard dataStream.count >= 17 else {
                throw PhotoshopReadError.corrupted
            }

            self = .photoFilter(try PhotoFilter(dataStream: &dataStream))
        case .blackAndWhite:
            /// Black White (Photoshop CS3)
            /// Key is 'blwh' . Data is as follows:
            /// Content Generator Extra Data
            /// Length Description
            /// 4 Descriptor Version ( = 16)
            /// Variable Descriptor of extra data
            self = .blackAndWhite(try VersionedDescriptor(dataStream: &dataStream))
        case .contentGeneratorExtraData:
            /// Content Generator Extra Data (Photoshop CS5)
            /// Key is 'CgEd' . Data is as follows:
            /// Content Generator Extra Data
            /// Length Description
            /// 4 Descriptor Version ( = 16)
            /// Variable Descriptor of extra data
            self = .contentGeneratorExtraData(try VersionedDescriptor(dataStream: &dataStream))
        case .textEngineData:
            /// Text Engine Data (Photoshop CS3)
            /// Key is 'Txt2' . Data is as follows:
            /// Text Engine Data
            /// Length Description
            /// 4 Length of data to follow
            /// Variable Raw bytes for text engine
            let count: UInt32 = try dataStream.read(endianess: .bigEndian)
            guard count <= dataStream.remainingCount else {
                throw PhotoshopReadError.corrupted
            }

            self = .textEngineData(try dataStream.readBytes(count: Int(count)))
        case .vibrance:
            /// Vibrance (Photoshop CS3)
            /// Key is 'vibA' . Data is as follows:
            /// Vibrance
            /// Length Description
            /// 4 Descriptor Version ( = 16)
            /// Variable Descriptor of vibrance information
            self = .vibrance(try VersionedDescriptor(dataStream: &dataStream))
        case .unicodePathNames:
            /// Unicode Path Name (Photoshop CS6)
            /// Key is 'pths' . Data is as follows:
            /// Unicode Path Name
            /// Length Description
            /// 4 Descriptor Version ( = 16)
            /// Variable Descriptor containing a list of unicode path names
            self = .unicodePathNames(try VersionedDescriptor(dataStream: &dataStream))
        case .animationEffects:
            /// Animation Effects (Photoshop CS6)
            /// Key is 'anFX' . Data is as follows:
            /// Animation Effects
            /// Length Description
            /// 4 Descriptor Version ( = 16)
            /// Variable Descriptor containing animation effects
            self = .animationEffects(try VersionedDescriptor(dataStream: &dataStream))
        case .filterMask:
            /// Filter Mask (Photoshop CS3)
            /// Key is 'FMsk' . Data is as follows:
            /// Filter Mask
            /// Length Description
            /// 10 Color space
            /// 2 Opacity
            guard dataStream.count == 12 else {
                throw PhotoshopReadError.corrupted
            }
            
            self = .filterMask(try FilterMask(dataStream: &dataStream))
        case .placedLayerData:
            /// Placed Layer Data (Photoshop CS3)
            /// Key is 'SoLd' . See also 'PlLd' key. Data is as follows:
            /// Filter Mask
            /// Length Description
            /// 4 Identifier ( = 'soLD' )
            /// 4 Version ( = 4 )
            /// 4 Descriptor Version ( = 16)
            /// Variable Descriptor of placed layer information
            self = .placedLayerData(try PlacedLayerData(dataStream: &dataStream))
        case .vectorStrokeData:
            /// Vector Stroke Data (Photoshop CS6)
            /// Key is 'vstk' . Data is as follows:
            /// Vector stroke setting
            /// Length Description
            /// 4 Version ( = 16 )
            /// Variable Descriptor. Based on the Action file format structure (see See Descriptor structure)
            self = .vectorStrokeData(try VersionedDescriptor(dataStream: &dataStream))
        case .vectorStrokeContent:
            /// Vector Stroke Content Data (Photoshop CS6)
            /// Key is 'vscg' . Data is as follows:
            /// Vector stroke content setting
            /// Length Description
            /// 4 Key for data
            /// 4 Version ( = 16 )
            /// Variable Descriptor. Based on the Action file format structure (see See Descriptor structure)
            self = .vectorStrokeContent(try VectorStrokeContent(dataStream: &dataStream))
        case .usingAlignedRendering:
            /// Using Aligned Rendering (Photoshop CS6)
            /// Key is 'sn2P' . Data is as follows:
            /// Using Aligned Rendering
            /// Length Description
            /// 4 Non zero is true for using aligned rendering
            guard dataStream.count == 4 else {
                throw PhotoshopReadError.corrupted
            }
            
            self = .usingAlignedRendering(try dataStream.read(endianess: .bigEndian) as UInt32 != 0)
        case .vectorOriginationData:
            /// Vector Origination Data (Photoshop CC)
            /// Key is 'vogk' . Data is as follows:
            /// Vector origination setting
            /// Length Description
            /// 4 Version ( = 1 for Photoshop CC)
            /// 4 Version ( = 16 )
            /// Variable Descriptor. Based on the Action file format structure (see See Descriptor structure)
            self = .vectorOriginationData(try VectorOriginationData(dataStream: &dataStream))
        case .pixelSourceDataPxDC:
            /// Pixel Source Data (Photoshop CC)
            /// Key is 'PxSc'. Data is as follows:
            /// Pixel Source info
            /// Length Description
            /// 4 Version ( = 16 )
            /// Variable Descriptor. Based on the Action file format structure (see See Descriptor structure)
            self = .pixelSourceData(key: knownKey, try VersionedDescriptor(dataStream: &dataStream))
        case .compositorUsed:
            /// Compositor Used (Photoshop 2020)
            /// Key is 'cinf'. Data is as follows:
            /// Compositor Used
            /// Length Description
            /// 4 Version ( = 16 )
            /// Variable Descriptor. Based on the Action file format structure (see See Descriptor structure)
            self = .compositorUsed(try VersionedDescriptor(dataStream: &dataStream))
        case .pixelSourceDataPxSD:
            /// Pixel Source Data (Photoshop CC 2015)
            /// Key is 'PxSD'. Data is as follows:
            /// Pixel Source info
            /// Length Description
            /// 8 Length of data to follow
            /// Variable Raw data for 3D or video layers.
            self = .pixelSourceData(key: knownKey, try VersionedDescriptor(dataStream: &dataStream))
        case .artboardDataArtb, .artboardDataArtd, .artboardDataAbdd:
            /// Artboard Data (Photoshop CC 2015)
            /// Key is 'artb' or 'artd' or 'abdd'. Data is as follows:
            /// Artboard info
            /// Length Description
            /// 4 Version ( = 16 )
            /// Variable Descriptor. Based on the Action file format structure (see See Descriptor structure)
            self = .artboardData(key: knownKey, try VersionedDescriptor(dataStream: &dataStream))
        case .smartObjectLayerData:
            /// Smart Object Layer Data (Photoshop CC 2015)
            /// Key is 'SoLE' . Data is as follows:
            /// Smart Object info
            /// Length Description
            /// 4 Type ( = 'soLD' )
            /// 4 Version ( = 4 or 5 )
            /// Variable Descriptor. Based on the Action file format structure (see See Descriptor structure)
            self = .smartObjectLayerData(try SmartObjectLayerData(dataStream: &dataStream))
        case .savingMergedTransparencyMtrn, .savingMergedTransparencyMt16, .savingMergedTransparencyMt32:
            /// Saving Merged Transparency
            /// Key is 'Mtrn', 'Mt16' or 'Mt32' . There is no data associated with these keys.
            self = .savingMergedTransparency(key: knownKey)
        case .userMask:
            /// User Mask
            /// Key is 'LMsk' . Data is as follows:
            /// User Mask
            /// Length Description
            /// 10 Color space
            /// 2 Opacity
            /// 1 Flag ( = 128 )
            guard dataStream.count == 14 else {
                throw PhotoshopReadError.corrupted
            }
            
            self = .userMask(try UserMask(dataStream: &dataStream))
        case .exposure:
            /// Exposure
            /// Key is 'expA' .
            /// Exposure
            /// Length Description
            /// 2 Version (= 1)
            /// 4 Exposure
            /// 4 Offset
            /// 4 Gamma
            guard dataStream.count == 16 else {
                throw PhotoshopReadError.corrupted
            }
            
            self = .exposure(try Exposure(dataStream: &dataStream))
        case .filterEffectsFXid, .filterEffectsFEid:
            /// Filter Effects
            /// Key is 'FXid' or 'FEid' .
            /// Filter Effects
            /// Length Description
            /// 4 Version ( =1, 2 or 3)
            /// 8 Length of data to follow
            /// The following is repeated for the given length.
            /// Variable Pascal string as identifier
            /// 4 Version ( = 1 )
            /// 8 Length
            /// 16 Rectangle: top, left, bottom, right
            /// 4 Depth
            /// 4 Max channels
            /// The following is repeated for number of channels + a user mask + a sheet mask.
            /// 4 Boolean indicating whether array is written
            /// 8 Length
            /// 2 Compression mode of data to follow.
            /// Variable Actual data based on compression
            /// End of repeating for channels
            /// 1 Next two items present or not
            /// 2 Compression mode of data to follow
            /// Variable Actual data based on compression
            self = .filterEffects(key: knownKey, try FilterEffects(dataStream: &dataStream))
        case .opacity:
            guard dataStream.count == 4 else {
                throw PhotoshopReadError.corrupted
            }

            let startPosition = dataStream.position
            self = .opacity(try dataStream.read() as UInt8 != 0)
            try dataStream.readFourByteAlignmentPadding(startPosition: startPosition)
        case .hueSaturation2:
            self = .hueSaturation2(try dataStream.readBytes(count: dataStream.count))
        case .colorBalance:
            self = .colorBalance(try dataStream.readBytes(count: dataStream.count))
        case .levels:
            self = .levels(try dataStream.readBytes(count: dataStream.count))
        case .curves:
            self = .curves(try dataStream.readBytes(count: dataStream.count))
        case .invert:
            guard dataStream.count == 0 else {
                throw PhotoshopReadError.corrupted
            }

            self = .invert
        case .posterize:
            guard dataStream.count == 4 else {
                throw PhotoshopReadError.corrupted
            }

            let startPosition = dataStream.position
            self = .posterize(try dataStream.read())
            try dataStream.readFourByteAlignmentPadding(startPosition: startPosition)
        case .threshold:
            guard dataStream.count == 4 else {
                throw PhotoshopReadError.corrupted
            }

            let startPosition = dataStream.position
            self = .threshold(try dataStream.read())
            try dataStream.readFourByteAlignmentPadding(startPosition: startPosition)
        case .selectiveColor:
            guard dataStream.count == 84 else {
                throw PhotoshopReadError.corrupted
            }

            self = .selectiveColor(try SelectiveColor(dataStream: &dataStream))
        case .lfxs:
            self = .lfxs(try Lfxs(dataStream: &dataStream))
        }
        
        if dataStream.remainingCount > 0 && dataStream.remainingCount < 4 {
            try dataStream.readFourByteAlignmentPadding(startPosition: 0)
        }

        guard dataStream.remainingCount == 0 else {
            throw PhotoshopReadError.corrupted
        }
    }
}
