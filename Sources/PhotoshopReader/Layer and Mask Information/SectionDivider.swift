//
//  SectionDivider.swift
//  
//
//  Created by Hugh Bellamy on 19/01/2021.
//

import DataStream

/// Section divider setting (Photoshop 6.0)
/// Key is 'lsct' . Data is as follows:
public struct SectionDivider {
    public let type: DividerType
    public let signature: String?
    public let key: String?
    public let subType: DividerSubType?
    
    public init(dataStream: inout DataStream) throws {
        /// 4 Type. 4 possible values, 0 = any other type of layer, 1 = open "folder", 2 = closed "folder", 3 = bounding section divider,
        /// hidden in the UI
        self.type = try DividerType(dataStream: &dataStream)
        
        if dataStream.remainingCount == 0 {
            self.signature = nil
            self.key = nil
            self.subType = nil
            return
        }
        
        /// Following is only present if length >= 12
        /// 4 Signature: '8BIM'
        guard let signature = try dataStream.readString(count: 4, encoding: .ascii) else {
            throw PhotoshopReadError.corrupted
        }
        guard signature == "8BIM" else {
            throw PhotoshopReadError.corrupted
        }
        
        self.signature = signature

        /// 4 Key. See blend mode keys in See Layer records.
        guard let key = try dataStream.readString(count: 4, encoding: .ascii) else {
            throw PhotoshopReadError.corrupted
        }
        
        self.key = key
        
        if dataStream.remainingCount == 0 {
            self.subType = nil
            return
        }
        
        /// Following is only present if length >= 16
        /// 4 Sub type. 0 = normal, 1 = scene group, affects the animation timeline.
        self.subType = try DividerSubType(dataStream: &dataStream)
    }
    
    /// 4 Type. 4 possible values, 0 = any other type of layer, 1 = open "folder", 2 = closed "folder", 3 = bounding section divider,
    /// hidden in the UI
    public enum DividerType: UInt32, DataStreamCreatable {
        case anyOtherType = 0
        case openFolder = 1
        case closedFolder = 2
        case boundingSectionDivider = 3
    }
    
    /// 4 Sub type. 0 = normal, 1 = scene group, affects the animation timeline.
    public enum DividerSubType: UInt32, DataStreamCreatable {
        case normal = 0
        case sceneGroup = 1
    }
}
