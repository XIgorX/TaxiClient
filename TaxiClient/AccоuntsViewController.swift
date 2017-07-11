//
//  AccauntsViewController.swift
//  TaxiClient
//
//  Created by Igor on 10.07.17.
//  Copyright © 2017 Igor. All rights reserved.
//

import UIKit

let defaults = UserDefaults.standard
let phoneNumberLength = 16
var phoneNumber: String = "                ";

class AccountsViewController: UIViewController {

    @IBOutlet weak var lblPhoneNumber: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()

        phoneNumber = defaults.string(forKey: "userConfirmedPhone") ?? "                ";
        while (phoneNumber.characters.count < phoneNumberLength) { phoneNumber += " "; }
        
        let start = phoneNumber.index(phoneNumber.startIndex, offsetBy: 7);
        let end = phoneNumber.index(phoneNumber.startIndex, offsetBy: 7 + 7);
        
        phoneNumber.replaceSubrange(start..<end, with: " ***-** ")
        
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
