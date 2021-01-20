//
//  ImageResourceID.swift
//  
//
//  Created by Hugh Bellamy on 18/01/2021.
//

/// Image Resource IDs
/// Image resources use several standard ID numbers, as shown in the Image resource IDs. Not all file formats use all ID's. Some information may
/// be stored in other sections of the file.
/// For those resource IDs that have been added since Photoshop 3.0. the entry indicates the version in which they were introduced, e.g.
/// ( Photoshop 6.0).
public enum ImageResourceID: UInt16 {
    /// 0x03E8 1000 (Obsolete--Photoshop 2.0 only ) Contains five 2-byte values: number of channels, rows, columns, depth, and mode
    case channelInfo = 0x03E8

    /// 0x03E9 1001 Macintosh print manager print info record
    case macPrintManagerPrintInfo = 0x03E9

    /// 0x03EA 1002 Macintosh page format information. No longer read by Photoshop. (Obsolete)
    case macPageFormatInformation = 0x03EA

    /// 0x03EB 1003 (Obsolete--Photoshop 2.0 only ) Indexed color table
    case indexedColorTable = 0x03EB

    /// 0x03ED 1005 ResolutionInfo structure. See Appendix A in Photoshop API Guide.pdf.
    case resolutionInfo = 0x03ED

    /// 0x03EE 1006 Names of the alpha channels as a series of Pascal strings.
    case alphaChannelNames = 0x03EE

    /// 0x03EF 1007 (Obsolete) See ID 1077DisplayInfo structure. See Appendix A in Photoshop API Guide.pdf.
    case displayInfoObsolete = 0x03EF

    /// 0x03F0 1008 The caption as a Pascal string.
    case caption = 0x03F0

    /// 0x03F1 1009 Border information. Contains a fixed number (2 bytes real, 2 bytes fraction) for the border width, and 2 bytes for border
    /// units (1 = inches, 2 = cm, 3 = points, 4 = picas, 5 = columns).
    case borderInformation = 0x03F1

    /// 0x03F2 1010 Background color. See See Color structure.
    case backgroundColor = 0x03F2

    /// 0x03F3 1011 Print flags. A series of one-byte boolean values (see Page Setup dialog): labels, crop marks, color bars, registration marks,
    /// negative, flip, interpolate, caption, print flags.
    case printFlags = 0x03F3

    /// 0x03F4 1012 Grayscale and multichannel halftoning information
    case grayscaleAndMultichannelHalftoningInformation = 0x03F4

    /// 0x03F5 1013 Color halftoning information
    case colorHalftoningInformation = 0x03F5

    /// 0x03F6 1014 Duotone halftoning information
    case duotoneHalftoningInformation = 0x03F6

    /// 0x03F7 1015 Grayscale and multichannel transfer function
    case grayscaleAndMultichannelTransferFunction = 0x03F7

    /// 0x03F8 1016 Color transfer functions
    case colorTransferFunctions = 0x03F8

    /// 0x03F9 1017 Duotone transfer functions
    case duotoneTransferFunctions = 0x03F9

    /// 0x03FA 1018 Duotone image information
    case duotoneImageInformation = 0x03FA

    /// 0x03FB 1019 Two bytes for the effective black and white values for the dot range
    case blackAndWhiteValuesForDotRange = 0x03FB

    /// 0x03FC 1020 (Obsolete)
    case obsolete0x03FC = 0x03FC

    /// 0x03FD 1021 EPS options
    case epsOptions = 0x03FD

    /// 0x03FE 1022 Quick Mask information. 2 bytes containing Quick Mask channel ID; 1- byte boolean indicating whether the mask was
    /// initially empty.
    case quickMaskInformation = 0x03FE

    /// 0x03FF 1023 (Obsolete)
    case obsolete0x03FF = 0x03FF

    /// 0x0400 1024 Layer state information. 2 bytes containing the index of target layer (0 = bottom layer).
    case layerStateInformation = 0x0400

    /// 0x0401 1025 Working path (not saved). See See Path resource format.
    case workingPath = 0x0401

    /// 0x0402 1026 Layers group information. 2 bytes per layer containing a group ID for the dragging groups. Layers in a group have the same group ID.
    case layersGroupInformation = 0x0402

