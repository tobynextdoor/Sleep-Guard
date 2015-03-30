//
//  MetaWearChooserViewController.swift
//  Sleep Guard
//
//  Created by Tobias Wermuth on 14/11/14.
//  Copyright (c) 2014 tobynextdoor. All rights reserved.
//

import UIKit

class SleepGuardMetaWearSelectionViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    var devices: [MBLMetaWear] = []
    var selectedDevice: MBLMetaWear!
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var connectingView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        startScanning()
        
        tableView.tableFooterView = UIView(frame: CGRectZero)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.destinationViewController .isKindOfClass(SleepGuardTimeSelectionViewController.classForCoder()) {
            (segue.destinationViewController as SleepGuardTimeSelectionViewController).device = selectedDevice
        }
    }
    
    func startScanning() {
        MBLMetaWearManager.sharedManager().startScanForMetaWearsAllowDuplicates(true, {(devices:[AnyObject]!) -> Void in
            self.devices = devices as [MBLMetaWear]
            
            self.tableView.reloadData()
        })
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return devices.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell: UITableViewCell = tableView.dequeueReusableCellWithIdentifier("Device Cell") as UITableViewCell
        let device: MBLMetaWear = devices[indexPath.row]
        
        /*
        var nameLabel: UILabel = cell.viewWithTag(1) as UILabel
        nameLabel.text = device.deviceInfo.manufacturerName
        */
        
        var uuidLabel: UILabel = cell.viewWithTag(2) as UILabel
        uuidLabel.text = device.identifier.UUIDString
        
        var rssiLabel: UILabel = cell.viewWithTag(3) as UILabel
        rssiLabel.text = device.discoveryTimeRSSI.stringValue
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        selectedDevice = devices[indexPath.row]
        
        MBLMetaWearManager.sharedManager().stopScanForMetaWears()
        
        connectingView.hidden = false
        connectingView.alpha = 0

        UIView.animateWithDuration(0.3, animations: {() -> Void in
            self.connectingView.alpha = 1.0
        })
        
        selectedDevice.connectWithHandler({(error) -> Void in
            if error == nil {
                self.selectedDevice.led.setLEDOn(false, withOptions: 0)
                
                self.performSegueWithIdentifier("To Timer Selection", sender: self)
            } else {
                UIView.animateWithDuration(0.3, animations: {() -> Void in
                    self.connectingView.alpha = 0.0
                })
                
                self.startScanning()
            }
        })
    }
}
