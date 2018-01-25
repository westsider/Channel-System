//
//  LoginViewController.swift
//  Channel System
//
//  Created by Warren Hansen on 1/25/18.
//  Copyright © 2018 Warren Hansen. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {

    @IBOutlet weak var siChart: UITextField!
    
    @IBOutlet weak var intrinioUser: UITextField!
    
    @IBOutlet weak var intrinioPass: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBAction func loginAction(_ sender: Any) {
        saveLogins()
    }
    
    func saveLogins() {
        if  let myUser = intrinioUser.text  {
            if myUser.count < 8 {
                intrinioUser.text = "more characters required"
                return
            }
            UserDefaults.standard.set(myUser, forKey: "user")
        } else {
            print("No User Set")
        }
        
        if  let myPassWord = intrinioUser.text  {
            if myPassWord.count < 8 {
                intrinioUser.text = "more characters required"
                return
            }
            UserDefaults.standard.set(myPassWord, forKey: "password")
        } else {
            print("No Password Set")
        }
        
        if  let sciPassWord = siChart.text  {
            if sciPassWord.count < 8 {
                siChart.text = "more characters required"
                return
            }
            UserDefaults.standard.set(sciPassWord, forKey: "scichartLicense")
            segueToScanVC()
        } else {
            print("No API Key Set")
        }
    }
    
    private func segueToScanVC() {
        let myVC:ScanViewController = storyboard?.instantiateViewController(withIdentifier: "ScanVC") as! ScanViewController
        navigationController?.pushViewController(myVC, animated: true)
    }

}
