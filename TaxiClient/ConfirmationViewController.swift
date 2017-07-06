//
//  ConfirmationViewController.swift
//  TaxiClient
//
//  Created by Igor on 06.07.17.
//  Copyright © 2017 Igor. All rights reserved.
//

import UIKit

class ConfirmationViewController: UIViewController {

    @IBOutlet weak var btnReady: UIButton!
    @IBOutlet weak var txtCode: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        btnReady.backgroundColor = UIColor.lightGray
    }

    @IBAction func code_Changed(_ sender: Any)
    {
        if (txtCode.text == "") { btnReady.backgroundColor = UIColor.lightGray }
        else { btnReady.backgroundColor = UIColor(red: 1.00, green: 200/255, blue: 0, alpha: 1.00) }
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
