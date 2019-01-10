//
//  MySizeVC.swift
//  Befit
//
//  Created by 이충신 on 05/01/2019.
//  Copyright © 2019 GGOMMI. All rights reserved.
//

import UIKit

class MySizeVC: UIViewController {

    @IBOutlet weak var productImg: UIImageView!
    @IBOutlet weak var brandName: UILabel!
    @IBOutlet weak var productName: UILabel!
    @IBOutlet weak var size: UILabel!
    var categoryIdx: Int?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = true
        self.tabBarController?.tabBar.isHidden = true
        
        network()
    
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.navigationBar.isHidden = false
        self.tabBarController?.tabBar.isHidden = false
    }
    
    
    func network(){
        
        GetClosetDetailService.shared.showClosetDetail(idx: categoryIdx!, completion: {[weak self] (res) in
            guard let `self` = self else {return}
            guard let data = res.data else {return}
            self.productImg.imageFromUrl(data.image_url!, defaultImgPath: "")
            self.brandName.text = data.name_english
            self.productName.text = data.name
            
        })
    }


    @IBAction func backBtn(_ sender: Any) {
        
        self.navigationController?.popViewController(animated: true)
    }
}