    /// 0x0403 1027 (Obsolete)
    case obsolete0x0403 = 0x0403

    /// 0x0404 1028 IPTC-NAA record. Contains the File Info... information. See the documentation in the IPTC folder of the Documentation folder.
    case iptcNAARecord = 0x0404

    /// 0x0405 1029 Image mode for raw format files
    case imageMode = 0x0405

    /// 0x0406 1030 JPEG quality. Private.
    case jpegQuality = 0x0406

    /// 0x0408 1032 (Photoshop 4.0) Grid and guides information. See See Grid and guides resource format.
    case gridAndGuidesInformation = 0x0408

    /// 0x0409 1033 (Photoshop 4.0) Thumbnail resource for Photoshop 4.0 only. See See Thumbnail resource format.
    case thumbnailResourceObsolete = 0x0409

    /// 0x040A 1034 (Photoshop 4.0) Copyright flag. Boolean indicating whether image is copyrighted. Can be set via Property suite or by user
    /// in File Info...
    case copyrightFlag = 0x040A

    /// 0x040B 1035 (Photoshop 4.0) URL. Handle of a text string with uniform resource locator. Can be set via Property suite or by user in
    /// File Info...
    case url = 0x040B

    /// 0x040C 1036 (Photoshop 5.0) Thumbnail resource (supersedes resource 1033). See See Thumbnail resource format.
    case thumbnailResource = 0x040C

    /// 0x040D 1037 (Photoshop 5.0) Global Angle. 4 bytes that contain an integer between 0 and 359, which is the global lighting angle for
    /// effects layer. If not present, assumed to be 30.
    case globalAngle = 0x040D

    /// 0x040E 1038 (Obsolete) See ID 1073 below. (Photoshop 5.0) Color samplers resource. See See Color samplers resource format.
    case colorSamplersResourceObsolete = 0x040E

    /// 0x040F 1039 (Photoshop 5.0) ICC Profile. The raw bytes of an ICC (International Color Consortium) format profile. See
    /// ICC1v42_2006-05.pdf in the Documentation folder and icProfileHeader.h in Sample Code\Common\Includes .
    case iccProfile = 0x040F

    /// 0x0410 1040 (Photoshop 5.0) Watermark. One byte.
    case watermark = 0x0410

    /// 0x0411 1041 (Photoshop 5.0) ICC Untagged Profile. 1 byte that disables any assumed profile handling when opening the file.
    /// 1 = intentionally untagged.
    case iccUntaggedProfile = 0x0411

    /// 0x0412 1042 (Photoshop 5.0) Effects visible. 1-byte global flag to show/hide all the effects layer. Only present when they are hidden.
    case effectsVisible = 0x0412

    /// 0x0413 1043 (Photoshop 5.0) Spot Halftone. 4 bytes for version, 4 bytes for length, and the variable length data.
    case spotHalftone = 0x0413

    /// 0x0414 1044 (Photoshop 5.0) Document-specific IDs seed number. 4 bytes: Base value, starting at which layer IDs will be generated
    /// (or a greater value if existing IDs already exceed it). Its purpose is to avoid the case where we add layers, flatten, save, open, and then add more layers that end up with the same IDs as the first set.
    case documentSpecificIDsSeedNumber = 0x0414

    /// 0x0415 1045 (Photoshop 5.0) Unicode Alpha Names. Unicode string
    case unicodeAlphaChannelNames = 0x0415

    /// 0x0416 1046 (Photoshop 6.0) Indexed Color Table Count. 2 bytes for the number of colors in table that are actually defined
    case indexedColorTableCount = 0x0416

    /// 0x0417 1047 (Photoshop 6.0) Transparency Index. 2 bytes for the index of transparent color, if any.
    case transparencyIndex = 0x0417

    /// 0x0419 1049 (Photoshop 6.0) Global Altitude. 4 byte entry for altitude
    case globalAltitude = 0x0419

    /// 0x041A 1050 (Photoshop 6.0) Slices. See See Slices resource format.
    case slices = 0x041A

    /// 0x041B 1051 (Photoshop 6.0) Workflow URL. Unicode string
    case workflowURL = 0x041B

