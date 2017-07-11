//
//  SettingsViewController.swift
//  TaxiClient
//
//  Created by Igor on 28.06.17.
//  Copyright © 2017 Igor. All rights reserved.
//

import UIKit

class SettingsViewController: UITableViewController {
    @IBOutlet weak var lblPhoneNumber: UILabel!
    
    @IBOutlet weak var lblEmail: UILabel!

    @IBOutlet weak var tipsTableViewCell: UIView!
    @IBOutlet weak var lblTips: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
            
        //self.navigationController?.navigationBar.backIndicatorImage = UIImage(named: "close.png")
        //self.navigationController?.navigationBar.backIndicatorTransitionMaskImage = UIImage(named: "close")
        //self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: UIBarButtonItemStyle.plain, target: nil, action: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated);
        
        let defaults = UserDefaults.standard
        let tips: Int = defaults.integer(forKey: "userTipsDefaults");
        
        //if (tips==0) { tipsTableViewCell.frame.size.height = 0}
        //else  {
        lblTips.text = String(tips) + " %";
        
        let email: String = defaults.string(forKey: "userEmailDefaults") ?? "";
        lblEmail.text = email;
        
        let phoneNumber: String? = defaults.string(forKey: "userConfirmedPhone");
        lblPhoneNumber.text = phoneNumber;
        
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
