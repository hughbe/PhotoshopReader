//
//  Descriptor.swift
//  
//
//  Created by Hugh Bellamy on 18/01/2021.
//


import DataStream

/// Descriptor structure
public struct Descriptor {
    public let name: String
    public let classID: Key
    public let items: [Item]
    
    public init(dataStream: inout DataStream) throws {
        /// Variable Unicode string: name from classID
        self.name = try dataStream.readUnicodeString()
        
        /// Variable classID: 4 bytes (length), followed either by string or (if length is zero) 4-byte classID
        self.classID = try dataStream.readKey()
        
        /// 4 Number of items in descriptor
        let numberOfItems: UInt32 = try dataStream.read(endianess: .bigEndian)
        
        /// The following is repeated for each item in descriptor
        var items: [Item] = []
        items.reserveCapacity(Int(numberOfItems))
        for _ in 0..<numberOfItems {
            items.append(try Item(dataStream: &dataStream))
        }
        
        self.items = items
    }
    
    public struct Item {
        public let key: Key
        public let value: Value
        
        public init(dataStream: inout DataStream) throws {
            /// Variable Key: 4 bytes ( length) followed either by string or (if length is zero) 4-byte key
            self.key = try dataStream.readKey()
            
            /// 4 Type: OSType key
            guard let typeRaw = try dataStream.readString(count: 4, encoding: .ascii) else {
                throw PhotoshopReadError.corrupted
            }
            guard let type = OSType(rawValue: typeRaw) else {
                throw PhotoshopReadError.corrupted
            }
            
            /// Variable Item type: see the tables below for each possible type
            self.value = try Value(dataStream: &dataStream, type: type)
        }
        
        /// 4 Type: OSType key
        public enum OSType: String {
            /// 'obj ' = Reference
            case reference = "obj "

            /// 'Objc' = Descriptor
            case descriptor = "Objc"

            /// 'VlLs' = List
            case list = "VlLs"

            /// 'doub' = Double
            case double = "doub"

            /// 'UntF' = Unit float
            case unitFloat = "UntF"

            /// 'TEXT' = String
            case string = "TEXT"

            /// 'enum' = Enumerated
            case enumerated = "enum"

            /// 'long' = Integer
            case integer = "long"

            /// 'comp' = Large Integer
            case largeInteger = "comp"

            /// 'bool' = Boolean
            case boolean = "bool"

            /// 'GlbO' = GlobalObject same as Descriptor
            case globalObject = "GlbO"

            /// 'type' = Class
            case type = "type"

            /// 'GlbC' = Class
            case glibc = "GlbC"

            /// 'alis' = Alias
            case alias = "alis"

            /// 'tdta' = Raw Data
            case rawData = "tdta"
            
            /// https://github.com/tonton-pixel/json-photoshop-scripting/tree/master/Documentation/Photoshop-Actions-File-Format/README.md
            case objectArray = "ObAr"
            
            /// https://github.com/tonton-pixel/json-photoshop-scripting/tree/master/Documentation/Photoshop-Actions-File-Format/README.md
            case unitFloats = "UnFl"
        }
        
        public enum Value {
            case descriptor(_: Descriptor)
            case list(_: [Value])
            case double(_: Double)
            case unitFloat(_: UnitFloat)
            case string(_: String)
            case enumerated(_: EnumeratedDescriptor)
            case integer(_: Int32)
            case largeInteger(_: Int64)
            case boolean(_: Bool)
            case reference(_: [ReferenceItem])
            case globalObject(_: Descriptor)
            case type(_: Class)
            case glibc(_: Class)
            case alias(_: [UInt8])
            case rawData(_: [UInt8])
            case objectArray(_: ObjectArray)
            case unitFloats(_: UnitFloats)
            
