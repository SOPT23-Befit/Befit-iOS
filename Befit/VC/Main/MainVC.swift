//
//  ViewController.swift
//  Befit
//
//  Created by 이충신 on 25/12/2018.
//  Copyright © 2018 GGOMMI. All rights reserved.
//

import UIKit
import SideMenuSwift

class MainVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    @IBAction func categoryAction(_ sender: Any) {
        self.sideMenuController?.revealMenu();
    }
    

}

