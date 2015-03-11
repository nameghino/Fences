//
//  FencesListInterfaceController.swift
//  Fences
//
//  Created by Nicolas Ameghino on 3/11/15.
//  Copyright (c) 2015 Nicolas Ameghino. All rights reserved.
//

import WatchKit
import Foundation

let FenceMapDetailSegueIdentifier = "FenceMapDetailSegue"

class FencesListInterfaceController: WKInterfaceController {

    let watchFenceStore = GetFenceStore()
    @IBOutlet weak var fencesTable: WKInterfaceTable!
    
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
    }

    override func willActivate() {
        NSLog("activating this thing")

        fencesTable.setNumberOfRows(watchFenceStore.allItems.count, withRowType: "FencesListRowController")
        
        for (index, fence) in enumerate(watchFenceStore.allItems) {
            let controller = fencesTable.rowControllerAtIndex(index) as! FencesListRowController
            controller.setFence(fence)
        }
        
        super.willActivate()
    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }
    
    override func table(table: WKInterfaceTable, didSelectRowAtIndex rowIndex: Int) {
        NSLog("tapped on row \(rowIndex)")
        let fence = watchFenceStore.allItems[rowIndex]
        self.pushControllerWithName("WKFencesMap", context: fence)
    }
}

class FencesListRowController: NSObject {
    @IBOutlet weak var mapView: WKInterfaceMap!
    @IBOutlet weak var label: WKInterfaceLabel!
    
    func setFence(fence: Fence) {
        label.setText(fence.textDescription)
        let region = MKCoordinateRegionMakeWithDistance(fence.coordinate, 100, 100)
        mapView.setRegion(region)
    }
}