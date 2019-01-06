//
//  UserInfoVC2.swift
//  Befit
//
//  Created by 이충신 on 25/12/2018.
//  Copyright © 2018 GGOMMI. All rights reserved.
//

import UIKit

class UserInfoVC1: UIViewController {
    
    let uesrDefault = UserDefaults.standard
    
    @IBOutlet weak var womanImg: UIButton!
    @IBOutlet weak var manImg: UIButton!
    @IBOutlet weak var nextBtn: UIButton!
    
    var selected: Bool!
    let gender = UserDefaults.standard.string(forKey: "gender")

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //네비게이션 바 설정
        self.navigationController!.navigationBar.barTintColor = UIColor.white
        UINavigationBar.appearance().shadowImage = UIImage()
        UINavigationBar.appearance().setBackgroundImage(UIImage(), for: .default)

    }
    
    //성별 선택시 이미지 변환
    @IBAction func womanBtn(_ sender: Any) {
        
        if !womanImg.isSelected {
            womanImg.isSelected = true
            womanImg.setImage(#imageLiteral(resourceName: "icWomanTouch"), for: .selected)
            nextBtn.setImage(#imageLiteral(resourceName: "icPurplearrow"), for: .normal)
            manImg.setImage(#imageLiteral(resourceName: "icManNotouch"), for: .selected)
            manImg.isSelected = false
            uesrDefault.set("여", forKey: "gender")
        }
        else{
            womanImg.isSelected = false
            womanImg.setImage(#imageLiteral(resourceName: "icWomanNotouch"), for: .selected)
            nextBtn.setImage(#imageLiteral(resourceName: "icGrayarrow"), for: .normal)
        }
    }
    
    @IBAction func manBtn(_ sender: Any) {
        
        
        if !manImg.isSelected {
            manImg.isSelected = true
            manImg.setImage(#imageLiteral(resourceName: "icManTouch"), for: .selected)
            nextBtn.setImage(#imageLiteral(resourceName: "icPurplearrow"), for: .normal)
            womanImg.setImage(#imageLiteral(resourceName: "icWomanNotouch"), for: .selected)
            womanImg.isSelected = false
            uesrDefault.set("남", forKey: "gender")
        }
        else{
            manImg.isSelected = false
            manImg.setImage(#imageLiteral(resourceName: "icManNotouch"), for: .selected)
            nextBtn.setImage(#imageLiteral(resourceName: "icGrayarrow"), for: .normal)
        }
    }
    
    @IBAction func nextBtn(_ sender: Any) {
        
        if manImg.isSelected || womanImg.isSelected {
            let logIn = UIStoryboard.init(name: "LogIn", bundle: nil)
            let userInfoVC = logIn.instantiateViewController(withIdentifier: "UserInfoVC3") as? UserInfoVC2
            self.navigationController?.pushViewController(userInfoVC!, animated: true)
        }
    }
    @IBAction func backAction(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
}