            public init(dataStream: inout DataStream, type: OSType) throws {
                switch type {
                case OSType.descriptor:
                    /// Descriptor structure
                    /// Length Description
                    /// Variable Unicode string: name from classID
                    /// Variable classID: 4 bytes (length), followed either by string or (if length is zero) 4-byte classID
                    /// 4 Number of items in descriptor
                    /// The following is repeated for each item in descriptor
                    /// Variable Key: 4 bytes ( length) followed either by string or (if length is zero) 4-byte key
                    /// 4 Type: OSType key
                    /// 'obj ' = Reference
                    /// 'Objc' = Descriptor
                    /// 'VlLs' = List
                    /// 'doub' = Double
                    /// 'UntF' = Unit float
                    /// 'TEXT' = String
                    /// 'enum' = Enumerated
                    /// 'long' = Integer
                    /// 'comp' = Large Integer
                    /// 'bool' = Boolean
                    /// 'GlbO' = GlobalObject same as Descriptor
                    /// 'type' = Class
                    /// 'GlbC' = Class
                    /// 'alis' = Alias
                    /// 'tdta' = Raw Data
                    /// Variable Item type: see the tables below for each possible type
                    self = .descriptor(try Descriptor(dataStream: &dataStream))
                case OSType.list:
                    /// List structure
                    /// Length Description
                    /// 4 Number of items in the list
                    /// The following is repeated for each item in list
                    /// 4 OSType key for type to use. See See Descriptor structure for types.
                    /// Variable See the tables above for each possible type
                    let count: UInt32 = try dataStream.read(endianess: .bigEndian)
                    
                    var values: [Value] = []
                    values.reserveCapacity(Int(count))
                    for _ in 0..<count {
                        guard let elementTypeRaw = try dataStream.readString(count: 4, encoding: .ascii) else {
                            throw PhotoshopReadError.corrupted
                        }
                        guard let elementType = OSType(rawValue: elementTypeRaw) else {
                            throw PhotoshopReadError.corrupted
                        }
                        
                        values.append(try Value(dataStream: &dataStream, type: elementType))
                    }
                    
                    self = .list(values)
                case OSType.double:
                    /// Double structure
                    /// Length Description
                    /// 8 Actual value (double)
                    self = .double(try dataStream.readDouble(endianess: .bigEndian))
                case OSType.unitFloat:
                    /// Unit float structure
                    /// Length Description
                    /// 4 Units the following value is in. One of the following:
                    /// '#Ang' = angle: base degrees
                    /// '#Rsl' = density: base per inch
                    /// '#Rlt' = distance: base 72ppi
                    /// '#Nne' = none: coerced.
                    /// '#Prc'= percent: unit value
                    /// '#Pxl' = pixels: tagged unit value
                    /// 8 Actual value (double)
                    self = .unitFloat(try UnitFloat(dataStream: &dataStream))
                case OSType.string:
                    /// String structure
                    /// Length Description
                    /// Variable String value as Unicode string
                    self = .string(try dataStream.readUnicodeString())
                case OSType.enumerated:
                    /// Enumerated descriptor
                    /// Length Description
                    /// Variable Type: 4 bytes (length), followed either by string or (if length is zero) 4-byte typeID
                    /// Variable Enum: 4 bytes (length), followed either by string or (if length is zero) 4-byte enum
                    self = .enumerated(try EnumeratedDescriptor(dataStream: &dataStream))
                case OSType.integer:
                    self = .integer(try dataStream.read(endianess: .bigEndian))
                case OSType.boolean:
                    /// Boolean structure
                    /// Length Description
                    /// 1 Boolean value
                    self = .boolean(try dataStream.read() as UInt8 != 0)
                case .reference:
                    /// Reference Structure
                    /// Length Description
                    /// 4 Number of items
                    /// The following is repeated for each item in reference
                    /// 4 OSType key for type to use:
                    /// 'prop' = Property
                    /// 'Clss' = Class
                    /// 'Enmr' = Enumerated Reference
                    /// 'rele' = Offset
                    /// 'Idnt' = Identifier
                    /// 'indx' = Index
                    /// 'name' =Name
                    /// Variable
                    /// Item type: see the tables below for each possible Reference type
                    guard dataStream.remainingCount >= 4 else {
                        throw PhotoshopReadError.corrupted
                    }
                    
                    let count: UInt32 = try dataStream.read(endianess: .bigEndian)
                    
                    var items: [ReferenceItem] = []
                    items.reserveCapacity(Int(count))
                    for _ in 0..<count {
                        items.append(try ReferenceItem(dataStream: &dataStream))
                    }
                    
                    self = .reference(items)
                case .largeInteger:
                    /// Large Integer
                    /// Length Description
                    /// 8 Value
                    self = .largeInteger(try dataStream.read(endianess: .bigEndian))
                case .globalObject:
                    /// Descriptor structure
                    /// Length Description
                    /// Variable Unicode string: name from classID
                    /// Variable classID: 4 bytes (length), followed either by string or (if length is zero) 4-byte classID
                    /// 4 Number of items in descriptor
                    /// The following is repeated for each item in descriptor
                    /// Variable Key: 4 bytes ( length) followed either by string or (if length is zero) 4-byte key
                    /// 4 Type: OSType key
                    /// 'obj ' = Reference
                    /// 'Objc' = Descriptor
                    /// 'VlLs' = List
                    /// 'doub' = Double
                    /// 'UntF' = Unit float
                    /// 'TEXT' = String
                    /// 'enum' = Enumerated
                    /// 'long' = Integer
                    /// 'comp' = Large Integer
                    /// 'bool' = Boolean
                    /// 'GlbO' = GlobalObject same as Descriptor
                    /// 'type' = Class
                    /// 'GlbC' = Class
                    /// 'alis' = Alias
                    /// 'tdta' = Raw Data
                    /// Variable Item type: see the tables below for each possible type
                    self = .globalObject(try Descriptor(dataStream: &dataStream))
                case .type:
                    /// Class structure
                    /// Length Description
                    /// Variable Unicode string: name from classID
                    /// Variable ClassID: 4 bytes (length), followed either by string or (if length is zero) 4-byte classID
                    self = .type(try Class(dataStream: &dataStream))
                case .glibc:
                    /// Class structure
                    /// Length Description
                    /// Variable Unicode string: name from classID
                    /// Variable ClassID: 4 bytes (length), followed either by string or (if length is zero) 4-byte classID
                    self = .glibc(try Class(dataStream: &dataStream))
                case .alias:
                    /// Alias structure
                    /// Length Description
                    /// 4 Length of data to follow
                    /// Variable FSSpec for Macintosh or a handle to a string to the full path on Windows
                    let length: UInt32 = try dataStream.read(endianess: .bigEndian)
                    guard length <= dataStream.remainingCount else {
                        throw PhotoshopReadError.corrupted
                    }
                    
                    self = .alias(try dataStream.readBytes(count: Int(length)))
                case .rawData:
                    /// Raw Data
                    /// Length Description
                    /// Variable Value
                    let count: UInt32 = try dataStream.read(endianess: .bigEndian)
                    guard count <= dataStream.remainingCount else {
                        throw PhotoshopReadError.corrupted
                    }
                    
                    self = .rawData(try dataStream.readBytes(count: Int(count)))
                case .objectArray:
                    self = .objectArray(try ObjectArray(dataStream: &dataStream))
                case .unitFloats:
                    self = .unitFloats(try UnitFloats(dataStream: &dataStream))
                }
            }
        }
        
