//
//  LinkedLayer.swift
//  
//
//  Created by Hugh Bellamy on 20/01/2021.
//

import DataStream

/// Linked Layer
/// Key is 'lnkD' . Also keys 'lnk2' and 'lnk3' . Data is as follows:
/// Linked Layer
public struct LinkedLayer {
    public let length1: UInt64
    public let type: String
    public let version: UInt32
    public let uniqueID: String
    public let originalFileName: String
    public let fileType: UInt32
    public let fileCreator: UInt32
    public let length2: UInt32
    public let openParametersDescriptor: Descriptor?
    public let linkedParametersDescriptor: Descriptor?
    public let year: UInt32?
    public let month: UInt8?
    public let day: UInt8?
    public let hour: UInt8?
    public let minute: UInt8?
    public let seconds: Double?
    public let fileSize: UInt64?
    public let padding: UInt64?
    public let rawData: DataStream?
    public let childDocumentID: String?
    public let assetModTime: Double?
    public let assetLockedState: UInt8?
    public let rawData2: DataStream?
    
    public init(dataStream: inout DataStream) throws {
        /// 8 Length of the data to follow
        self.length1 = try dataStream.read(endianess: .bigEndian)
        guard self.length1 <= dataStream.remainingCount else {
            throw PhotoshopReadError.corrupted
        }
        
        /// 4 Type ( = 'liFD' linked file data, 'liFE' linked file external or 'liFA' linked file alias )
        guard let type = try dataStream.readString(count: 4, encoding: .ascii) else {
            throw PhotoshopReadError.corrupted
        }
        
        self.type = type
        
        /// 4 Version ( = 1 to 7 )
        let version: UInt32 = try dataStream.read(endianess: .bigEndian)
        guard version >= 1 else {
            throw PhotoshopReadError.corrupted
        }
        
        self.version = version
        
        /// Variable Pascal string. Unique ID.
        self.uniqueID = try dataStream.readPascalString()
        
        /// Variable Unicode string of the original file name
        self.originalFileName = try dataStream.readUnicodeString()
        
        /// 4 File Type
        self.fileType = try dataStream.read(endianess: .bigEndian)
        
        /// 4 File Creator
        self.fileCreator = try dataStream.read(endianess: .bigEndian)
        
        /// 8 Length of the data to follow
        self.length2 = try dataStream.read(endianess: .bigEndian)
        guard self.length2 <= dataStream.remainingCount else {
            throw PhotoshopReadError.corrupted
        }
        
        /// 1 File open descriptor
        let hasFileOpenDescriptor = try dataStream.read() as UInt8 != 0
        
        /// Variable Descriptor of open parameters. Only present when above is true.
        if hasFileOpenDescriptor {
            self.openParametersDescriptor = try Descriptor(dataStream: &dataStream)
        } else {
            self.openParametersDescriptor = nil
        }
        
        /// If the type is 'liFE' then a linked file Descriptor is next.
        /// Variable Descriptor of linked file parameters. See comment above.
        if type == "liFE" {
            self.linkedParametersDescriptor = try Descriptor(dataStream: &dataStream)
        } else {
            self.linkedParametersDescriptor = nil
        }
        
        /// If the type is 'liFE' and the version is greater than 3 then the following is present. Year, Month, Day, Hour, Minute, Second is next.
        if type == "liFE" && version > 3 {
            /// 4 Year
            self.year = try dataStream.read(endianess: .bigEndian)
            
            /// 1 Month
            self.month = try dataStream.read()
            
            /// 1 Day
            self.day = try dataStream.read()

            /// 1 Hour
            self.hour = try dataStream.read()
            
            /// 1 Minute
            self.minute = try dataStream.read()

            /// 8 Double for the seconds
            self.seconds = try dataStream.readDouble(endianess: .bigEndian)
        } else {
            self.year = nil
            self.month = nil
            self.day = nil
            self.hour = nil
            self.minute = nil
            self.seconds = nil
        }
        
        /// If the type is 'liFE' then a file size is next.
        /// 8 File size
        if self.type == "liFE" {
            let fileSize: UInt64 = try dataStream.read(endianess: .bigEndian)
            guard fileSize <= dataStream.remainingCount else {
                throw PhotoshopReadError.corrupted
            }
            
            self.fileSize = fileSize
        } else {
            self.fileSize = nil
        }
        
        /// If the type is 'liFA' then 4 zeros are next.
        /// 8 All zeros
        if self.type == "liFA" {
            self.padding = try dataStream.read(endianess: .bigEndian)
        } else {
            self.padding = nil
        }
        
        /// If the type is 'liFE' then they bytes of the file are next.
        /// Variable Raw bytes of the file.
        if self.type == "liFE" {
            self.rawData = DataStream(slicing: dataStream, startIndex: dataStream.position, count: Int(self.fileSize!))
            dataStream.position += Int(fileSize!)
        } else {
            self.rawData = nil
        }
        
        /// If the version is greater than or equal to 5 then the following is next.
        /// UnicodeString Child Document ID.
        if self.version >= 5 {
            self.childDocumentID = try dataStream.readUnicodeString()
        } else {
            self.childDocumentID = nil
        }
        
        /// If the version is greater than or equal to 6 then the following is next.
        /// Double Asset mod time.
        if self.version >= 6 {
            self.assetModTime = try dataStream.readDouble(endianess: .bigEndian)
        } else {
            self.assetModTime = nil
        }
        
        /// If the version is greater than or equal to 7 then the following is next.
        /// 1 Asset locked state, for Libraries assets.
        if self.version >= 6 {
            self.assetLockedState = try dataStream.read()
        } else {
            self.assetLockedState = nil
        }
    
        /// If the type is 'liFE' and the version is 2 then the following is next.
        /// Variable Raw bytes of the file.
        if self.type == "liFE" && version == 2 {
            self.rawData2 = DataStream(slicing: dataStream, startIndex: dataStream.position, count: Int(self.fileSize!))
            dataStream.position += Int(fileSize!)
        } else {
            self.rawData2 = nil
        }
        
        /// Skip remaining data.
        dataStream.position += dataStream.remainingCount
    }
    
    /// 4 Type ( = 'liFD' linked file data, 'liFE' linked file external or 'liFA' linked file alias )
    public enum LinkedFileType: String {
        case linkedFileData = "liFD"
        case linkedFileExternal = "liFE"
        case linkedFileAlias = "liFA"
    }
}
