//
//  GameSettingsViewController.swift
//  CoreDataLab
//
//  Created by Oscar on 9/29/17.
//  Copyright © 2017 Luke Hansen. All rights reserved.
//

import UIKit

class GameSettingsViewController: UIViewController {
    let defaults = UserDefaults.standard
    @IBOutlet weak var segControl: UISegmentedControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let cs = Int(self.defaults.string(forKey: "CurrSteps")!)
        let pg = Int(self.defaults.string(forKey: "PersistentGoal")!)
        
        if(cs!>=pg!*1){
            segControl.setEnabled(true, forSegmentAt: 0)
        }
        if(cs!>=pg!*2){
            segControl.setEnabled(true, forSegmentAt: 1)
        }
        if(cs!>=pg!*3){
            segControl.setEnabled(true, forSegmentAt: 2)
        }
        defaults.setValue(segControl.titleForSegment(at:segControl.selectedSegmentIndex), forKeyPath: "Color")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func colorChanged(_ sender: UISegmentedControl) {
        defaults.setValue(sender.titleForSegment(at:sender.selectedSegmentIndex), forKeyPath: "Color")
    }

}
