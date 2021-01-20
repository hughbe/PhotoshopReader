//
//  Path.swift
//  
//
//  Created by Hugh Bellamy on 18/01/2021.
//

import DataStream

/// Path resource format
/// Photoshop stores the paths saved with an image in an image resource block. These resource blocks consist of a series of 26-byte path
/// point records, so the resource length should always be a multiple of 26.
/// Photoshop stores its paths as resources of type 8BIM , with IDs in the range 2000 through 2997. These numbers should be reserved
/// for Photoshop. The name of the resource is the name given to the path when it was saved.
/// If the file contains a resource of type 8BIM with an ID of 2999, then this resource contains a Pascal-style string containing the name of
/// the clipping path to use with this image when saving it as an EPS file. 4 byte fixed value for flatness and 2 byte fill rule. 0 = same fill rule
/// 1 = even odd fill rule, 2 = non zero winding fill rule. The fill rule is ignored by Photoshop.
/// The path format returned by GetProperty() call is identical to what is described below. Refer to the IllustratorExport sample plug-in code
/// to see how this resource data is constructed.
/// Path points
/// All points used in defining a path are stored in eight bytes as a pair of 32-bit components, vertical component first.
/// The two components are signed, fixed point numbers with 8 bits before the binary point and 24 bits after the binary point. Three guard
/// bits are reserved in the points to eliminate most concerns over arithmetic overflow. Hence, the range for each component is 0xF0000000
/// to 0x0FFFFFFF representing a range of -16 to 16. The lower bound is included, but not the upper bound.
/// This limited range is used because the points are expressed relative to the image size. The vertical component is given with respect to
/// the image height, and the horizontal component is given with respect to the image width. [ 0,0 ] represents the top-left corner of the
/// image; [ 1,1 ] ([ 0x01000000,0x01000000 ]) represents the bottom-right.
/// Path records
/// The data in a path resource consists of one or more 26-byte records. The first two bytes of each record is a selector to indicate what
/// kind of path it is. For Windows, you should swap the bytes before accessing it as a short.
/// Path data record types
/// Selector
/// Description
/// 0 Closed subpath length record
/// 1 Closed subpath Bezier knot, linked
/// 2 Closed subpath Bezier knot, unlinked
/// 3 Open subpath length record
/// 4 Open subpath Bezier knot, linked
/// 5 Open subpath Bezier knot, unlinked
/// 6 Path fill rule record
/// 7 Clipboard record
/// 8 Initial fill rule record
/// The first 26-byte path record contains a selector value of 6, path fill rule record. The remaining 24 bytes of the first record are zeroes.
/// Paths use even/odd ruling. Subpath length records, selector value 0 or 3, contain the number of Bezier knot records in bytes 2 and 3.
/// The remaining 22 bytes are unused, and should be zeroes. Each length record is then immediately followed by the Bezier knot records
/// describing the knots of the subpath.
/// In Bezier knot records, the 24 bytes following the selector field contain three path points (described above) for:
/// the control point for the Bezier segment preceding the knot,
/// the anchor point for the knot, and
/// the control point for the Bezier segment leaving the knot.
/// Linked knots have their control points linked. Editing one point modifies the other to preserve collinearity. Knots should only be marked
/// as having linked controls if their control points are collinear with their anchor. The control points on unlinked knots are independent of
/// each other. Refer to the Adobe Photoshop User Guide for more information.
/// Clipboard records, selector=7 , contain four fixed-point numbers for the bounding rectangle (top, left, bottom, right), and a single
/// fixed-point number indicating the resolution.
/// Initial fill records, selector=8 , contain one two byte record. A value of 1 means that the fill starts with all pixels. The value will be either
/// 0 or 1.
/// In Windows, the byte order of the path point components are reversed; you should swap the bytes when accessing each 32-bit value.
public enum PathRecord {
    /// 0 Closed subpath length record
    case closedSubpathLength(numberOfBezierKnotRecords: UInt16)
    
