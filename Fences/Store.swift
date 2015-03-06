//
//  Store.swift
//  Fences
//
//  Created by Nicolas Ameghino on 3/4/15.
//  Copyright (c) 2015 Nicolas Ameghino. All rights reserved.
//

import UIKit
import Swift

public protocol Storeable {
    var key: String { get }
}

func filePathInLibraryDirectory(filePath: String) -> String {
    let libraryPath = NSSearchPathForDirectoriesInDomains(.LibraryDirectory,.UserDomainMask,true)[0] as! String
    return libraryPath.stringByAppendingPathComponent(filePath)
}

func filePathInDocumentsDirectory(filePath: String) -> String {
    let documentsPath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory,.UserDomainMask,true)[0] as! String
    return documentsPath.stringByAppendingPathComponent(filePath)
}

typealias StoreSaveCallback = (Bool) -> (Void)

public class Store<T where T: Equatable, T: Storeable>: NSObject {
    private var container: [T] = []
    private var index: [String: T] = [:]
    private var creator: () -> T
    
    // Add callbacks
    public var willAddBlock: ((T) -> ())?
    public var didAddBlock: ((T) -> ())?

    // Remove callbacks
    public var willRemoveBlock: ((T) -> ())?
    public var didRemoveBlock: ((T) -> ())?
    
    private var filePath: String
    
    private let lock = NSLock()
    
    var allItems: [T] {
        get {
            return container
        }
    }
    
    convenience init(filePath: String, creator: () -> T) {
        self.init(filePath: filePath, loadFile: true, creator: creator)
    }
    
    init(filePath: String, loadFile: Bool, creator: () -> T) {
        self.creator = creator
        self.filePath = filePath
        
        super.init()
        if loadFile {
            let fm = NSFileManager.defaultManager()
            if fm.fileExistsAtPath(self.filePath) {
                self.rebuildIndex(NSKeyedUnarchiver.unarchiveObjectWithFile(self.filePath) as! [T])
            }
        }
    }
    
    func rebuildIndex(objects: [T]) {
        lock.lock()
        index.removeAll(keepCapacity: true)
        for o in objects {
            index[o.key] = o
            container.append(o)
        }
        lock.unlock()
    }
    
    func save(callback: StoreSaveCallback?) {
        lock.lock()
        let success = NSKeyedArchiver.archiveRootObject(self.container as! AnyObject, toFile: self.filePath)
        if let cb = callback {
            cb(success)
        }
        lock.unlock()
    }
    
    func create() -> T {
        let o = creator()
        self.add(o)
        return o
    }
    
    func add(item: T) {
        lock.lock()
        if let wa = willAddBlock {
            wa(item)
        }
        container.append(item)
        index[item.key] = item
        
        if let da = didAddBlock {
            da(item)
        }
        
        lock.unlock()
    }
    
    func get(index: Int) -> T {
        return container[index]
    }
    
    func get(key: String) -> T? {
        return index[key]
    }
    
    func remove(index: Int) {
        lock.lock()
        let item = self.get(index)
        
        if let wr = willRemoveBlock {
            wr(item)
        }
        
        self.container.removeAtIndex(index)
        self.index.removeValueForKey(item.key)
        
        if let dr = didRemoveBlock {
            dr(item)
        }
        lock.unlock()
    }
    
    func remove(key: String) {
        if let item = index[key] {
            self.remove(item)
        }
    }
    
    func remove(item: T) {
        if let index = find(container, item) {
            self.remove(index)
        }
    }
    
    
}