        /// Unit float structure
        public struct UnitFloat {
            public let units: Units
            public let value: Double
            
            public init(dataStream: inout DataStream) throws {
                /// 4 Units the following value is in. One of the following:
                /// '#Ang' = angle: base degrees
                /// '#Rsl' = density: base per inch
                /// '#Rlt' = distance: base 72ppi
                /// '#Nne' = none: coerced.
                /// '#Prc'= percent: unit value
                /// '#Pxl' = pixels: tagged unit value
                guard let unitsRaw = try dataStream.readString(count: 4, encoding: .ascii) else {
                    throw PhotoshopReadError.corrupted
                }
                if unitsRaw != "\0\0\0\0" {
                    guard let units = Units(rawValue: unitsRaw) else {
                        throw PhotoshopReadError.corrupted
                    }
                    
                    self.units = units
                } else {
                    self.units = .none
                }
                
                /// 8 Actual value (double)
                self.value = try dataStream.readDouble(endianess: .bigEndian)
            }
        }
        
        /// 4 Units the following value is in. One of the following:
        /// '#Ang' = angle: base degrees
        /// '#Rsl' = density: base per inch
        /// '#Rlt' = distance: base 72ppi
        /// '#Nne' = none: coerced.
        /// '#Prc'= percent: unit value
        /// '#Pxl' = pixels: tagged unit value
        public enum Units: String {
            case angle = "#Ang"
            case density = "#Rsl"
            case distance = "#Rlt"
            case none = "#Nne"
            case percent = "#Prc"
            case pixels = "#Pxl"
            case millimeters = "#Mlm"
            case points = "#Pnt"
        }
        
        /// The following is repeated for each item in reference
        public enum ReferenceItem {
            case property(_: Property)
            case `class`(_: Class)
            case enumeratedReference(_: EnumeratedReference)
            case offset(_: Offset)
            case identifier(_: Identifier)
            case index(_: Index)
            case name(_: Name)
            
