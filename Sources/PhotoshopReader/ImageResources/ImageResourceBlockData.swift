//
//  PhotoshopDocumentColorModeData.swift
//
//
//  Created by Hugh Bellamy on 18/01/2021.
//

import DataStream

public enum ImageResourceBlockData {
    case channelInfo(_: ChannelInfo)
    case macPrintManagerPrintInfo(_: [UInt8])
    case macPageFormatInformation(_: [UInt8])
    case indexedColorTable(_: [UInt8])
    case resolutionInfo(_: ResolutionInfo)
    case alphaChannelNames(_: [String])
    case displayInfoObsolete(_: [DisplayInfoObsolete])
    case caption(_: String)
    case borderInformation(_: BorderInformation)
    case backgroundColor(_: Color)
    case printFlags(_: PrintFlags)
    case grayscaleAndMultichannelHalftoningInformation(_: [UInt8])
    case colorHalftoningInformation(_: [UInt8])
    case duotoneHalftoningInformation(_: [UInt8])
    case grayscaleAndMultichannelTransferFunction(_: [UInt8])
    case colorTransferFunctions(_: [UInt8])
    case duotoneTransferFunctions(_: [UInt8])
    case duotoneImageInformation(_: [UInt8])
    case blackAndWhiteValuesForDotRange(_: (UInt8, UInt8))
    case obsolete0x03FC(_: [UInt8])
    case epsOptions(_: [UInt8])
    case quickMaskInformation(_: QuickMaskInformation)
    case obsolete0x03FF(_: [UInt8])
    case layerStateInformation(_: UInt16)
    case workingPath(_: [PathRecord])
    case layersGroupInformation(_: [UInt16])
    case obsolete0x0403(_: [UInt8])
    case iptcNAARecord(_: IPTCRecord)
    case imageMode(_: [UInt8])
    case jpegQuality(_: [UInt8])
    case gridAndGuidesInformation(_: GridAndGuidesInformation)
    case thumbnailResourceObsolete(_: ThumbnailResource)
    case copyrightFlag(_: Bool)
    case url(_: [UInt8])
    case thumbnailResource(_: ThumbnailResource)
    case globalAngle(_: Float)
    case colorSamplersResourceObsolete(_: ColorSamplersResource)
    case iccProfile(_: DataStream)
    case watermark(_: Bool)
    case iccUntaggedProfile(_: Bool)
    case effectsVisible(_: Bool)
    case spotHalftone(_: SpotHalftone)
    case documentSpecificIDsSeedNumber(_: UInt32)
    case unicodeAlphaChannelNames(_: [String])
    case indexedColorTableCount(_: UInt16)
    case transparencyIndex(_: UInt16)
    case globalAltitude(_: Float)
    case slices(_: Slices)
    case workflowURL(_: String)
    case jumpToXPEP(_: JumpToXPEP)
    case alphaIdentifiers(_: [UInt32])
    case urlList(_: [PhotoshopURL])
    case versionInfo(_: VersionInfo)
    case exifData1(_: [UInt8])
    case exifData3(_: [UInt8])
    case xmpMetadata(_: String)
    case captionDigest(_: [UInt8])
    case printScale(_: PrintScale)
    case pixelAspectRatio(_: PixelAspectRatio)
    case layerComps(_: VersionedDescriptor)
    case alternateDuotoneColors(_: AlternateDuotoneColors)
    case alternateSpotColors(_: AlternateSpotColors)
    case layerSelectionIDs(_: [UInt32])
    case hdrToningInformation(_: [UInt8])
    case printInfo(_: [UInt8])
    case layerGroupsEnabledID(_: [Bool])
    case colorSamplersResource(_: ColorSamplersResource)
    case measurementScale(_: VersionedDescriptor)
    case timelineInformation(_: VersionedDescriptor)
    case sheetDisclosure(_: VersionedDescriptor)
    case displayInfo(_: DisplayInfo)
    case onionSkins(_: VersionedDescriptor)
    case countInformation(_: VersionedDescriptor)
    case printInformation(_: VersionedDescriptor)
    case printStyle(_: VersionedDescriptor)
    case macNSPrintInfo(_: [UInt8])
    case windowsDEVMODE(_: [UInt8])
    case autoSaveFilePath(_: String)
    case autoSaveFormat(_: String)
    case pathSelectionState(_: VersionedDescriptor)
    case nameOfClippingPath(_: [PathRecord])
    case originPathInfo(_: VersionedDescriptor)
    case imageReadVariables(_: String)
    case imageReadDataSets(_: [UInt8])
    case imageReadyDefaultSelectedState(_: [UInt8])
    case imageReady7RolloverExpandedState(_: [UInt8])
    case imageReadyRolloverExpandedState(_: [UInt8])
    case imageReadySaveLayerSettings(_: [UInt8])
    case imageReadyVersion(_: [UInt8])
    case lightroomWorkflow(_: [UInt8])
    case printFlagsInformation(_: PrintFlagsInformation)
    case pluginResource(id: UInt16, _: [UInt8])
    case pathInformation(id: UInt16, _: [PathRecord])
    case unknown(id: UInt16, _: [UInt8])
    
