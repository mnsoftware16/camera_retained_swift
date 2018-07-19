//
//  MultiArray.swift
//  CameraRetrained
//
//  Created by Marcin on 19.07.2018.
//  Copyright © 2018 Marcin. All rights reserved.
//

import Foundation
import CoreML

public struct MultiArray<T: MultiArrayType> {
    public let array: MLMultiArray
    public let pointer: UnsafeMutablePointer<T>
    
    private(set) public var strides: [Int]
    private(set) public var shape: [Int]
    
    /**
     Creates a new multi-array filled with all zeros.
     */
    public init(shape: [Int]) {
        let m = try! MLMultiArray(shape: shape as [NSNumber], dataType: T.multiArrayDataType)
        self.init(m)
        memset(pointer, 0, MemoryLayout<T>.stride * count)
    }
    
    /**
     Creates a new multi-array initialized with the specified value.
     */
    public init(shape: [Int], initial: T) {
        self.init(shape: shape)
        for i in 0..<count {
            pointer[i] = initial
        }
    }
    
    /**
     Creates a multi-array that wraps an existing MLMultiArray.
     */
    public init(_ array: MLMultiArray) {
        self.init(array, array.shape as! [Int], array.strides as! [Int])
    }
    
    init(_ array: MLMultiArray, _ shape: [Int], _ strides: [Int]) {
        self.array = array
        self.shape = shape
        self.strides = strides
        pointer = UnsafeMutablePointer<T>(OpaquePointer(array.dataPointer))
    }
    
    /**
     Returns the number of elements in the entire array.
     */
    public var count: Int {
        return shape.reduce(1, *)
    }
    
    public subscript(a: Int) -> T {
        get { return pointer[a] }
        set { pointer[a] = newValue }
    }
    
    public subscript(a: Int, b: Int) -> T {
        get { return pointer[a*strides[0] + b*strides[1]] }
        set { pointer[a*strides[0] + b*strides[1]] = newValue }
    }
    
    public subscript(a: Int, b: Int, c: Int) -> T {
        get { return pointer[a*strides[0] + b*strides[1] + c*strides[2]] }
        set { pointer[a*strides[0] + b*strides[1] + c*strides[2]] = newValue }
    }
    
    public subscript(a: Int, b: Int, c: Int, d: Int) -> T {
        get { return pointer[a*strides[0] + b*strides[1] + c*strides[2] + d*strides[3]] }
        set { pointer[a*strides[0] + b*strides[1] + c*strides[2] + d*strides[3]] = newValue }
    }
    
    public subscript(a: Int, b: Int, c: Int, d: Int, e: Int) -> T {
        get { return pointer[a*strides[0] + b*strides[1] + c*strides[2] + d*strides[3] + e*strides[4]] }
        set { pointer[a*strides[0] + b*strides[1] + c*strides[2] + d*strides[3] + e*strides[4]] = newValue }
    }
    
    public subscript(indices: [Int]) -> T {
        get { return pointer[offset(for: indices)] }
        set { pointer[offset(for: indices)] = newValue }
    }
    
    func offset(for indices: [Int]) -> Int {
        var offset = 0
        for i in 0..<indices.count {
            offset += indices[i] * strides[i]
        }
        return offset
    }
    
    /**
     Returns a transposed version of this array. NOTE: The new array still uses
     the same underlying storage (the same MLMultiArray object).
     */
    public func transposed(_ order: [Int]) -> MultiArray {
        precondition(order.count == strides.count)
        var newShape = shape
        var newStrides = strides
        for i in 0..<order.count {
            newShape[i] = shape[order[i]]
            newStrides[i] = strides[order[i]]
        }
        return MultiArray(array, newShape, newStrides)
    }
    
    /**
     Changes the number of dimensions and their sizes.
     */
    public func reshaped(_ dimensions: [Int]) -> MultiArray {
        let newCount = dimensions.reduce(1, *)
        precondition(newCount == count, "Cannot reshape \(shape) to \(dimensions)")
        
        var newStrides = [Int](repeating: 0, count: dimensions.count)
        newStrides[dimensions.count - 1] = 1
        for i in stride(from: dimensions.count - 1, to: 0, by: -1) {
            newStrides[i - 1] = newStrides[i] * dimensions[i]
        }
        
        return MultiArray(array, dimensions, newStrides)
    }
}

extension MultiArray: CustomStringConvertible {
    public var description: String {
        return description([])
    }
    
    func description(_ indices: [Int]) -> String {
        func indent(_ x: Int) -> String {
            return String(repeating: " ", count: x)
        }
        
        // This function is called recursively for every dimension.
        // Add an entry for this dimension to the end of the array.
        var indices = indices + [0]
        
        let d = indices.count - 1          // the current dimension
        let N = shape[d]                   // how many elements in this dimension
        
        var s = "["
        if indices.count < shape.count {   // not last dimension yet?
            for i in 0..<N {
                indices[d] = i
                s += description(indices)      // then call recursively again
                if i != N - 1 {
                    s += ",\n" + indent(d + 1)
                }
            }
        } else {                           // the last dimension has actual data
            s += " "
            for i in 0..<N {
                indices[d] = i
                s += "\(self[indices])"
                if i != N - 1 {                // not last element?
                    s += ", "
                    if i % 11 == 10 {            // wrap long lines
                        s += "\n " + indent(d + 1)
                    }
                }
            }
            s += " "
        }
        return s + "]"
    }
}