            public init(dataStream: inout DataStream) throws {
                /// 4 OSType key for type to use:
                /// 'prop' = Property
                /// 'Clss' = Class
                /// 'Enmr' = Enumerated Reference
                /// 'rele' = Offset
                /// 'Idnt' = Identifier
                /// 'indx' = Index
                /// 'name' =Name
                guard let typeRaw = try dataStream.readString(count: 4, encoding: .ascii) else {
                    throw PhotoshopReadError.corrupted
                }
                guard let type = ReferenceItemOSType(rawValue: typeRaw) else {
                    throw PhotoshopReadError.corrupted
                }
                
                /// Variable Item type: see the tables below for each possible Reference type
                switch type {
                case .property:
                    /// Property Structure
                    /// Length Description
                    /// Variable Unicode string: name from classID
                    /// Variable classID: 4 bytes (length), followed either by string or (if length is zero) 4-byte classID
                    /// Variable KeyID: 4 bytes (length), followed either by string or (if length is zero) 4-byte keyID
                    self = .property(try Property(dataStream: &dataStream))
                case .class:
                    /// Class structure
                    /// Length Description
                    /// Variable Unicode string: name from classID
                    /// Variable ClassID: 4 bytes (length), followed either by string or (if length is zero) 4-byte classID
                    self = .class(try Class(dataStream: &dataStream))
                case .enumeratedReference:
                    /// Enumerated reference
                    /// Length Description
                    /// Variable Unicode string: name from ClassID.
                    /// Variable ClassID: 4 bytes (length), followed either by string or (if length is zero) 4-byte classID
                    /// Variable TypeID: 4 bytes (length), followed either by string or (if length is zero) 4-byte typeID
                    /// Variable enum: 4 bytes (length), followed either by string or (if length is zero) 4-byte enum
                    self = .enumeratedReference(try EnumeratedReference(dataStream: &dataStream))
                case .offset:
                    /// Offset structure
                    /// Length Description
                    /// Variable Unicode string: name from ClassID
                    /// Variable ClassID: 4 bytes (length), followed either by string or (if length is zero) 4-byte classID
                    /// 4 Value of the offset
                    self = .offset(try Offset(dataStream: &dataStream))
                case .identifier:
                    self = .identifier(try Identifier(dataStream: &dataStream))
                case .index:
                    self = .index(try Index(dataStream: &dataStream))
                case .name:
                    self = .name(try Name(dataStream: &dataStream))
                }
            }
            
            /// 4 OSType key for type to use:
            /// 'prop' = Property
            /// 'Clss' = Class
            /// 'Enmr' = Enumerated Reference
            /// 'rele' = Offset
            /// 'Idnt' = Identifier
            /// 'indx' = Index
            /// 'name' = Name
            public enum ReferenceItemOSType: String {
                case property = "prop"
                case `class` = "clss"
                case enumeratedReference = "Enmr"
                case offset = "rele"
                case identifier = "Idnt"
                case index = "indx"
                case name = "name"
            }
        }
        
        /// Property Structure
        public struct Property {
            public let name: String
            public let classID: Key
            public let keyID: Key
            
            public init(dataStream: inout DataStream) throws {
                /// Variable Unicode string: name from classID
                self.name = try dataStream.readUnicodeString()
                
                /// Variable classID: 4 bytes (length), followed either by string or (if length is zero) 4-byte classID
                self.classID = try dataStream.readKey()
                
                /// Variable KeyID: 4 bytes (length), followed either by string or (if length is zero) 4-byte keyID
                self.keyID = try dataStream.readKey()
            }
        }
        
        /// Enumerated reference
        public struct EnumeratedReference {
            public let name: String
            public let classID: Key
            public let typeID: Key
            public let enumID: Key
            
            public init(dataStream: inout DataStream) throws {
                /// Variable Unicode string: name from ClassID.
                self.name = try dataStream.readUnicodeString()
                
                /// Variable ClassID: 4 bytes (length), followed either by string or (if length is zero) 4-byte classID
                self.classID = try dataStream.readKey()
                
                /// Variable TypeID: 4 bytes (length), followed either by string or (if length is zero) 4-byte typeID
                self.typeID = try dataStream.readKey()
                
                /// Variable enum: 4 bytes (length), followed either by string or (if length is zero) 4-byte enum
                self.enumID = try dataStream.readKey()
            }
        }
        