    public init(resource: ImageResourceBlock) throws {
        var resourceData = resource.data
        try self.init(dataStream: &resourceData, id: resource.id)
    }
    
    public init(dataStream: inout DataStream, id: UInt16) throws {
        guard let knownID = ImageResourceID(rawValue: id) else {
            if id >= 0x0FA0 && id <= 0x0FA0 {
                /// 0x0FA0-0x1387 4000-4999 Plug-In resource(s). Resources added by a plug-in.
                /// See the plug-in API found in the SDK documentation
                self = .pluginResource(id: id, try dataStream.readBytes(count: dataStream.count))
            } else if id >= 0x07D0 && id <= 0x0BB6 {
                /// 0x07D0-0x0BB6 2000-2997 Path Information (saved paths). See See Path resource format.
                guard (dataStream.count % 26) == 0 else {
                    self = .unknown(id: id, try dataStream.readBytes(count: dataStream.count))
                    return
                }

                let count = dataStream.count / 26
                var values: [PathRecord] = []
                values.reserveCapacity(count)
                for _ in 0..<count {
                    values.append(try PathRecord(dataStream: &dataStream))
                }

                self = .pathInformation(id: id, values)
            } else {
                self = .unknown(id: id, try dataStream.readBytes(count: dataStream.count))
            }

            return
        }
        
        switch knownID {
        case .channelInfo:
            /// 0x03E8 1000 (Obsolete--Photoshop 2.0 only ) Contains five 2-byte values: number of channels, rows,
            /// columns, depth, and mode
            self = .channelInfo(try ChannelInfo(dataStream: &dataStream))
        case .macPrintManagerPrintInfo:
            /// 0x03E9 1001 Macintosh print manager print info record
            self = .macPrintManagerPrintInfo(try dataStream.readBytes(count: dataStream.count))
        case .macPageFormatInformation:
            /// 0x03EA 1002 Macintosh page format information. No longer read by Photoshop. (Obsolete)
            self = .macPageFormatInformation(try dataStream.readBytes(count: dataStream.count))
        case .indexedColorTable:
            /// 0x03EB 1003 (Obsolete--Photoshop 2.0 only ) Indexed color table
            self = .indexedColorTable(try dataStream.readBytes(count: dataStream.count))
        case .resolutionInfo:
            /// 0x03ED 1005 ResolutionInfo structure. See Appendix A in Photoshop API Guide.pdf.
            guard dataStream.count == 16 else {
                throw PhotoshopReadError.corrupted
            }

            self = .resolutionInfo(try ResolutionInfo(dataStream: &dataStream))
        case .alphaChannelNames:
            /// 0x03EE 1006 Names of the alpha channels as a series of Pascal strings.
            var values: [String] = []
            while dataStream.remainingCount > 0 {
                values.append(try dataStream.readPascalString())
            }

            self = .alphaChannelNames(values)
        case .displayInfoObsolete:
            /// 0x03EF 1007 (Obsolete) See ID 1077DisplayInfo structure. See Appendix A in Photoshop API Guide.pdf.
            guard dataStream.count % 14 == 0 else {
                throw PhotoshopReadError.corrupted
            }

            let count = dataStream.count / 14
            var values: [DisplayInfoObsolete] = []
            values.reserveCapacity(count)
            for _ in 0..<count {
                values.append(try DisplayInfoObsolete(dataStream: &dataStream))
            }
            
            self = .displayInfoObsolete(values)
        case .caption:
            /// 0x03F0 1008 The caption as a Pascal string.
            self = .caption(try dataStream.readPascalString())
        case .borderInformation:
            /// 0x03F1 1009 Border information. Contains a fixed number (2 bytes real, 2 bytes fraction) for the border width, and 2 bytes for border
            /// units (1 = inches, 2 = cm, 3 = points, 4 = picas, 5 = columns).
            guard dataStream.count == 6 else {
                throw PhotoshopReadError.corrupted
            }
            
            self = .borderInformation(try BorderInformation(dataStream: &dataStream))
        case .backgroundColor:
            /// 0x03F2 1010 Background color. See See Color structure.
            guard dataStream.count == 10 else {
                throw PhotoshopReadError.corrupted
            }

            self = .backgroundColor(try Color(dataStream: &dataStream))
        case .printFlags:
            /// 0x03F3 1011 Print flags. A series of one-byte boolean values (see Page Setup dialog): labels, crop marks,
            /// color bars, registration marks, negative, flip, interpolate, caption, print flags.
            guard dataStream.count >= 7 && dataStream.count <= 9 else {
                throw PhotoshopReadError.corrupted
            }

            self = .printFlags(try PrintFlags(dataStream: &dataStream))
        case .grayscaleAndMultichannelHalftoningInformation:
            /// 0x03F4 1012 Grayscale and multichannel halftoning information
            self = .grayscaleAndMultichannelHalftoningInformation(try dataStream.readBytes(count: dataStream.count))
        case .colorHalftoningInformation:
            /// 0x03F5 1013 Color halftoning information
            self = .colorHalftoningInformation(try dataStream.readBytes(count: dataStream.count))
        case .duotoneHalftoningInformation:
            /// 0x03F6 1014 Duotone halftoning information
            self = .duotoneHalftoningInformation(try dataStream.readBytes(count: dataStream.count))
        case .grayscaleAndMultichannelTransferFunction:
            /// 0x03F7 1015 Grayscale and multichannel transfer function
            self = .grayscaleAndMultichannelTransferFunction(try dataStream.readBytes(count: dataStream.count))
        case .colorTransferFunctions:
            /// 0x03F8 1016 Color transfer functions
            self = .colorTransferFunctions(try dataStream.readBytes(count: dataStream.count))
        case .duotoneTransferFunctions:
            /// 0x03F9 1017 Duotone transfer functions
            self = .duotoneTransferFunctions(try dataStream.readBytes(count: dataStream.count))
        case .duotoneImageInformation:
            /// 0x03FA 1018 Duotone image information
            self = .duotoneImageInformation(try dataStream.readBytes(count: dataStream.count))
        case .blackAndWhiteValuesForDotRange:
            /// 0x03FB 1019 Two bytes for the effective black and white values for the dot range
            guard dataStream.count == 2 else {
                throw PhotoshopReadError.corrupted
            }

            self = .blackAndWhiteValuesForDotRange((try dataStream.read(), try dataStream.read()))
        case .obsolete0x03FC:
            /// 0x03FC 1020 (Obsolete)
            self = .obsolete0x03FC(try dataStream.readBytes(count: dataStream.count))
        case .epsOptions:
            /// 0x03FD 1021 EPS options
            self = .epsOptions(try dataStream.readBytes(count: dataStream.count))
        case .quickMaskInformation:
            /// 0x03FE 1022 Quick Mask information. 2 bytes containing Quick Mask channel ID; 1- byte boolean indicating
            /// whether the mask was initially empty.
            self = .quickMaskInformation(try QuickMaskInformation(dataStream: &dataStream))
        case .obsolete0x03FF:
            /// 0x03FF 1023 (Obsolete)
            self = .obsolete0x03FF(try dataStream.readBytes(count: dataStream.count))
        case .layerStateInformation:
            /// 0x0400 1024 Layer state information. 2 bytes containing the index of target layer (0 = bottom layer).
            guard dataStream.count == 2 else {
                throw PhotoshopReadError.corrupted
            }

            self = .layerStateInformation(try dataStream.read(endianess: .bigEndian))
        case .workingPath:
            /// 0x0401 1025 Working path (not saved). See See Path resource format.
            let startPosition = dataStream.position
            let count = dataStream.count / 26
            var values: [PathRecord] = []
            values.reserveCapacity(count)
            for _ in 0..<count {
                values.append(try PathRecord(dataStream: &dataStream))
            }
            
            self = .workingPath(values)
            
            // Seen four byte padding
            if dataStream.remainingCount > 0 && dataStream.remainingCount < 4 {
                try dataStream.readFourByteAlignmentPadding(startPosition: startPosition)
            }
        case .layersGroupInformation:
            /// 0x0402 1026 Layers group information. 2 bytes per layer containing a group ID for the dragging groups. Layers in a group have the same group ID.
            guard (dataStream.count % 2) == 0 else {
                throw PhotoshopReadError.corrupted
            }

            let count = dataStream.count / 2
            var values: [UInt16] = []
            values.reserveCapacity(count)
            for _ in 0..<count {
                values.append(try dataStream.read(endianess: .bigEndian))
            }
            
            self = .layersGroupInformation(values)
        case .obsolete0x0403:
            /// 0x0403 1027 (Obsolete)
            self = .obsolete0x0403(try dataStream.readBytes(count: dataStream.count))
        case .iptcNAARecord:
            /// 0x0404 1028 IPTC-NAA record. Contains the File Info... information. See the documentation in the IPTC folder of the Documentation folder.
            self = .iptcNAARecord(try IPTCRecord(dataStream: &dataStream))
        case .imageMode:
            /// 0x0405 1029 Image mode for raw format files
            self = .imageMode(try dataStream.readBytes(count: dataStream.count))
        case .jpegQuality:
            /// 0x0406 1030 JPEG quality. Private.
            self = .jpegQuality(try dataStream.readBytes(count: dataStream.count))
        case .gridAndGuidesInformation:
            /// 0x0408 1032 (Photoshop 4.0) Grid and guides information. See See Grid and guides resource format.
            self = .gridAndGuidesInformation(try GridAndGuidesInformation(dataStream: &dataStream))
        case .thumbnailResourceObsolete:
            /// 0x0409 1033 (Photoshop 4.0) Thumbnail resource for Photoshop 4.0 only. See See Thumbnail resource format.
            self = .thumbnailResourceObsolete(try ThumbnailResource(dataStream: &dataStream))
        case .copyrightFlag:
            /// 0x040A 1034 (Photoshop 4.0) Copyright flag. Boolean indicating whether image is copyrighted. Can be set via Property suite or by user
            /// in File Info...
            guard dataStream.count == 1 else {
                throw PhotoshopReadError.corrupted
            }

            self = .copyrightFlag(try dataStream.read() as UInt8 != 0)
        case .url:
            /// 0x040B 1035 (Photoshop 4.0) URL. Handle of a text string with uniform resource locator. Can be set via Property suite or by user in
            /// File Info...
            self = .url(try dataStream.readBytes(count: dataStream.count))
        case .thumbnailResource:
            /// 0x040C 1036 (Photoshop 5.0) Thumbnail resource (supersedes resource 1033). See See Thumbnail resource format.
            self = .thumbnailResource(try ThumbnailResource(dataStream: &dataStream))
        case .globalAngle:
            /// 0x040D 1037 (Photoshop 5.0) Global Angle. 4 bytes that contain an integer between 0 and 359, which is the
            /// global lighting angle for effects layer. If not present, assumed to be 30.
            guard dataStream.count == 4 else {
                throw PhotoshopReadError.corrupted
            }
            
            self = .globalAngle(try dataStream.readFloat(endianess: .bigEndian))
        case .colorSamplersResourceObsolete:
            /// 0x040E 1038 (Obsolete) See ID 1073 below. (Photoshop 5.0) Color samplers resource. See See Color
            /// samplers resource format.
            self = .colorSamplersResourceObsolete(try ColorSamplersResource(dataStream: &dataStream))
        case .iccProfile:
            /// 0x040F 1039 (Photoshop 5.0) ICC Profile. The raw bytes of an ICC (International Color Consortium) format
            /// profile. See ICC1v42_2006-05.pdf in the Documentation folder and icProfileHeader.h in
            /// Sample Code\Common\Includes .
            self = .iccProfile(DataStream(slicing: dataStream, startIndex: dataStream.position, count: dataStream.remainingCount))
            dataStream.position += dataStream.remainingCount
        case .watermark:
            /// 0x0410 1040 (Photoshop 5.0) Watermark. One byte.
            guard dataStream.count == 1 else {
                throw PhotoshopReadError.corrupted
            }

            self = .watermark(try dataStream.read() as UInt8 != 0)
        case .iccUntaggedProfile:
            /// 0x0411 1041 (Photoshop 5.0) ICC Untagged Profile. 1 byte that disables any assumed profile handling when
            /// opening the file. 1 = intentionally untagged.
            guard dataStream.count == 1 else {
                throw PhotoshopReadError.corrupted
            }

            self = .iccUntaggedProfile(try dataStream.read() as UInt8 != 0)
        case .effectsVisible:
            /// 0x0412 1042 (Photoshop 5.0) Effects visible. 1-byte global flag to show/hide all the effects layer. Only
            /// present when they are hidden.
            guard dataStream.count == 1 else {
                throw PhotoshopReadError.corrupted
            }

            self = .effectsVisible(try dataStream.read() as UInt8 != 0)
        case .spotHalftone: // 0x0413
            /// 0x0413 1043 (Photoshop 5.0) Spot Halftone. 4 bytes for version, 4 bytes for length, and the variable length data.
            self = .spotHalftone(try SpotHalftone(dataStream: &dataStream))
        case .documentSpecificIDsSeedNumber:
            /// 0x0414 1044 (Photoshop 5.0) Document-specific IDs seed number. 4 bytes: Base value, starting at which
            /// layer IDs will be generated (or a greater value if existing IDs already exceed it). Its purpose is to avoid the
            /// case where we add layers, flatten, save, open, and then add more layers that end up with the same IDs as the first set.
            guard dataStream.count == 4 else {
                throw PhotoshopReadError.corrupted
            }
            
            self = .documentSpecificIDsSeedNumber(try dataStream.read(endianess: .bigEndian))
        case .unicodeAlphaChannelNames: // 0x0415
            /// 0x0415 1045 (Photoshop 5.0) Unicode Alpha Names. Unicode string
            var values: [String] = []
            while dataStream.remainingCount > 0 {
                values.append(try dataStream.readUnicodeString())
            }

            self = .unicodeAlphaChannelNames(values)
        case .indexedColorTableCount:
            /// 0x0416 1046 (Photoshop 6.0) Indexed Color Table Count. 2 bytes for the number of colors in table that
            /// are actually defined
            guard dataStream.count == 2 else {
                throw PhotoshopReadError.corrupted
            }
            
            self = .indexedColorTableCount(try dataStream.read(endianess: .bigEndian))
        case .transparencyIndex:
            /// 0x0417 1047 (Photoshop 6.0) Transparency Index. 2 bytes for the index of transparent color, if any.
            guard dataStream.count == 2 else {
                throw PhotoshopReadError.corrupted
            }
            
            self = .transparencyIndex(try dataStream.read(endianess: .bigEndian))
        case .globalAltitude:
            /// 0x0419 1049 (Photoshop 6.0) Global Altitude. 4 byte entry for altitude
            guard dataStream.count == 4 else {
                throw PhotoshopReadError.corrupted
            }
            
            self = .globalAltitude(try dataStream.readFloat(endianess: .bigEndian))
        case .slices:
            /// 0x041A 1050 (Photoshop 6.0) Slices. See See Slices resource format.
            self = .slices(try Slices(dataStream: &dataStream))
        case .workflowURL:
            /// 0x041B 1051 (Photoshop 6.0) Workflow URL. Unicode string
            self = .workflowURL(try dataStream.readUnicodeString())
        case .jumpToXPEP:
            /// 0x041C 1052 (Photoshop 6.0) Jump To XPEP. 2 bytes major version, 2 bytes minor version, 4 bytes count.
            /// Following is repeated for count: 4 bytes block size, 4 bytes key, if key = 'jtDd' , then next is a Boolean for the
            /// dirty flag; otherwise it's a 4 byte entry for the mod date.
            self = .jumpToXPEP(try JumpToXPEP(dataStream: &dataStream))
        case .alphaIdentifiers:
            /// 0x041D 1053 (Photoshop 6.0) Alpha Identifiers. 4 bytes of length, followed by 4 bytes each for every alpha
            /// identifier.
            // Description appears to be wrong:
            // Actually is a list of 4 byte values without a preceding count.
            //
            // let count: UInt32 = try dataStream.read(endianess: .bigEndian)
            // guard count * 4 <= dataStream.remainingCount else {
            //     throw PhotoshopReadError.corrupted
            // }
            //
            // var values: [UInt32] = []
            // values.reserveCapacity(Int(count))
            // for _ in 0..<count {
            //     values.append(try dataStream.read(endianess: .bigEndian))
            // }
            //
            // self = .alphaIdentifiers(values)
            
            guard (dataStream.count % 4) == 0 else {
                throw PhotoshopReadError.corrupted
            }

            let count = dataStream.count / 4
            var values: [UInt32] = []
            values.reserveCapacity(count)
            for _ in 0..<count {
                values.append(try dataStream.read(endianess: .bigEndian))
            }
            
            self = .alphaIdentifiers(values)
        case .urlList:
            /// 0x041E 1054 (Photoshop 6.0) URL List. 4 byte count of URLs, followed by 4 byte long, 4 byte ID, and
            /// Unicode string for each count.
            guard dataStream.count >= 4 else {
                throw PhotoshopReadError.corrupted
            }

            let count: UInt32 = try dataStream.read(endianess: .bigEndian)
            guard count * 8 <= dataStream.remainingCount else {
                throw PhotoshopReadError.corrupted
            }

            var values: [PhotoshopURL] = []
            values.reserveCapacity(Int(count))
            for _ in 0..<count {
                values.append(try PhotoshopURL(dataStream: &dataStream))
            }
            
            self = .urlList(values)
        case .versionInfo:
            /// 0x0421 1057 (Photoshop 6.0) Version Info. 4 bytes version, 1 byte hasRealMergedData , Unicode string:
            /// writer name, Unicode string: reader name, 4 bytes file version.
            self = .versionInfo(try VersionInfo(dataStream: &dataStream))
        case .exifData1:
            /// 0x0422 1058 (Photoshop 7.0) EXIF data 1. See
            /// http://www.kodak.com/global/plugins/acrobat/en/service/digCam/exifStandard2.pdf
            self = .exifData1(try dataStream.readBytes(count: dataStream.count))
        case .exifData3:
            /// 0x0423 1059 (Photoshop 7.0) EXIF data 3. See
            /// http://www.kodak.com/global/plugins/acrobat/en/service/digCam/exifStandard2.pdf
            self = .exifData3(try dataStream.readBytes(count: dataStream.count))
        case .xmpMetadata:
            /// 0x0424 1060 (Photoshop 7.0) XMP metadata. File info as XML description. See
            /// http://www.adobe.com/devnet/xmp/
            guard let data = try dataStream.readString(count: dataStream.count, encoding: .ascii) else {
                throw PhotoshopReadError.corrupted
            }
            
            self = .xmpMetadata(data)
        case .captionDigest:
            /// 0x0425 1061 (Photoshop 7.0) Caption digest. 16 bytes: RSA Data Security, MD5 message-digest algorithm
            guard dataStream.count == 16 else {
                throw PhotoshopReadError.corrupted
            }

            self = .captionDigest(try dataStream.readBytes(count: dataStream.count))
        case .printScale:
            /// 0x0426 1062 (Photoshop 7.0) Print scale. 2 bytes style (0 = centered, 1 = size to fit, 2 = user defined). 4
            /// bytes x location (floating point). 4 bytes y location (floating point). 4 bytes scale (floating point)
            guard dataStream.count == 14 else {
                throw PhotoshopReadError.corrupted
            }

            self = .printScale(try PrintScale(dataStream: &dataStream))
        case .pixelAspectRatio:
            /// 0x0428 1064 (Photoshop CS) Pixel Aspect Ratio. 4 bytes (version = 1 or 2), 8 bytes double, x / y of a pixel.
            /// Version 2, attempting to correct values for NTSC and PAL, previously off by a factor of approx. 5%.
            guard dataStream.count == 12 else {
                throw PhotoshopReadError.corrupted
            }

            self = .pixelAspectRatio(try PixelAspectRatio(dataStream: &dataStream))
        case .layerComps:
            /// 0x0429 1065 (Photoshop CS) Layer Comps. 4 bytes (descriptor version = 16), Descriptor (see See
            /// Descriptor structure)
            self = .layerComps(try VersionedDescriptor(dataStream: &dataStream))
        case .alternateDuotoneColors:
            /// 0x042A 1066 (Photoshop CS) Alternate Duotone Colors. 2 bytes (version = 1), 2 bytes count, following is
            /// repeated for each count: [ Color: 2 bytes for space followed by 4 * 2 byte color component ], following this
            /// is another 2 byte count, usually 256, followed by Lab colors one byte each for L, a, b. This resource is not read or used by Photoshop.
            self = .alternateDuotoneColors(try AlternateDuotoneColors(dataStream: &dataStream))
        case .alternateSpotColors:
            /// 0x042B 1067 (Photoshop CS)Alternate Spot Colors. 2 bytes (version = 1), 2 bytes channel count, following
            /// is repeated for each count: 4 bytes channel ID, Color: 2 bytes for space followed by 4 * 2 byte color
            /// component. This resource is not read or used by Photoshop.
            self = .alternateSpotColors(try AlternateSpotColors(dataStream: &dataStream))
        case .layerSelectionIDs:
            /// 0x042D 1069 (Photoshop CS2) Layer Selection ID(s). 2 bytes count, following is repeated for each count: 4 bytes layer ID
            guard dataStream.count >= 2 else {
                throw PhotoshopReadError.corrupted
            }
            
            let count: UInt16 = try dataStream.read(endianess: .bigEndian)
            guard 2 + count * 4 == dataStream.count else {
                throw PhotoshopReadError.corrupted
            }
            
            var values: [UInt32] = []
            values.reserveCapacity(Int(count))
            for _ in 0..<count {
                values.append(try dataStream.read(endianess: .bigEndian))
            }
            
            self = .layerSelectionIDs(values)
        case .hdrToningInformation:
            /// 0x042E 1070 (Photoshop CS2) HDR Toning information
            self = .hdrToningInformation(try dataStream.readBytes(count: dataStream.count))
        case .printInfo:
            /// 0x042F 1071 (Photoshop CS2) Print info
            self = .printInfo(try dataStream.readBytes(count: dataStream.count))
        case .layerGroupsEnabledID:
            /// 0x0430 1072 (Photoshop CS2) Layer Group(s) Enabled ID. 1 byte for each layer in the document, repeated
            /// by length of the resource. NOTE: Layer groups have start and end markers
            var values: [Bool] = []
            values.reserveCapacity(dataStream.count)
            for _ in 0..<dataStream.count {
                values.append(try dataStream.read() as UInt8 != 0)
            }
            
            self = .layerGroupsEnabledID(values)
        case .colorSamplersResource:
            /// 0x0431 1073 (Photoshop CS3) Color samplers resource. Also see ID 1038 for old format. See See Color samplers resource format.
            self = .colorSamplersResource(try ColorSamplersResource(dataStream: &dataStream))
        case .measurementScale:
            /// 0x0432 1074 (Photoshop CS3) Measurement Scale. 4 bytes (descriptor version = 16), Descriptor (see See
            /// Descriptor structure)
            self = .measurementScale(try VersionedDescriptor(dataStream: &dataStream))
        case .timelineInformation:
            /// 0x0433 1075 (Photoshop CS3) Timeline Information. 4 bytes (descriptor version = 16), Descriptor (see See
            /// Descriptor structure)
            self = .timelineInformation(try VersionedDescriptor(dataStream: &dataStream))
        case .sheetDisclosure:
            /// 0x0434 1076 (Photoshop CS3) Sheet Disclosure. 4 bytes (descriptor version = 16), Descriptor (see See
            /// Descriptor structure)
            self = .sheetDisclosure(try VersionedDescriptor(dataStream: &dataStream))
        case .displayInfo:
            /// 0x0435 1077 (Photoshop CS3) DisplayInfo structure to support floating point clors. Also see ID 1007.
            /// See Appendix A in Photoshop API Guide.pdf .
            if dataStream.count == 17 {
                self = .displayInfo(try DisplayInfo(dataStream: &dataStream))
            } else {
                self = .unknown(id: id, try dataStream.readBytes(count: dataStream.count))
            }
        case .onionSkins:
            /// 0x0436 1078 (Photoshop CS3) Onion Skins. 4 bytes (descriptor version = 16), Descriptor (see See
            /// Descriptor structure)
            self = .onionSkins(try VersionedDescriptor(dataStream: &dataStream))
        case .countInformation:
            /// 0x0438 1080 (Photoshop CS4) Count Information. 4 bytes (descriptor version = 16), Descriptor (see See
        /// Descriptor structure) Information about the count in the document. See the Count Tool.
            self = .countInformation(try VersionedDescriptor(dataStream: &dataStream))
        case .printInformation:
            /// 0x043A 1082 (Photoshop CS5) Print Information. 4 bytes (descriptor version = 16), Descriptor (see See
            /// Descriptor structure) Information about the current print settings in the document. The color management options.
            self = .printInformation(try VersionedDescriptor(dataStream: &dataStream))
        case .printStyle:
            /// 0x043B 1083 (Photoshop CS5) Print Style. 4 bytes (descriptor version = 16), Descriptor (see See
            /// Descriptor structure) Information about the current print style in the document. The printing marks, labels, ornaments, etc.
            self = .printStyle(try VersionedDescriptor(dataStream: &dataStream))
        case .macNSPrintInfo:
            /// 0x043C 1084 (Photoshop CS5) Macintosh NSPrintInfo. Variable OS specific info for Macintosh. NSPrintInfo.
            /// It is recommened that you do not interpret or use this data.
            self = .macNSPrintInfo(try dataStream.readBytes(count: dataStream.count))
        case .windowsDEVOMDE:
            ///0x043D 1085 (Photoshop CS5) Windows DEVMODE. Variable OS specific info for Windows. DEVMODE.
            ///It is recommened that you do not interpret or use this data.
            self = .windowsDEVMODE(try dataStream.readBytes(count: dataStream.count))
        case .autoSaveFilePath:
            /// 0x043E 1086 (Photoshop CS6) Auto Save File Path. Unicode string. It is recommened that you do not
            /// interpret or use this data.
            self = .autoSaveFilePath(try dataStream.readUnicodeString())
        case .autoSaveFormat:
            /// 0x043F 1087 (Photoshop CS6) Auto Save Format. Unicode string. It is recommened that you do not interpret
            /// or use this data.
            self = .autoSaveFilePath(try dataStream.readUnicodeString())
        case .pathSelectionState:
            /// 0x0440 1088 (Photoshop CC) Path Selection State. 4 bytes (descriptor version = 16), Descriptor (see See Descriptor structure) Information about the current path selection state.
            self = .pathSelectionState(try VersionedDescriptor(dataStream: &dataStream))
        case .nameOfClippingPath:
            /// 0x0BB7 2999 Name of clipping path. See See Path resource format.
            let startPosition = dataStream.position
            let count = dataStream.count / 26
            var values: [PathRecord] = []
            values.reserveCapacity(count)
            for _ in 0..<count {
                values.append(try PathRecord(dataStream: &dataStream))
            }
            
            self = .nameOfClippingPath(values)
            
            // Seen four byte padding
            if dataStream.remainingCount > 0 && dataStream.remainingCount < 4 {
                try dataStream.readFourByteAlignmentPadding(startPosition: startPosition)
            }
        case .originPathInfo:
            /// 0x0BB8 3000 (Photoshop CC) Origin Path Info. 4 bytes (descriptor version = 16), Descriptor (see See
            /// Descriptor structure) Information about the origin path data.
            self = .originPathInfo(try VersionedDescriptor(dataStream: &dataStream))
        case .imageReadVariables:
            /// 0x1B58 7000 Image Ready variables. XML representation of variables definition
            guard let data = try dataStream.readString(count: dataStream.count, encoding: .ascii) else {
                throw PhotoshopReadError.corrupted
            }
            
            self = .imageReadVariables(data)
        case .imageReadDataSets:
            /// 0x1B59 7001 Image Ready data sets
            self = .imageReadDataSets(try dataStream.readBytes(count: dataStream.count))
        case .imageReadyDefaultSelectedState:
            /// 0x1B5A 7002 Image Ready default selected state
            self = .imageReadyDefaultSelectedState(try dataStream.readBytes(count: dataStream.count))
        case .imageReady7RolloverExpandedState:
            /// 0x1B5B 7003 Image Ready 7 rollover expanded state
            self = .imageReady7RolloverExpandedState(try dataStream.readBytes(count: dataStream.count))
        case .imageReadyRolloverExpandedState:
            /// 0x1B5C 7004 Image Ready rollover expanded state
            self = .imageReadyRolloverExpandedState(try dataStream.readBytes(count: dataStream.count))
        case .imageReadySaveLayerSettings:
            /// 0x1B5D 7005 Image Ready save layer settings
            self = .imageReadySaveLayerSettings(try dataStream.readBytes(count: dataStream.count))
        case .imageReadyVersion:
            /// 0x1B5E 7006 Image Ready version
            self = .imageReadyVersion(try dataStream.readBytes(count: dataStream.count))
        case .lightroomWorkflow:
            /// 0x1F40 8000 (Photoshop CS3) Lightroom workflow, if present the document is in the middle of a Lightroom
            /// workflow.
            self = .lightroomWorkflow(try dataStream.readBytes(count: dataStream.count))
        case .printFlagsInformation:
            /// 0x2710 10000 Print flags information. 2 bytes version ( = 1), 1 byte center crop marks, 1 byte ( = 0), 4 bytes
            /// bleed width value, 2 bytes bleed width scale.
            guard dataStream.count == 10 else {
                throw PhotoshopReadError.corrupted
            }

            self = .printFlagsInformation(try PrintFlagsInformation(dataStream: &dataStream))
        }
        
        guard dataStream.remainingCount == 0 else {
            throw PhotoshopReadError.corrupted
        }
    }
}
