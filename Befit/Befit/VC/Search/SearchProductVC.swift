//
//  SearchProductVC.swift
//  Befit
//
//  Created by 이충신 on 30/12/2018.
//  Copyright © 2018 GGOMMI. All rights reserved.
//
//  Search.Storyboard
//  2-1) 키워드 검색 결과 관련된 상품 목록 보여주는 VC (CollectionView)

import UIKit
import XLPagerTabStrip

class SearchProductVC: UIViewController {
    
    @IBOutlet weak var noResultView: UIView!
    @IBOutlet weak var collectionView: UICollectionView!
    
    //prevent Button image disappear in custom cell
    var productLikesImg: [UIImage]?
    var productList: [Product]?
    
    var searchKeyword: String = ""
    
 
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.delegate = self;
        collectionView.dataSource = self;
        NotificationCenter.default.addObserver(self, selector: #selector(searchListen), name: Notification.Name(rawValue: "searchEnd"), object: nil)
    }
    
    @objc func searchListen(){
        viewWillAppear(true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        guard let keyword = UserDefaults.standard.string(forKey: "SearchKeyword") else {return}
        searchKeyword = keyword
        sortingNew(keyword: searchKeyword)
    }
    
}

extension SearchProductVC: UICollectionViewDataSource {
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        guard let product = productList else {
            noResultView.isHidden = false
            return 0
        }
        
        return product.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ProductCVCell", for: indexPath) as! ProductCVCell
        guard let product = productList else {return cell}
        
        cell.brandName.text = product[indexPath.row].name_korean
        cell.productName.text =  product[indexPath.row].name
        cell.price.text = product[indexPath.row].price
        cell.productImg.imageFromUrl2(product[indexPath.row].image_url, defaultImgPath: "")
        
        //likeBtn 구현부
        cell.likeBtn.addTarget(self, action: #selector(clickLike(_:)), for: .touchUpInside)
        cell.likeBtn.tag = indexPath.row
        cell.likeBtn.setImage(productLikesImg?[indexPath.row], for: .normal)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        guard let searchProduct = productList?[indexPath.row] else {return}
        
        let productVC = Storyboard.shared().product.instantiateViewController(withIdentifier: "ProductVC")as! ProductVC
        productVC.productInfo = searchProduct
        self.navigationController?.present(productVC, animated: true, completion: nil)
        
    }
    
    @objc func clickLike(_ sender: UIButton){
        
        guard let productIdx = productList?[sender.tag].idx else {return}
        
        //1) 상품 좋아요 취소가 작동하는 부분
        if sender.imageView?.image == #imageLiteral(resourceName: "icLikeFull") {
            unlike(idx: productIdx)
            sender.setImage(#imageLiteral(resourceName: "icLikeLine"), for: .normal)
            productLikesImg?[sender.tag] = #imageLiteral(resourceName: "icLikeLine")
        }
            
        //2)상품 좋아요가 작동하는 부분
        else {
            like(idx: productIdx)
            sender.setImage(#imageLiteral(resourceName: "icLikeFull"), for: .normal)
            productLikesImg?[sender.tag] = #imageLiteral(resourceName: "icLikeFull")
            
            
        }
        
    }

    
}

extension SearchProductVC:  UICollectionViewDelegateFlowLayout {
    
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        switch kind {
            
        case UICollectionView.elementKindSectionHeader:
            
            let cell = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "NewPopularSortingCRV", for: indexPath as IndexPath) as! NewPopularSortingCRV
            
            cell.backgroundColor =  #colorLiteral(red: 0.9215686275, green: 0.9215686275, blue: 0.9215686275, alpha: 1)
            cell.isUserInteractionEnabled = true
            cell.popularBtn.addTarget(self, action: #selector(popularReload), for: .touchUpInside)
            cell.newBtn.addTarget(self, action: #selector(newReload), for: .touchUpInside)
            return cell
            
        default:
            assert(false, "Unexpected element kind")
        }
        
    }
    
    @objc func newReload(){
       sortingNew(keyword: searchKeyword)
    }
    
    @objc func popularReload(){
        sortingPopular(keyword: searchKeyword)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 167, height: 239)
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 9
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 9
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        
        return UIEdgeInsets(top: 0, left: 15, bottom: 15, right: 15)
    }
    
}

extension SearchProductVC: IndicatorInfoProvider{
    
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return IndicatorInfo(title: "상품")
    }
}

//Mark: - Network Service
extension SearchProductVC {
    
    func sortingNew(keyword: String){
        SearchProductService.shared.showSearchProductNew(keyword: keyword) { (res) in
            
            
            guard let status = res.status else {return}
            
            print(status)
            
            if status == 200 {
                
                if res.data == nil {
                    self.noResultView.isHidden = false
                    self.collectionView.isHidden = true
                }
                else{
                    self.noResultView.isHidden = true
                    self.collectionView.isHidden = false
                }
                
            }
            
                self.productList = res.data
            
                if let data = res.data {
                    self.productLikesImg = []
                    for product in data {
                        let likeImg = product.product_like == 1 ? #imageLiteral(resourceName: "icLikeFull") : #imageLiteral(resourceName: "icLikeLine")
                        self.productLikesImg?.append(likeImg)
                    }
                }
            
                self.collectionView.reloadData()
            
        }
    }
    
    func sortingPopular(keyword: String){
        SearchProductService.shared.showSearchProductPopular(keyword: keyword) { (res) in
            self.productList = res.data
            self.productLikesImg = []
            for product in res.data! {
                let likeImg = product.product_like == 1 ? #imageLiteral(resourceName: "icLikeFull") : #imageLiteral(resourceName: "icLikeLine")
                self.productLikesImg?.append(likeImg)
            }
            self.collectionView.reloadData()
        }
    }
    
    func like(idx: Int){
        LikePService.shared.like(productIdx: idx) { (res) in
            if let status = res.status {
                switch status {
                case 201 :
                    print("상품 좋아요 성공!")
                case 400...600 :
                    self.simpleAlert(title: "ERROR", message: res.message!)
                default: return
                }
            }
        }
    }

    
    func unlike(idx: Int){
        LikePService.shared.unlike(productIdx: idx) { (res) in
            if let status = res.status {
                switch status {
                case 200 :
                    print("상품 좋아요 취소 성공!")
                case 400...600 :
                    self.simpleAlert(title: "ERROR", message: res.message!)
                default: return
                }
            }
        }
    }
    
    
}


