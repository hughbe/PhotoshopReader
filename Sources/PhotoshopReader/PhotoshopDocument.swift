//
//  PhotoshopDocument.swift
//  
//
//  Created by Hugh Bellamy on 30/11/2020.
//

import DataStream
import Foundation

/// Photoshop file structure
/// Photoshop File Format
/// File header (File Header Section).
/// Color mode data (Color Mode Data Section)
/// Image resources (Image Resources Section)
/// Layer and mask information (Layer and Mask Information Section)
/// Image data (Image Data Section).
/// The file header has a fixed length; the other four sections are variable in length.
/// When writing one of these sections, you should write all fields in the section, as Photoshop may try to read the entire section. Whenever writing a file and skipping bytes, you should explicitly write zeros for the skipped fields.
/// When reading one of the length-delimited sections, use the length field to decide when you should stop reading. In most cases, the length field indicates the number of bytes, not records, following.
/// The values in "Length" column in all tables are in bytes.
/// All values defined as Unicode string consist of:
/// A 4-byte length field, representing the number of UTF-16 code units in the string (not bytes).
/// The string of Unicode values, two bytes per character and a two byte null for the end of the string.
public struct PhotoshopDocument {
    public let header: PhotoshopDocumentHeader
    public let colorModeData: PhotoshopDocumentColorModeData
    public let imageResources: PhotoshopDocumentImageResources
    public let layerAndMaskInformation: PhotoshopDocumentLayerAndMaskInformation
    public let imageData: PhotoshopDocumentImageData
    
    public init(data: Data) throws {
        var dataStream = DataStream(data)
        try self.init(dataStream: &dataStream)
    }
    
    public init(dataStream: inout DataStream) throws {
        self.header = try PhotoshopDocumentHeader(dataStream: &dataStream)
        self.colorModeData = try PhotoshopDocumentColorModeData(dataStream: &dataStream)
        self.imageResources = try PhotoshopDocumentImageResources(dataStream: &dataStream)
        self.layerAndMaskInformation = try PhotoshopDocumentLayerAndMaskInformation(dataStream: &dataStream, psb: self.header.psb)
        self.imageData = try PhotoshopDocumentImageData(dataStream: &dataStream)
    }
}
