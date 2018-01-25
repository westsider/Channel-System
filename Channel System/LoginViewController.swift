//
//  LoginViewController.swift
//  Channel System
//
//  Created by Warren Hansen on 1/25/18.
//  Copyright © 2018 Warren Hansen. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    

    func saveIntrinio(user:String, password:String){
        var user = ""
        var password = ""
        if  let myUser = UserDefaults.standard.object(forKey: "user")   {
            user = myUser as! String
        } else {
            print("No User Set")
        }
        if  let myPassWord = UserDefaults.standard.object(forKey: "password")  {
            password = myPassWord as! String
        } else {
            print("No Password Set")
        }
    }

}