    /// 0x041C 1052 (Photoshop 6.0) Jump To XPEP. 2 bytes major version, 2 bytes minor version, 4 bytes count. Following is repeated for count: 4 bytes block size, 4 bytes key, if key = 'jtDd' , then next is a Boolean for the dirty flag; otherwise it's a 4 byte entry for the mod date.
    case jumpToXPEP = 0x041C

    /// 0x041D 1053 (Photoshop 6.0) Alpha Identifiers. 4 bytes of length, followed by 4 bytes each for every alpha identifier.
    case alphaIdentifiers = 0x041D

    /// 0x041E 1054 (Photoshop 6.0) URL List. 4 byte count of URLs, followed by 4 byte long, 4 byte ID, and Unicode string for each count.
    case urlList = 0x041E

    /// 0x0421 1057 (Photoshop 6.0) Version Info. 4 bytes version, 1 byte hasRealMergedData , Unicode string: writer name, Unicode string: reader name, 4 bytes file version.
    case versionInfo = 0x0421

    /// 0x0422 1058 (Photoshop 7.0) EXIF data 1. See http://www.kodak.com/global/plugins/acrobat/en/service/digCam/exifStandard2.pdf
    case exifData1 = 0x0422

    /// 0x0423 1059 (Photoshop 7.0) EXIF data 3. See http://www.kodak.com/global/plugins/acrobat/en/service/digCam/exifStandard2.pdf
    case exifData3 = 0x0423

    /// 0x0424 1060 (Photoshop 7.0) XMP metadata. File info as XML description. See http://www.adobe.com/devnet/xmp/
    case xmpMetadata = 0x0424

    /// 0x0425 1061 (Photoshop 7.0) Caption digest. 16 bytes: RSA Data Security, MD5 message-digest algorithm
    case captionDigest = 0x0425

    /// 0x0426 1062 (Photoshop 7.0) Print scale. 2 bytes style (0 = centered, 1 = size to fit, 2 = user defined). 4 bytes x location (floating point). 4 bytes y location (floating point). 4 bytes scale (floating point)
    case printScale = 0x0426

    /// 0x0428 1064 (Photoshop CS) Pixel Aspect Ratio. 4 bytes (version = 1 or 2), 8 bytes double, x / y of a pixel. Version 2, attempting to correct values for NTSC and PAL, previously off by a factor of approx. 5%.
    case pixelAspectRatio = 0x0428

    /// 0x0429 1065 (Photoshop CS) Layer Comps. 4 bytes (descriptor version = 16), Descriptor (see See Descriptor structure)
    case layerComps = 0x0429

    /// 0x042A 1066 (Photoshop CS) Alternate Duotone Colors. 2 bytes (version = 1), 2 bytes count, following is repeated for each count: [ Color: 2 bytes for space followed by 4 * 2 byte color component ], following this is another 2 byte count, usually 256, followed by Lab colors one byte each for L, a, b. This resource is not read or used by Photoshop.
    case alternateDuotoneColors = 0x042A

    /// 0x042B 1067 (Photoshop CS) Alternate Spot Colors. 2 bytes (version = 1), 2 bytes channel count, following is repeated for each count: 4 bytes channel ID, Color: 2 bytes for space followed by 4 * 2 byte color component. This resource is not read or used by Photoshop.
    case alternateSpotColors = 0x042B

    /// 0x042D 1069 (Photoshop CS2) Layer Selection ID(s). 2 bytes count, following is repeated for each count: 4 bytes layer ID
    case layerSelectionIDs = 0x042D

    /// 0x042E 1070 (Photoshop CS2) HDR Toning information
    case hdrToningInformation = 0x042E

    /// 0x042F 1071 (Photoshop CS2) Print info
    case printInfo = 0x042F

    /// 0x0430 1072 (Photoshop CS2) Layer Group(s) Enabled ID. 1 byte for each layer in the document, repeated by length of the resource. NOTE: Layer groups have start and end markers
    case layerGroupsEnabledID = 0x0430

    /// 0x0431 1073 (Photoshop CS3) Color samplers resource. Also see ID 1038 for old format. See See Color samplers resource format.
    case colorSamplersResource = 0x0431

    /// 0x0432 1074 (Photoshop CS3) Measurement Scale. 4 bytes (descriptor version = 16), Descriptor (see See Descriptor structure)
    case measurementScale = 0x0432