    /// 1 Closed subpath Bezier knot, linked
    case closedSubpathBezierKnotLinked(_: PathPoint, _: PathPoint, _: PathPoint)
    
    /// 2 Closed subpath Bezier knot, unlinked
    case closedSubpathBezierKnotUnlinked(_: PathPoint, _: PathPoint, _: PathPoint)
    
    /// 3 Open subpath length record
    case openSubpathLength
    
    /// 4 Open subpath Bezier knot, linked
    case openSubpathBezierKnotLinked(_: PathPoint, _: PathPoint, _: PathPoint)
    
    /// 5 Open subpath Bezier knot, unlinked
    case openSubpathBezierKnotUnlinked(_: PathPoint, _: PathPoint, _: PathPoint)
    
    /// 6 Path fill rule record
    case pathFillRule
    
    /// 7 Clipboard record
    case clipboard
    
    /// 8 Initial fill rule record
    case initialFillRule(fillStartsWithAllPixels: Bool)
    
    public init(dataStream: inout DataStream) throws {
        guard dataStream.remainingCount >= 26 else {
            throw PhotoshopReadError.corrupted
        }
        
        let startPosition = dataStream.position
        
        let selector: UInt16 = try dataStream.read(endianess: .bigEndian)
        
        switch selector {
        case 0:
            self = .closedSubpathLength(numberOfBezierKnotRecords: try dataStream.read(endianess: .bigEndian))
            guard dataStream.position + 22 <= dataStream.count else {
                throw PhotoshopReadError.corrupted
            }

            dataStream.position += 22
        case 1:
            self = .closedSubpathBezierKnotLinked(
                try PathPoint(dataStream: &dataStream),
                try PathPoint(dataStream: &dataStream),
                try PathPoint(dataStream: &dataStream)
            )
        case 2:
            self = .closedSubpathBezierKnotUnlinked(
                try PathPoint(dataStream: &dataStream),
                try PathPoint(dataStream: &dataStream),
                try PathPoint(dataStream: &dataStream)
            )
        case 3:
            self = .closedSubpathLength(numberOfBezierKnotRecords: try dataStream.read(endianess: .bigEndian))
            guard dataStream.position + 22 <= dataStream.count else {
                throw PhotoshopReadError.corrupted
            }

            dataStream.position += 22
        case 4:
            self = .openSubpathBezierKnotUnlinked(
                try PathPoint(dataStream: &dataStream),
                try PathPoint(dataStream: &dataStream),
                try PathPoint(dataStream: &dataStream)
            )
        case 5:
            self = .openSubpathBezierKnotUnlinked(
                try PathPoint(dataStream: &dataStream),
                try PathPoint(dataStream: &dataStream),
                try PathPoint(dataStream: &dataStream)
            )
        case 6:
            self = .pathFillRule
            guard dataStream.position + 24 <= dataStream.count else {
                throw PhotoshopReadError.corrupted
            }

            dataStream.position += 24
        case 8:
            let fillStartsWithAllPixels = (try dataStream.read(endianess: .bigEndian) as UInt16) != 0
            self = .initialFillRule(fillStartsWithAllPixels: fillStartsWithAllPixels)
            guard dataStream.position + 22 <= dataStream.count else {
                throw PhotoshopReadError.corrupted
            }

            dataStream.position += 22
        default:
            throw PhotoshopReadError.corrupted
        }
        
        guard dataStream.position - startPosition == 26 else {
            throw PhotoshopReadError.corrupted
        }
    }
    
    public struct PathPoint {
        public let vertical: Float
        public let horizontal: Float
        
        public init(dataStream: inout DataStream) throws {
            func readFixed() throws -> Float {
                let rawValue: UInt32 = try dataStream.read(endianess: .bigEndian)
                return Float(rawValue)
            }
            
            self.vertical = try readFixed()
            self.horizontal = try readFixed()
        }
    }
}
