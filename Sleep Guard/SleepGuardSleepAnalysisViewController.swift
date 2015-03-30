//
//  SleepGuardSleepAnalysisViewController.swift
//  Sleep Guard
//
//  Created by Tobias Wermuth on 19/11/14.
//  Copyright (c) 2014 tobynextdoor. All rights reserved.
//

import UIKit

class SleepGuardSleepAnalysisViewController: UIViewController {
    
    var device: MBLMetaWear!

    var deltaAccValues: [(timestamp: NSDate, value: Float)] = []
    var analysisValues: [(timestamp: NSDate, value: Float)] = []
    
    let analysisSize = 6 * 60 * 5
    
    @IBOutlet weak var lineGraphView: BEMSimpleLineGraphView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        UIDevice.currentDevice().proximityMonitoringEnabled = false
        
        initInterface()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        for var i = 0; i < deltaAccValues.count; i++ {
            if deltaAccValues.count > i + analysisSize {
                var temp: Float = 0
                
                for var j = i; j < i + analysisSize; j++ {
                    if deltaAccValues[j].value > 0.1 {
                        temp++
                    }
                }
                
                let analysisValue = (
                    timestamp: deltaAccValues[i].timestamp,
                    value: temp)
                analysisValues.append(analysisValue)
                
                i += analysisSize
            }
        }
        
        lineGraphView.reloadGraph()
    }
    
    func initInterface() {
        lineGraphView.enableBezierCurve = true
        lineGraphView.colorTop = SleepGuard().appColor()
        lineGraphView.colorBottom = UIColor.whiteColor()
        lineGraphView.backgroundColor = SleepGuard().appColor()
        lineGraphView.colorXaxisLabel = SleepGuard().appColor()
        lineGraphView.colorYaxisLabel = UIColor.whiteColor()
        lineGraphView.enableYAxisLabel = true
        lineGraphView.autoScaleYAxis = true
        lineGraphView.enableReferenceYAxisLines = true
        
        lineGraphView.animationGraphStyle = BEMLineAnimation.Fade
    }
    
    func numberOfPointsInLineGraph(graph: BEMSimpleLineGraphView) -> NSInteger {
        return analysisValues.count
    }
    
    func lineGraph(graph: BEMSimpleLineGraphView, valueForPointAtIndex index: NSInteger) -> CGFloat {
        return CGFloat(analysisValues[index].value)
    }
    
    func numberOfGapsBetweenLabelsOnLineGraph(graph: BEMSimpleLineGraphView) -> NSInteger {
        return 4
    }
    
    func lineGraph(graph: BEMSimpleLineGraphView, labelOnXAxisForIndex index: NSInteger) -> NSString {
        let dateFormatter: NSDateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        
        return dateFormatter.stringFromDate(analysisValues[index].timestamp)
    }
    
    var alarm = false
    let alarmIncreaseTime = 10.0
    var alarmLevel: Float = 0;
    
    func startAlarm() {
        alarm = true
        increaseAlarmStrength()
        buzz()
    }
    
    @IBAction func stopAlarm() {
        alarm = false
        alarmLevel = 0
        
        device.led.setLEDOn(false, withOptions: 0)
    }
    
    func increaseAlarmStrength() {
        if alarm && device != nil {
            device.led.flashLEDColor(UIColor.whiteColor(), withIntensity: CGFloat(alarmLevel + 0.09))
            
            alarmLevel += 0.1
            
            println(alarmLevel)
            
            if alarmLevel < 1.0 {
                NSTimer.scheduledTimerWithTimeInterval(
                    alarmIncreaseTime,
                    target: self,
                    selector: "increaseAlarmStrength",
                    userInfo: nil,
                    repeats: false)
            }
        }
    }
    
    func buzz() {
        if alarm && device != nil {
            /*device.hapticBuzzer.startHapticWithDutyCycle(UInt8(alarmLevel * 230), pulseWidth: UInt16(400), completion: {() -> Void in
                var timer = NSTimer.scheduledTimerWithTimeInterval(
                    100,
                    target: self,
                    selector: "buzz",
                    userInfo: nil,
                    repeats: false)
                timer.fire()
            })*/
        }
    }
}
