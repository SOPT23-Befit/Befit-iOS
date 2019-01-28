//
//  SizeCheckVC.swift
//  Befit
//
//  Created by 이충신 on 11/01/2019.
//  Copyright © 2019 GGOMMI. All rights reserved.
//
//  웹 뷰에 띄울 사이즈 체크 비교 팝업 뷰

import UIKit

enum BodyPart: String {
    
    case chest = "가슴 단면"
    case total = "총장"
    case shoulder = "어깨 너비"
    case sleeve = "소매 길이"
    case waist = "허리 단면"
    case thigh = "허벅지 단면"
    case crotch = "밑위"
    case dobla = "밑단 단면"
    
}

class SizeCheckVC: UIViewController {
    
    var keyboardDismissGesture : UITapGestureRecognizer?
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var originalImage: UIImageView!
    @IBOutlet weak var sizeCheckView: UIView!
    
    //내 비교 상품 리스트(옷장)
    var myClosetList: [Closet]?
    var comparableList: [SizeCheck] = []
    var realKey: [String] = []

    //선택한 상품 정보
    var productInfo: Product?
    var productSizeList: [String] = []
    @IBOutlet weak var productNameLB: UILabel!
    @IBOutlet weak var productSizeLB: UILabel!
    
    //Picker, TF, PageControl
    @IBOutlet weak var productTF: UITextField!
    let pickerView = UIPickerView()
    @IBOutlet weak var pageControl: UIPageControl!
    
    //상품 사이즈 정보 LB 관련
    @IBOutlet weak var wholeStack: UIStackView!
    @IBOutlet weak var fourthStack: UIStackView!
    @IBOutlet weak var fifthStack: UIStackView!
    
    var LB0Array: [UILabel] = []
    @IBOutlet weak var LB00: UILabel!
    @IBOutlet weak var LB01: UILabel!
    @IBOutlet weak var LB02: UILabel!
    @IBOutlet weak var LB03: UILabel!
    @IBOutlet weak var LB04: UILabel!
    var LB1Array: [UILabel] = []
    @IBOutlet weak var LB10: UILabel!
    @IBOutlet weak var LB11: UILabel!
    @IBOutlet weak var LB12: UILabel!
    @IBOutlet weak var LB13: UILabel!
    @IBOutlet weak var LB14: UILabel!
    var LB2Array: [UILabel] = []
    @IBOutlet weak var LB20: UILabel!
    @IBOutlet weak var LB21: UILabel!
    @IBOutlet weak var LB22: UILabel!
    @IBOutlet weak var LB23: UILabel!
    @IBOutlet weak var LB24: UILabel!
    ////////////////////////////////
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.black.withAlphaComponent(0.8)
        self.showAnimate()
        initPickerWithTF()
        collectionView.delegate = self;
        collectionView.dataSource = self;
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        initProducutInfo()
        initLB()
        network()
    }
    
    func initProducutInfo(){
        
        //1) 뷰의 시작점에서 현재 선택한 상품의 사이즈 종류를 Export.
        guard let psize = productInfo?.measure1?.toJSON().keys.sorted()else{return}
        productSizeList = Array(psize)
        
        //2) 선택한 상품의 이름을 설정
        productNameLB.text = productInfo?.name
        
        //3) 페이지 컨트롤의 수는 선택한 상품의 사이즈 갯수
        pageControl.numberOfPages = productSizeList.count
    }
    
    func initLB(){
        
        LB0Array.append(LB00); LB0Array.append(LB01)
        LB0Array.append(LB02); LB0Array.append(LB03)
        LB0Array.append(LB04)
        
        LB1Array.append(LB10); LB1Array.append(LB11)
        LB1Array.append(LB12); LB1Array.append(LB13)
        LB1Array.append(LB14)
        
        LB2Array.append(LB20); LB2Array.append(LB21)
        LB2Array.append(LB22); LB2Array.append(LB23)
        LB2Array.append(LB24)

    }
    
    func network(){
        
        //선택한 상품의 카테고리 인덱스를 파악하여 해당 카테고리의 정보들을 불러온다.
        GetClosetListService.shared.showClosetList(idx: (productInfo?.product_category_index)!) { (res) in

            self.myClosetList = res.data
            
            //1) 옷장에 데이터가 없는 경우
            if res.data == nil {
                //************이 시점에서 뷰(옷장 등록을 유도하는)를 Show ************
                self.simpleAlert(title: "ERROR", message: "등록된 옷장이 없습니다!!")
            }
                
            //2) 옷장에 데이터가 있는 경우
            else {
                print("closet_idx = \(res.data?[0].closet_idx)")
                print("product_idx = \(self.productInfo?.idx)")
                print("productSizeList.first = \(self.productSizeList.first)")
                
                // Original Image 설정
                SizeCheckService.shared.showSizeCheck(closetIdx: res.data?[0].closet_idx!, productIdx: self.productInfo?.idx!, productSize: self.productSizeList.first) { (res) in
                    print("(result!! = \(res)")
                    self.originalImage.imageFromUrl(res.data?.my_url, defaultImgPath: "")
                }
            }
            
        }
        
    }
    
    @IBAction func okBtn(_ sender: Any) {
        self.removeAnimate();
    }

}


