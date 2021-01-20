//
//  DimensionUnit.swift
//  
//
//  Created by Hugh Bellamy on 18/01/2021.
//

public enum DimensionUnit: UInt16, DataStreamCreatable {
    case inches = 1
    case cm = 2
    case points = 3
    case picas = 4
    case columns = 5
}
