//
//  MyPageVC.swift
//  Befit
//
//  Created by 이충신 on 25/12/2018.
//  Copyright © 2018 GGOMMI. All rights reserved.
//
//  MyPage.Storyboard
//  0) 마이페이지 첫번째 VC(설정, 정보, 선택항목을 보여줌)

import UIKit

class MyPageVC: UIViewController {

    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var userEmail: UILabel!
    var gender: String?
    var brandIdx: [Int] = [0,0]
    
    @IBOutlet weak var tableView: UITableView!
    
    let tableData = ["나의 패션 취향", "나의 사이즈 정보", "통합회원정보관리", "고객센터"]
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        tableView.delegate = self;
        tableView.dataSource = self;
   
        tableView.separatorStyle = .none
        tableView.tableFooterView = UIView()
        tableView.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: 375, height: 20))
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        network()
    
    }
    
  
    func network(){
        
        UserInfoService.shared.showUserInfo { (res) in
            
            print("\n<***현재 회원 정보***>")
            print("idx = \(res.idx!)")
            print("email = \(res.email!)")
            print("pw = \(res.password!)")
            print("gender = \(res.gender!)")
            print("name = \(res.name!)")
            print("brand1 = \(res.brand1_idx!)")
            print("brand2 = \(res.brand2_idx!)")
            print("birth = \(res.birthday!)")
      
            self.userName.text = res.name
            self.userEmail.text = res.email
            self.gender = res.gender
            
            self.brandIdx[0] = res.brand1_idx!
            self.brandIdx[1] = res.brand2_idx!
            
            //정보의 일부가 없으면 guard let으로 빠져나감(코드 순서 변경 하지 말것)
            guard let address = res.home_address, let detail = res.detail_address, let phone = res.phone, let post = res.post_number
                else {return}
            
            print("postcode = " + post)
            print("adress = " + address + " " + detail)
            print("phone = " + phone + "\n")
            
        }
    }
    
    @IBAction func settingBtn(_ sender: Any) {
        let settingVC = Storyboard.shared().myPage.instantiateViewController(withIdentifier: "SettingVC") as! SettingVC
        self.navigationController?.present(settingVC, animated: true, completion: nil)
    }
    

}



extension MyPageVC : UITableViewDelegate, UITableViewDataSource{
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       return  tableData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
         let cell = tableView.dequeueReusableCell(withIdentifier: "MyPageTVCell") as! MyPageTVCell
         cell.titleLB.text = tableData[indexPath.row]
         return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        switch indexPath.row {
            
            case 0:
                let changeBrandVC = Storyboard.shared().myPage.instantiateViewController(withIdentifier: "ChangeBrandVC")as! ChangeBrandVC
                    changeBrandVC.gender = self.gender
                    changeBrandVC.brandIdx = self.brandIdx
                    self.navigationController?.pushViewController(changeBrandVC, animated: true)
            
            case 1:
                let sizeInfoVC1 = Storyboard.shared().myPage.instantiateViewController(withIdentifier: "SizeInfoVC1")as! SizeInfoVC1
                    sizeInfoVC1.gender = self.gender
                    self.navigationController?.pushViewController(sizeInfoVC1, animated: true)
            
            case 2:
                let userInfoAdminVC = Storyboard.shared().myPage.instantiateViewController(withIdentifier: "UserInfoAdminVC")as! UserInfoAdminVC
                    self.navigationController?.present(userInfoAdminVC, animated: true, completion: nil)

            case 3:
                    print("고객센터 뷰로 이동")
            default: break
        
        }
        
     }
    
}

