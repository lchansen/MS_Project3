//
//  StatsViewController.swift
//  CoreDataLab
//
//  Created by Luke Hansen on 9/27/17.
//  Copyright © 2017 Luke Hansen. All rights reserved.
//

import UIKit
import CoreMotion

class StatsViewController: UIViewController, UITextFieldDelegate {
    let activityManager = CMMotionActivityManager()
    let pedometerYesterday = CMPedometer()
    let pedometer = CMPedometer()
    var goalMet = true
    let defaults = UserDefaults.standard
    
    
    @IBOutlet var currStepsSinceYesterday: UILabel!
    @IBOutlet var currSteps: UILabel!
    @IBOutlet var activityLabel: UILabel!
    @IBOutlet var goalTextField: UITextField!
    @IBOutlet var progressLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.startActivityMonitoring()
        self.startPedometerMonitoring()
        self.goalTextField.delegate = self
        self.goalTextField.keyboardType = .numberPad
        if let pg = self.defaults.string(forKey: "PersistentGoal"){
            self.goalTextField.text = pg
        }
        self.updateGoalStatus()
    }
    
    func updateGoalStatus(){
        if let goal = self.defaults.string(forKey: "PersistentGoal"){
            if let gi = Int(goal){
                let currTextfieldInt: Int? = Int(self.currSteps.text!)
                if let ci = currTextfieldInt{
                    if(gi-ci>0){
                        self.progressLabel.text = String(gi-ci)
                    }
                    else {
                        self.progressLabel.text = "Goal Met"
                    }
                } else {
                    self.progressLabel.text = "No Goal"
                }
            } else {
                self.progressLabel.text = "No Goal"
            }
        } else {
            self.progressLabel.text = "No Goal"
        }
    }

    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?){
        view.endEditing(true)
        defaults.set(self.goalTextField.text, forKey:"PersistentGoal")
        self.updateGoalStatus()
        super.touchesBegan(touches, with: event)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    
    func startActivityMonitoring(){
        // is activity is available
        if CMMotionActivityManager.isActivityAvailable(){
            // update from this queue (should we use the MAIN queue here??.... )
            self.activityManager.startActivityUpdates(to: OperationQueue.main)
            {(activity:CMMotionActivity?)->Void in
                // unwrap the activity and dispaly
                if let unwrappedActivity = activity {
                    print("%@",unwrappedActivity.description)
                    if (unwrappedActivity.stationary){
                        self.activityLabel.text = "Still"
                    } else if (unwrappedActivity.walking){
                        self.activityLabel.text = "Walking"
                    } else if (unwrappedActivity.running){
                        self.activityLabel.text = "Running"
                    } else if (unwrappedActivity.cycling){
                        self.activityLabel.text = "Cycling"
                    } else if (unwrappedActivity.automotive){
                        self.activityLabel.text = "Driving"
                    } else {
                        self.activityLabel.text = "Unknown"
                    }
                    
                }
            }
        }
        
    }
    
    func startPedometerMonitoring(){
        if CMPedometer.isStepCountingAvailable(){
            var yesterday = Calendar.current.date( byAdding: .day, value: -1, to: Date())!
            yesterday = Calendar.current.date(bySettingHour: 0, minute: 0, second: 0, of: yesterday)!
            pedometerYesterday.startUpdates(from: yesterday, withHandler: {(pedData:CMPedometerData?, error:Error?) in
                if pedData != nil {
                    print("\(pedData!.description)")
                    DispatchQueue.main.async() {
                        self.currStepsSinceYesterday.text = (pedData?.numberOfSteps.stringValue)!
                        self.currStepsSinceYesterday.setNeedsDisplay()
                        self.updateGoalStatus()
                        self.goalTextField.setNeedsDisplay()
                    }
                }
            })
            
            let today = Calendar.current.date(bySettingHour: 0, minute: 0, second: 0, of: Date())!
            pedometer.startUpdates(from: today, withHandler: {(pedData:CMPedometerData?, error:Error?) in
                if pedData != nil {
                    print("\(pedData!.description)")
                    DispatchQueue.main.async() {
                        self.currSteps.text = (pedData?.numberOfSteps.stringValue)!
                        self.currSteps.setNeedsDisplay()
                        self.updateGoalStatus()
                        self.goalTextField.setNeedsDisplay()
                    }
                }
            })
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        let aSet = NSCharacterSet(charactersIn:"0123456789").inverted
        let compSepByCharInSet = string.components(separatedBy: aSet)
        let numberFiltered = compSepByCharInSet.joined(separator: "")
        return string == numberFiltered
    }

}
