//
//  MailViewController.swift
//  TaxiClient
//
//  Created by Igor on 10.07.17.
//  Copyright © 2017 Igor. All rights reserved.
//

import UIKit

class MailViewController: UIViewController {

    @IBOutlet weak var txtEMail: UITextField!
    @IBOutlet weak var lblEmail: UILabel!
    
    let defaults = UserDefaults.standard
    
    @IBAction func btnReady_Clicked(_ sender: Any)
    {
        defaults.set(txtEMail.text, forKey: "userEmailDefaults")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let email: String? = defaults.string(forKey: "userEmailDefaults");
        if (lblEmail != nil) {lblEmail.text = email}

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
