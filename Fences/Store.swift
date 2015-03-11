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
    
    private let operationQueue = NSOperationQueue()
    
    // Add callbacks
    public var willAddBlock: ((T) -> ())?
    public var didAddBlock: ((T) -> ())?
    
    // Remove callbacks
    public var willRemoveBlock: ((T) -> ())?
    public var didRemoveBlock: ((T) -> ())?
    
    private var fileName: String
    private var fileURL: NSURL
    
    var allItems: [T] {
        get {
            return container
        }
    }
    
    convenience init(fileName: String, creator: () -> T) {
        self.init(fileName: fileName, loadFile: true, appGroup: nil, creator: creator)
    }
    
    init(fileName: String, loadFile: Bool, appGroup: String?, creator: () -> T) {
        self.creator = creator
        self.fileName = fileName
        
        let fm = NSFileManager.defaultManager()
        
        
        if let ag = appGroup {
            let appGroupURL = fm.containerURLForSecurityApplicationGroupIdentifier(ag)!
            self.fileURL = appGroupURL.URLByAppendingPathComponent(self.fileName, isDirectory: false)
        } else {
            self.fileURL = NSURL(fileURLWithPath: fileName)!
        }
        
        super.init()
        
        if loadFile {
            if fm.fileExistsAtPath(self.fileURL.path!) {
                if let data = NSData(contentsOfURL: self.fileURL) {
                    let archived = NSKeyedUnarchiver.unarchiveObjectWithFile(self.fileURL.path!) as! [T]
                    self.rebuildIndex(archived)
                }
            }
        }
    }
    
    func rebuildIndex(objects: [T]) {
        operationQueue.addOperationWithBlock() {
            [unowned self] in
            self.index.removeAll(keepCapacity: true)
            self.container.removeAll(keepCapacity: true)
            for o in objects {
                self.index[o.key] = o
                self.container.append(o)
            }
        }
    }
    
    func save(callback: StoreSaveCallback?) {
        operationQueue.addOperationWithBlock() {
            [unowned self] in
            let success = NSKeyedArchiver.archiveRootObject(self.container as! AnyObject, toFile: self.fileURL.path!)
            if let cb = callback {
                cb(success)
            }
        }
    }
    
    func create() -> T {
        let o = creator()
        self.add(o)
        return o
    }
    
    func add(item: T) {
        operationQueue.addOperationWithBlock {
            [unowned self] in
            if let wa = self.willAddBlock {
                wa(item)
            }
            self.container.append(item)
            self.index[item.key] = item
            
            if let da = self.didAddBlock {
                da(item)
            }
        }
    }
    
    func get(index: Int) -> T {
        return container[index]
    }
    
    func get(key: String) -> T? {
        return index[key]
    }
    
    func remove(index: Int, callback:(() -> ())?) {
        
        let operation = NSBlockOperation() {
            [unowned self] in
            let item = self.get(index)
            
            if let wr = self.willRemoveBlock {
                wr(item)
            }
            
            self.container.removeAtIndex(index)
            self.index.removeValueForKey(item.key)
            
            if let dr = self.didRemoveBlock {
                dr(item)
            }
        }
        
        operation.completionBlock = callback
        operationQueue.addOperation(operation)
    }
    
    func remove(key: String, callback:(() -> ())?) {
        if let item = index[key] {
            self.remove(item, callback: callback)
        }
    }
    
    func remove(item: T, callback:(() -> ())?) {
        if let index = find(container, item) {
            self.remove(index, callback: callback)
        }
    }
}