        /// Offset structure
        public struct Offset {
            public let name: String
            public let classID: Key
            public let value: UInt32
            
            public init(dataStream: inout DataStream) throws {
                /// Variable Unicode string: name from ClassID
                self.name = try dataStream.readUnicodeString()
                
                /// Variable ClassID: 4 bytes (length), followed either by string or (if length is zero) 4-byte classID
                self.classID = try dataStream.readKey()
                
                /// 4 Value of the offset
                self.value = try dataStream.read(endianess: .bigEndian)
            }
        }

        public struct Identifier {
            public let name: String
            public let classID: Key
            public let value: UInt32
            
            public init(dataStream: inout DataStream) throws {
                /// Variable Unicode string: name from ClassID
                self.name = try dataStream.readUnicodeString()
                
                /// Variable ClassID: 4 bytes (length), followed either by string or (if length is zero) 4-byte classID
                self.classID = try dataStream.readKey()
                
                /// 4 Value of the identifier
                self.value = try dataStream.read(endianess: .bigEndian)
            }
        }
        
        public struct Index {
            public let name: String
            public let classID: Key
            public let value: UInt32
            
            public init(dataStream: inout DataStream) throws {
                /// Variable Unicode string: name from ClassID
                self.name = try dataStream.readUnicodeString()
                
                /// Variable ClassID: 4 bytes (length), followed either by string or (if length is zero) 4-byte classID
                self.classID = try dataStream.readKey()
                
                /// 4 Value of the index
                self.value = try dataStream.read(endianess: .bigEndian)
            }
        }
        
        public struct Name {
            public let name: String
            public let classID: Key
            public let value: String
            
            public init(dataStream: inout DataStream) throws {
                /// Variable Unicode string: name from ClassID
                self.name = try dataStream.readUnicodeString()
                
                /// Variable ClassID: 4 bytes (length), followed either by string or (if length is zero) 4-byte classID
                self.classID = try dataStream.readKey()
                
                /// Variable Name unicode string
                self.value = try dataStream.readUnicodeString()
            }
        }
        
        /// Enumerated descriptor
        public struct EnumeratedDescriptor {
            public let typeID: Key
            public let enumValue: Key
            
            public init(dataStream: inout DataStream) throws {
                /// Variable Type: 4 bytes (length), followed either by string or (if length is zero) 4-byte typeID
                self.typeID = try dataStream.readKey()

                /// Variable Enum: 4 bytes (length), followed either by string or (if length is zero) 4-byte enum
                self.enumValue = try dataStream.readKey()
            }
        }
        
        /// Class structure
        public struct Class {
            public let name: String
            public let classID: Key
            
            public init(dataStream: inout DataStream) throws {
                /// Variable Unicode string: name from classID
                self.name = try dataStream.readUnicodeString()
                
                /// Variable ClassID: 4 bytes (length), followed either by string or (if length is zero) 4-byte classID
                self.classID = try dataStream.readKey()
            }
        }
        
        public struct ObjectArray {
            public let version: UInt32
            public let name: String
            public let classID: Key
            public let values: [Item]
            
            public init(dataStream: inout DataStream) throws {
                self.version = try dataStream.read(endianess: .bigEndian)
                guard self.version == 16 else {
                    throw PhotoshopReadError.corrupted
                }
                
                self.name = try dataStream.readUnicodeString()
                
                self.classID = try dataStream.readKey()
                
                let count: UInt32 = try dataStream.read(endianess: .bigEndian)
                
                var items: [Item] = []
                items.reserveCapacity(Int(count))
                for _ in 0..<count {
                    items.append(try Item(dataStream: &dataStream))
                }
                
                self.values = items
            }
        }
        
        public struct UnitFloats {
            public let units: Units
            public let values: [Double]
            
            public init(dataStream: inout DataStream) throws {
                guard let unitsRaw = try dataStream.readString(count: 4, encoding: .ascii) else {
                    throw PhotoshopReadError.corrupted
                }
                guard let units = Units(rawValue: unitsRaw) else {
                    throw PhotoshopReadError.corrupted
                }
                
                self.units = units
                
                let count: UInt32 = try dataStream.read(endianess: .bigEndian)
                
                var values: [Double] = []
                values.reserveCapacity(Int(count))
                for _ in 0..<count {
                    values.append(try dataStream.readDouble(endianess: .bigEndian))
                }
                
                self.values = values
            }
        }
    }
}
