//
//  AuthorizationViewController.swift
//  TaxiClient
//
//  Created by Igor on 04.07.17.
//  Copyright © 2017 Igor. All rights reserved.
//

import UIKit

class AuthorizationViewController: UIViewController {

    @IBOutlet weak var btnCheckBoxAccept: UIButton!
    @IBOutlet weak var btnNext: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        btnNext.backgroundColor = UIColor.lightGray
        // Do any additional setup after loading the view.
    }

    @IBAction func btnCheckBoxAccept_Clicked(_ sender: Any)
    {
        btnCheckBoxAccept.isSelected = !btnCheckBoxAccept.isSelected;
        btnNext.isEnabled = !btnNext.isEnabled;
        if (btnNext.isEnabled) { btnNext.backgroundColor = UIColor(red: 1.00, green: 200/255, blue: 0, alpha: 1.00)}
        else  { btnNext.backgroundColor = UIColor.lightGray }
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
