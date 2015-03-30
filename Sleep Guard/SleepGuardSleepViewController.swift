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
    var wakeTime: NSDate!
    
    var values: [(timestamp: NSDate, data: MBLAccelerometerData)] = []
    var deltaAccValues: [(timestamp: NSDate, value: Float)] = []
    
    let graphMax: Float = 1.0
    let displayedValuesCount: Int = 50
    
    var sleepEnded = false
    
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var wakeTimeLabel: UILabel!
    @IBOutlet weak var lineGraphView: BEMSimpleLineGraphView!
    @IBOutlet weak var batteryLabel: UILabel!
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.destinationViewController.isKindOfClass(SleepGuardSleepAnalysisViewController.classForCoder()) {
            sleepEnded = true
            
            (segue.destinationViewController as SleepGuardSleepAnalysisViewController).deltaAccValues = deltaAccValues
            (segue.destinationViewController as SleepGuardSleepAnalysisViewController).device = device

            if wakeTime.timeIntervalSinceDate(NSDate()) < 60 {
                (segue.destinationViewController as SleepGuardSleepAnalysisViewController).startAlarm()
            }
            
            stopAccelerometer()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        UIDevice.currentDevice().proximityMonitoringEnabled = true
        
        initInterface()
        
        checkBattery()
        NSTimer.scheduledTimerWithTimeInterval(60.0, target: self, selector: "checkBattery", userInfo: nil, repeats: true)
        
        device.led.setLEDOn(false, withOptions: 0)
        
        startAccelerometer()
    }
    
    func initInterface() {
        updateTime()
        
        NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: "updateTime", userInfo: nil, repeats: true)
        
        let dateFormatter: NSDateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        
        wakeTimeLabel.text = dateFormatter.stringFromDate(wakeTime)
        
        lineGraphView.enableBezierCurve = true
        lineGraphView.colorTop = SleepGuard().appColor()
        lineGraphView.colorBottom = UIColor.whiteColor()
        lineGraphView.backgroundColor = SleepGuard().appColor()
        lineGraphView.colorXaxisLabel = SleepGuard().appColor()
        lineGraphView.colorYaxisLabel = UIColor.whiteColor()
        lineGraphView.enableYAxisLabel = true
        lineGraphView.autoScaleYAxis = false
        lineGraphView.enableReferenceYAxisLines = true
        lineGraphView.maximumYAxis = CGFloat(graphMax)
        
        lineGraphView.animationGraphStyle = BEMLineAnimation.None
    }
    
    func updateTime() {
        let dateFormatter: NSDateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        
        timeLabel.text = dateFormatter.stringFromDate(NSDate())
        
        if NSDate().timeIntervalSinceDate(wakeTime) > 0 && NSDate().timeIntervalSinceDate(wakeTime) < 10 {
            if !sleepEnded {self.performSegueWithIdentifier("To Analysis", sender: self)}
        }
    }
    
    func checkBattery() {
        device.readBatteryLifeWithHandler({(number, error) -> Void in
            if error == nil {
                self.batteryLabel.text = String(format: "Battery: %d%%", number as NSInteger)
                
                if (number as NSInteger) < 5 || error != nil {
                    if !self.sleepEnded {self.performSegueWithIdentifier("To Analysis", sender: self)}
                }
            } else {
                self.reconnect()
            }
        })
    }
    
    func numberOfPointsInLineGraph(graph: BEMSimpleLineGraphView) -> NSInteger {
        return displayedValuesCount
    }
    
    func lineGraph(graph: BEMSimpleLineGraphView, valueForPointAtIndex index: NSInteger) -> CGFloat {
        return deltaAccValues.count > displayedValuesCount ?
            CGFloat(deltaAccValues[deltaAccValues.count - displayedValuesCount + index].value / graphMax) * lineGraphView.frame.height :
            index < deltaAccValues.count ?
                CGFloat(deltaAccValues[index].value / graphMax)  * lineGraphView.frame.height :
                0
    }
    
    func numberOfGapsBetweenLabelsOnLineGraph(graph: BEMSimpleLineGraphView) -> NSInteger {
        return 5
    }
    
    func lineGraph(graph: BEMSimpleLineGraphView, labelOnXAxisForIndex index: NSInteger) -> NSString {
        if index < deltaAccValues.count {
            let timestamp: NSDate = deltaAccValues.count > displayedValuesCount ?
                deltaAccValues[deltaAccValues.count - displayedValuesCount + index].timestamp :
                deltaAccValues[index].timestamp
            
            let dateFormatter: NSDateFormatter = NSDateFormatter()
            dateFormatter.dateFormat = "HH:mm:ss"
            
            return dateFormatter.stringFromDate(timestamp)
        }
        
        return ""
    }
    
    func startAccelerometer() {
        device.accelerometer.fullScaleRange = MBLAccelerometerRange2G
        device.accelerometer.sampleFrequency = MBLAccelerometerSampleFrequency6_25Hz
        device.accelerometer.highPassFilter = false
        device.accelerometer.lowNoise = true
        device.accelerometer.autoSleep = true
        device.accelerometer.sleepSampleFrequency = MBLAccelerometerSleepSampleFrequency6_25Hz
        device.accelerometer.activePowerScheme = MBLAccelerometerPowerSchemeLowerPower

        device.accelerometer.dataReadyEvent.startNotificationsWithHandler({(acceleration, error) -> Void in
            if error == nil {
                let data: MBLAccelerometerData = acceleration as MBLAccelerometerData

                if self.values.count > 1 {
                    let deltaAccValue = (
                        timestamp: self.now(),
                        value: fabsf(data.x - self.values[self.values.count - 1].data.x) +
                            fabsf(data.y - self.values[self.values.count - 1].data.y) +
                            fabsf(data.z - self.values[self.values.count - 1].data.z))
                    self.deltaAccValues.append(deltaAccValue)
                    
                    self.lineGraphView.reloadGraph()
                }
                
                let value = (
                    timestamp: self.now(),
                    data: data)
                self.values.append(value)
            } else {
                self.reconnect()
            }
        })
    }
    
    func stopAccelerometer() {
        device.accelerometer.dataReadyEvent.stopNotifications()
    }
    
    func now() -> NSDate {
        return NSDate()
    }
    
    func reconnect() {
        device.connectWithHandler({(error) -> Void in})
    }
}
