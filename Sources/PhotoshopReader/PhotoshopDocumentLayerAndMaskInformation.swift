//
//  PhotoshopDocumentLayerAndMaskInformation.swift
//  
//
//  Created by Hugh Bellamy on 18/01/2021.
//

import DataStream

/// Layer and Mask Information Section
/// The fourth section of a Photoshop file contains information about layers and masks. This section of the document describes the
/// formats of layer and mask records.
/// The complete merged image data is not stored here. The complete merged/composite image resides in the last section of the file.
/// See See Image Data Section. If maximize compatibility is unchecked then the merged/composite is not created and the layer data
/// must be read to reproduce the final image.
/// See Layer and mask information section shows the overall structure of this section. If there are no layers or masks, this section is
/// just 4 bytes: the length field, which is set to zero. (**PSB** length is 8 bytes
/// 'Layr', 'Lr16' and 'Lr32' start at See Layer info. NOTE: The length of the section may already be known.)
/// When parsing this section pay close attention to the length of sections.
public struct PhotoshopDocumentLayerAndMaskInformation {
    public let length: UInt64
    public let layerInfo: LayerInfo?
    
    public init(dataStream: inout DataStream, psb: Bool) throws {
        /// 4 The length of the following color data.
        if psb {
            self.length = try dataStream.read(endianess: .bigEndian)
        } else {
            self.length = UInt64(try dataStream.read(endianess: .bigEndian) as UInt32)
        }
        guard self.length <= dataStream.remainingCount else {
            throw PhotoshopReadError.corrupted
        }
        
        if self.length == 0 {
            self.layerInfo = nil
            return
        }
        
        let startPosition = dataStream.position
        
        var actualDataStream = DataStream(slicing: dataStream, startIndex: dataStream.position, count: Int(self.length))
        self.layerInfo = try LayerInfo(dataStream: &actualDataStream, psb: psb)
        dataStream.position += Int(self.length)
        
        guard dataStream.position - startPosition == self.length else {
            throw PhotoshopReadError.corrupted
        }
    }
}