extension SizeCheckVC: UIPickerViewDelegate,UIPickerViewDataSource{
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        
        guard let closet = myClosetList else {return 0}
        return closet.count
        
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        guard let closet = myClosetList else {return ""}
        return closet[row].name
    }

    
    func initPickerWithTF() {
        
        pickerView.delegate = self;
        pickerView.dataSource = self;
        productTF.delegate = self;
        
        let bar = UIToolbar()
        let doneButton = UIBarButtonItem(title: "확인", style: .done, target: self, action: #selector(selectedPicker))
        let flexible = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        bar.setItems([flexible, doneButton], animated: true)
        bar.sizeToFit()
        
        productTF.addTarget(self, action: #selector(selectedPicker), for: .touchUpInside)
        productTF.delegate = self;
        productTF.inputAccessoryView = bar
        productTF.inputView = pickerView
        
    }
    
    ///MARK: - Select Picker
    @objc func selectedPicker(){
        
        let row = pickerView.selectedRow(inComponent: 0)
       
        self.sizeCheckNetwork(row)
        self.valueSetting(0)
        
        collectionView.contentOffset.x = 0
        pageControl.currentPage = 0
        collectionView.isScrollEnabled = true
        wholeStack.isHidden = false
        collectionView.reloadData()
        self.view.endEditing(true)
    }
    

}

extension SizeCheckVC {
    
    
    //1) 사이즈 체크 정보 통신 구현부
    func sizeCheckNetwork(_ row: Int){
        
        guard let myCloset = myClosetList?[row] else {return}
        productTF.text = myCloset.name
        comparableList.removeAll()
        
        //사이즈 종류 별로 각각 비교결과 값을 가져오는 부분
        for size in productSizeList {
            
            let runLoop = CFRunLoopGetCurrent() //Synchronous하게 받아오기 위해 사용.
            
            SizeCheckService.shared.showSizeCheck(closetIdx: myCloset.closet_idx!, productIdx: productInfo?.idx!, productSize: size) { (res) in
                
                print("\n<" + size + " Size와의 비교 결과>")
                print(res.data)
                self.comparableList.append(res.data!)
                
                print("\n<comparable에 append 이후 데이터")
                print(self.comparableList)
                
                guard let keys = res.data?.measure?.toJSON().keys else {return}
                self.realKey = Array(keys)
            
                CFRunLoopStop(runLoop)//Stop Loop
            }
            
            CFRunLoopRun()//Run Loop
        }
        
        print("\n<realKey배열에 저장된 데이터>")
        print(self.realKey)
        
        //LB0의 항목들을 설정
        for (idx, key) in self.realKey.enumerated() {
            switch key {
                case "chestSection":
                    self.LB0Array[idx].text = BodyPart.chest.rawValue
                    break
                case "totalLength":
                    self.LB0Array[idx].text = BodyPart.total.rawValue
                    break
                case "shoulderWidth":
                    self.LB0Array[idx].text = BodyPart.shoulder.rawValue
                    break
                case "sleeveLength":
                    self.LB0Array[idx].text = BodyPart.sleeve.rawValue
                    break
                case "waistSection":
                    self.LB0Array[idx].text = BodyPart.waist.rawValue
                    break
                case "thighSection":
                    self.LB0Array[idx].text = BodyPart.thigh.rawValue
                    break
                case "crotch":
                    self.LB0Array[idx].text = BodyPart.crotch.rawValue
                    break
                case "dobladillosSection":
                    self.LB0Array[idx].text = BodyPart.dobla.rawValue
                    break
                default:
                    break
            }
            
        }
        
        
    }
    
    
    //2) 수치 레이블에 값을 설정하는 부분
    func valueSetting(_ row: Int){
    
        guard let keys = comparableList[row].measure?.toJSON().keys else {return}
        guard let values = comparableList[row].measure?.toJSON().values else {return}
        
        if keys.count == 3 {
            self.fourthStack.isHidden = true
            self.fifthStack.isHidden = true
        }
        if keys.count == 4 {
            self.fourthStack.isHidden = false
            self.fifthStack.isHidden = true
        }
        if keys.count == 5 {
            self.fourthStack.isHidden = false
            self.fifthStack.isHidden = false
        }
        
        self.productSizeLB.text = productSizeList[row]
        guard let measureDic = productInfo?.measure1?.toJSON() else {return}
        let realDic = measureDic[productSizeList[row]] as! [String : String]
        
        for (idx, value) in values.enumerated() {
            
            let val = value as! String
            
            //1) LB1Array 설정
            if val == "0" {
                LB1Array[idx].text  = "딱맞음"
            }
            else if val.first == "-" {
                LB1Array[idx].text = val.dropFirst() + "cm 작음"
            }
            else {
                LB1Array[idx].text = val + "cm 큼"
            }
            
            //2) LB2Array 설정
            LB2Array[idx].text = realDic[realKey[idx]]! + "cm"
            
        }

    }
    
    
}



extension SizeCheckVC: UICollectionViewDelegate, UICollectionViewDataSource{
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return productSizeList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let row = indexPath.row
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MySizeCheckCVCell", for: indexPath) as! MySizeCheckCVCell
        
        if comparableList.count > 0 {
            cell.sizeCheckImg.imageFromUrl(comparableList[row].compare_url, defaultImgPath: "")
        }

        return cell
    }
    
    
    //Mark: - Detect Page changing
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        
        let row =  Int(round(scrollView.contentOffset.x / scrollView.frame.size.width))
        pageControl.currentPage = row
        
        self.productSizeLB.text = productSizeList[row]
        self.valueSetting(row)

    }
    
}


//MARK: - CollectionView Layout
extension SizeCheckVC: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 323, height: 225)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
    

}


//MARK: - PopUp Animation
extension SizeCheckVC {
    
    func showAnimate()
    {
        self.view.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
        
        self.view.alpha = 0.0;
        UIView.animate(withDuration: 0.3, animations: {
            self.view.alpha = 1.0
            self.view.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
        });
    }
    
    func removeAnimate()
    {
        UIView.animate(withDuration: 0.3, animations: {
            self.view.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
            self.view.alpha = 0.0;
            
        }, completion:{(finished : Bool)  in
            if (finished)
            {
                self.view.removeFromSuperview()
            }
        });
    }
    
}



//MARK: - Out view touch
extension SizeCheckVC: UITextFieldDelegate {
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return true
    }
    
}
