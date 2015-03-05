//
//  Store.swift
//  Fences
//
//  Created by Nicolas Ameghino on 3/4/15.
//  Copyright (c) 2015 Nicolas Ameghino. All rights reserved.
//

import UIKit
import Swift

class Store<T: Equatable>: NSObject {
    private var container: [T] = []
    private var creator: () -> T
    
    var allItems: [T] {
        get {
            return container
        }
    }
    
    init(creator: () -> T) {
        self.creator = creator
    }
    
    func create() -> T {
        let o = creator()
        self.add(o)
        return o
    }
    
    func add(item: T) {
        container.append(item)
    }
    
    func get(index: Int) -> T {
        return container[index]
    }
    
    func remove(index: Int) {
        container.removeAtIndex(index)
    }
    
    func remove(item: T) {
        if let index = find(container, item) {
            self.remove(index)
        }
    }
    
    
}
