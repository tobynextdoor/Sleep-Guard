//
//  SleepViewController.swift
//  Sleep Guard
//
//  Created by Tobias Wermuth on 14/11/14.
//  Copyright (c) 2014 tobynextdoor. All rights reserved.
//

import UIKit

class SleepGuardSleepViewController: UIViewController {
    
    var device: MBLMetaWear!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        UIDevice.currentDevice().proximityMonitoringEnabled = true
    }
}