    /// 0x0433 1075 (Photoshop CS3) Timeline Information. 4 bytes (descriptor version = 16), Descriptor (see See Descriptor structure)
    case timelineInformation = 0x0433

    /// 0x0434 1076 (Photoshop CS3) Sheet Disclosure. 4 bytes (descriptor version = 16), Descriptor (see See Descriptor structure)
    case sheetDisclosure = 0x0434

    /// 0x0435 1077 (Photoshop CS3) DisplayInfo structure to support floating point clors. Also see ID 1007. See Appendix A in Photoshop API Guide.pdf .
    case displayInfo = 0x0435

    /// 0x0436 1078 (Photoshop CS3) Onion Skins. 4 bytes (descriptor version = 16), Descriptor (see See Descriptor structure)
    case onionSkins = 0x0436

    /// 0x0438 1080 (Photoshop CS4) Count Information. 4 bytes (descriptor version = 16), Descriptor (see See Descriptor structure) Information about the count in the document. See the Count Tool.
    case countInformation = 0x0438

    /// 0x043A 1082 (Photoshop CS5) Print Information. 4 bytes (descriptor version = 16), Descriptor (see See Descriptor structure) Information about the current print settings in the document. The color management options.
    case printInformation = 0x043A

    /// 0x043B 1083 (Photoshop CS5) Print Style. 4 bytes (descriptor version = 16), Descriptor (see See Descriptor structure) Information about the current print style in the document. The printing marks, labels, ornaments, etc.
    case printStyle = 0x043B

    /// 0x043C 1084 (Photoshop CS5) Macintosh NSPrintInfo. Variable OS specific info for Macintosh. NSPrintInfo. It is recommened that you do not interpret or use this data.
    case macNSPrintInfo = 0x043C

    /// 0x043D 1085 (Photoshop CS5) Windows DEVMODE. Variable OS specific info for Windows. DEVMODE. It is recommened that you do not interpret or use this data.
    case windowsDEVOMDE = 0x043D

    /// 0x043E 1086 (Photoshop CS6) Auto Save File Path. Unicode string. It is recommened that you do not interpret or use this data.
    case autoSaveFilePath = 0x043E

    /// 0x043F 1087 (Photoshop CS6) Auto Save Format. Unicode string. It is recommened that you do not interpret or use this data.
    case autoSaveFormat = 0x043F

    /// 0x0440 1088 (Photoshop CC) Path Selection State. 4 bytes (descriptor version = 16), Descriptor (see See Descriptor structure) Information about the current path selection state.
    case pathSelectionState = 0x0440

    /// 0x0BB7 2999 Name of clipping path. See See Path resource format.
    case nameOfClippingPath = 0x0BB7

    /// 0x0BB8 3000 (Photoshop CC) Origin Path Info. 4 bytes (descriptor version = 16), Descriptor (see See Descriptor structure) Information about the origin path data.
    case originPathInfo = 0x0BB8

    /// 0x1B58 7000 Image Ready variables. XML representation of variables definition
    case imageReadVariables = 0x1B58

    /// 0x1B59 7001 Image Ready data sets
    case imageReadDataSets = 0x1B59

    /// 0x1B5A 7002 Image Ready default selected state
    case imageReadyDefaultSelectedState = 0x1B5A

    /// 0x1B5B 7003 Image Ready 7 rollover expanded state
    case imageReady7RolloverExpandedState = 0x1B5B

    /// 0x1B5C 7004 Image Ready rollover expanded state
    case imageReadyRolloverExpandedState = 0x1B5C

    /// 0x1B5D 7005 Image Ready save layer settings
    case imageReadySaveLayerSettings = 0x1B5D

    /// 0x1B5E 7006 Image Ready version
    case imageReadyVersion = 0x1B5E

    /// 0x1F40 8000 (Photoshop CS3) Lightroom workflow, if present the document is in the middle of a Lightroom workflow.
    case lightroomWorkflow = 0x1F40

    /// 0x2710 10000 Print flags information. 2 bytes version ( = 1), 1 byte center crop marks, 1 byte ( = 0), 4 bytes bleed width value, 2 bytes
    /// bleed width scale.
    case printFlagsInformation = 0x2710
}
