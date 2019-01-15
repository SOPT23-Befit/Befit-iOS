//
//  BrandVC.swift
//  Befit
//
//  Created by 박다영 on 06/01/2019.
//  Copyright © 2019 GGOMMI. All rights reserved.
//

import UIKit

class BrandVC: UIViewController {
    

    @IBOutlet weak var collectionView: UICollectionView!
    var brandInfo : Brand!
    var brandIdx: Int?
    var productInfo: [Product]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.delegate = self;
        collectionView.dataSource = self;
        
    }
   
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = true
        self.tabBarController?.tabBar.isHidden = true
        productListNewInit()
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.navigationBar.isHidden = false
        self.tabBarController?.tabBar.isHidden = false
    }
    

    @IBAction func backAction(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    
    func productListNewInit() {
        BrandProductSorting.shared.showSortingNew (brandIdx: brandIdx!, completion: { (productData) in
            self.productInfo = productData

            self.collectionView.reloadData()
        })
    }
    
    func productListPopularInit() {
        BrandProductSorting.shared.showSortingPopular(brandIdx: brandIdx!, completion: { (productData) in
            self.productInfo = productData
        
            self.collectionView.reloadData()
        })
    }
    
}

extension BrandVC: UICollectionViewDataSource{
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2
    }

    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if section == 0 {
            return 1
        }else {
            guard let product = productInfo else {return 0}
            return product.count
        }
        
    }
    
 
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        //1) 상단부 브랜드 페이지
        if indexPath.section == 0 {
            
            let cell1 = collectionView.dequeueReusableCell(withReuseIdentifier: "BrandDetailCVCell", for: indexPath) as! BrandDetailCVCell
            
            cell1.BrandLogoImg.imageFromUrl(brandInfo.logo_url, defaultImgPath: "")
            cell1.brandBackGround.imageFromUrl(brandInfo.mainpage_url, defaultImgPath: "")
            cell1.BrandNameEndglishLB.text = brandInfo.name_english
            cell1.BrandNameKoreanLB.text = brandInfo.name_korean
            
            if brandInfo.likeFlag == 1 {
                 cell1.LikeBtn.setImage(#imageLiteral(resourceName: "icLikeFull"), for: .normal)
            }else{
                cell1.LikeBtn.setImage(#imageLiteral(resourceName: "icLikeFull2"), for: .normal)
            }
            
            guard let product = productInfo else {return cell1}
            cell1.ProductNumLB.text = "PRODUCT (" + "\(product.count)" + ")"
        
            //인기순 신상품순 버튼 설정
            cell1.NewBtn.addTarget(self, action: #selector(newBtnClicked), for: .touchUpInside)
            cell1.PopularBtn.addTarget(self, action: #selector(popularBtnClicked), for: .touchUpInside)
            
            //브랜드 좋아요 하트 버튼 설정
            cell1.LikeBtn.addTarget(self, action: #selector(clickLike(_:)), for: .touchUpInside)
            
            return cell1
        }
            
        //2) 하단부 브랜드의 상품 리스트
        else {
        
            let cell2 = collectionView.dequeueReusableCell(withReuseIdentifier: "CategoryDetailCVCell", for: indexPath) as! CategoryDetailCVCell
            
            cell2.backgroundColor = UIColor.white
            
            cell2.brandName.text = productInfo?[indexPath.row].name_korean
            cell2.productName.text = productInfo?[indexPath.row].name
            cell2.price.text = productInfo?[indexPath.row].price
            cell2.productImg.imageFromUrl(productInfo?[indexPath.row].image_url, defaultImgPath: "")
            
            return cell2
        }
        
    }
    
    
    //좋아요가 작동하는 부분
    @objc func clickLike(_ sender: UIButton){
        
        if sender.imageView?.image == #imageLiteral(resourceName: "icLikeFull") {
             sender.setImage(#imageLiteral(resourceName: "icLikeFull2"), for: .normal)
            
            //1) 브랜드 좋아요 취소가 작동하는 부분
            UnLikeBService.shared.unlike(brandIdx: brandIdx!) { (res) in
                if let status = res.status {
                    switch status {
                    case 200 :
                        print("브랜드 좋아요 취소 성공!")
                    case 400...600 :
                        self.simpleAlert(title: "ERROR", message: res.message!)
                    default: break
                    }
                }
            }
        }
            
        else {
            sender.setImage(#imageLiteral(resourceName: "icLikeFull"), for: .normal)
            
            //2)브랜드 좋아요가 작동하는 부분
            LikeBService.shared.like(brandIdx: brandIdx!) { (res) in
                if let status = res.status {
                    switch status {
                    case 201 :
                        print("브랜드 좋아요 성공!")
                    case 400...600 :
                        self.simpleAlert(title: "ERROR", message: res.message!)
                    default: break
                    }
                }
            }
            
        }
        
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if indexPath.section == 0 {
            let productVC  = UIStoryboard(name: "Product", bundle: nil).instantiateViewController(withIdentifier: "ProductVC")as! ProductVC
            productVC.brandName = brandInfo.name_english
            productVC.address = brandInfo.link
            productVC.brandHome = true
            print("브랜드의 링크 = " + brandInfo.link!)
            self.navigationController?.present(productVC, animated: true, completion: nil)
        }
        else {
            let productVC  = UIStoryboard(name: "Product", bundle: nil).instantiateViewController(withIdentifier: "ProductVC")as! ProductVC
            productVC.brandName = productInfo?[indexPath.row].name_English
            productVC.address = productInfo?[indexPath.row].link
            productVC.productInfo = productInfo?[indexPath.row]
            self.navigationController?.present(productVC, animated: true, completion: nil)
        }
    }
    
    
    @objc func newBtnClicked(){
        productListNewInit()
        
    }
    
    @objc func popularBtnClicked(){
        productListPopularInit()
        
    }
    
}


extension BrandVC: UICollectionViewDelegateFlowLayout{

    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        if indexPath.section == 0 {
            // main에서 추천 brand 타고 들어 왔을 때 : 475
            // ranking : 268
            return CGSize(width: 375, height: 268)
            
        }
        else {
            return CGSize(width: 167, height: 235)
        }
        
   }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 9
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        
        return 9
    
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        
        if section == 0 {
            return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        } else {
            return UIEdgeInsets(top: 0, left: 15, bottom: 15, right: 15)
        }
        
    }
    
}


extension UIImageView {
    
    func setRounded() {
        self.layer.cornerRadius = (self.frame.width / 2)
        //instead of let radius = CGRectGetWidth(self.frame) / 2
        self.layer.masksToBounds = true
    }
}

