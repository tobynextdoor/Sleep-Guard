//
//  TimeChooserViewController.swift
//  Sleep Guard
//
//  Created by Tobias Wermuth on 14/11/14.
//  Copyright (c) 2014 tobynextdoor. All rights reserved.
//

import UIKit

class SleepGuardTimeSelectionViewController: UIViewController {
    
    var device: MBLMetaWear!
    
    @IBOutlet weak var datePicker: UIDatePicker!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.destinationViewController .isKindOfClass(SleepGuardSleepViewController.classForCoder()) {
            (segue.destinationViewController as SleepGuardSleepViewController).device = device
            (segue.destinationViewController as SleepGuardSleepViewController).wakeTime = datePicker.date
        }
    }
}
