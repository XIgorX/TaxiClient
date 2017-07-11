//
//  TipsViewController.swift
//  TaxiClient
//
//  Created by Igor on 07.07.17.
//  Copyright © 2017 Igor. All rights reserved.
//

import UIKit

class TipsViewController: UIViewController {
    
    @IBOutlet weak var switch0: UISwitch!
    @IBOutlet weak var switch5: UISwitch!
    @IBOutlet weak var switch10: UISwitch!
    @IBOutlet weak var switch15: UISwitch!
    
    let defaults = UserDefaults.standard
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tips: Int = defaults.integer(forKey: "userTipsDefaults");
        switch tips {
        case 0: switch0.setOn(true, animated: false)
        case 5: switch5.setOn(true, animated: false)
        case 10: switch10.setOn(true, animated: false)
        case 15: switch15.setOn(true, animated: false)
        default: break
        }
    }
    
    @IBAction func switch0Clicked(_ sender: Any)
    {
        switch0.setOn(true, animated: true)
        switch5.setOn(false, animated: true)
        switch10.setOn(false, animated: true)
        switch15.setOn(false, animated: true)
        
        defaults.set(0, forKey: "userTipsDefaults")
    }
    
    @IBAction func switch5Clicked(_ sender: Any)
    {

        switch0.setOn(false, animated: true)
        switch5.setOn(true, animated: true)
        switch10.setOn(false, animated: true)
        switch15.setOn(false, animated: true)

        defaults.set(5, forKey: "userTipsDefaults")
    }
    
    @IBAction func btn10Clicked(_ sender: Any)
    {
        switch0.setOn(false, animated: true)
        switch5.setOn(false, animated: true)
        switch10.setOn(true, animated: true)
        switch15.setOn(false, animated: true)
        
        defaults.set(10, forKey: "userTipsDefaults")
    }
    
    
    @IBAction func btn15Clicked(_ sender: Any)
    {
        switch0.setOn(false, animated: true)
        switch5.setOn(false, animated: true)
        switch10.setOn(false, animated: true)
        switch15.setOn(true, animated: true)
        
        defaults.set(15, forKey: "userTipsDefaults")
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

}
