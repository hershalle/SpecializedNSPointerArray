//
//  SpecializedNSPointerArray.swift
//
//  Created by Shai Balassiano on 19/03/2023.
//  Copyright © 2023 Shai Balassiano. All rights reserved.

import Foundation

public class SpecializedNSPointerArray<T: AnyObject> {
    public static func weakObjects() -> SpecializedNSPointerArray<T> {
        .init(pointerArray: .weakObjects())
    }
    
    public static func strongObjects() -> SpecializedNSPointerArray<T> {
        .init(pointerArray: .strongObjects())
    }
    
    let pointerArray: NSPointerArray
    
    private init(pointerArray: NSPointerArray) {
        self.pointerArray = pointerArray
    }
    
    public var count: Int {
        pointerArray.removeNils()
        return pointerArray.count
    }
    
    public var last: T? {
        pointerArray.last as? T
    }

    public func append(_ object: T?) {
        pointerArray.append(object)
    }
    
    public func insertObject(_ object: T?, at index: Int) {
        pointerArray.insertObject(object, at: index)
    }
    
    public func replaceObject(at index: Int, withObject object: T?) {
        pointerArray.replaceObject(at: index, withObject: object)
    }
    
    public func object(at index: Int) -> T? {
        pointerArray.object(at: index) as? T
    }
    
    public func removeObject(at index: Int) {
        pointerArray.removePointer(at: index)
    }
}

extension SpecializedNSPointerArray where T: Equatable {
    public func removeObject(object: T) {
        for i in 0 ..< count {
            if self.object(at: i) == object {
                removeObject(at: i)
            }
        }
    }
}

extension NSPointerArray {
    func removeNils() {
        guard count > 0 else {
            return
        }
        
        for i in (0 ..< count).reversed() {
            if object(at: i) == nil {
                removeObject(at: i)
            }
        }
    }
    
    func append(_ object: AnyObject?) {
        insertObject(object, at: count)
    }
    
    var last: AnyObject? {
        removeNils()
        guard count > 0 else {
            return nil
        }
        
        let lastIndex = max(0, count - 1)
        return object(at: lastIndex)
    }
    
    func insertObject(_ object: AnyObject?, at index: Int) {
        guard let object = object else { return }
        
        let pointer = Unmanaged.passUnretained(object).toOpaque()
        
        insertPointer(pointer, at: index)
        
        removeNils()
    }
    
    func replaceObject(at index: Int, withObject object: AnyObject?) {
        guard let object = object else { return }
        
        let pointer = Unmanaged.passUnretained(object).toOpaque()
        replacePointer(at: index, withPointer: pointer)
    }
    
    func object(at index: Int) -> AnyObject? {
        guard index < count, let pointer = pointer(at: index) else { return nil }
        return Unmanaged<AnyObject>.fromOpaque(pointer).takeUnretainedValue()
    }
    
    func removeObject(at index: Int) {
        removePointer(at: index)
    }
}

