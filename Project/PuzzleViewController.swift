//
//  PuzzleViewController.swift
//  Project
//
//  Created by Knaz on 2017/1/2.
//  Copyright © 2017年 Knaz. All rights reserved.
//

import UIKit
import CoreLocation

class PuzzleViewController: UIViewController,UIPickerViewDelegate, UIPickerViewDataSource , CLLocationManagerDelegate{

    //images
    @IBOutlet weak var image1: UIImageView!
    @IBOutlet weak var image2: UIImageView!
    @IBOutlet weak var image3: UIImageView!
    @IBOutlet weak var image4: UIImageView!
    @IBOutlet weak var image5: UIImageView!
    @IBOutlet weak var image6: UIImageView!
    @IBOutlet weak var image7: UIImageView!
    @IBOutlet weak var image8: UIImageView!
    @IBOutlet weak var image9: UIImageView!
    
    //get userid
    let userid = UserDefaults.standard.object(forKey: "userid") as! String
    
    //user location
    var locationManager :CLLocationManager!
    
    //place location
    var placeLatitude : Double!
    var placeLongitude : Double!
    
    //選擇奉獻超原力
    @IBOutlet weak var textfield: UITextField!
    var places = [1,2,3,4,5,6,7,8]
    var place = 0

    //超原力目前擺放位置
    var forceColorString = ""
    var color = ""
    var number = 0
    
    //toast label
    var toastLabel :UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        var images = [image1,image2,image3,image4,image5,image6,image7,image8]
        
        //取得拼圖顏色
        httpGet(URL:"http://140.119.163.40:8080/DarkEmpire/app/ver1.0/forceColor")
        
        //初始化拼圖
        image9.image = UIImage(named:"magicBorder")
        
        for placeNumber in 0...7
        {
            let currentColor = forceColorString.characters.first
            if currentColor == "Y"
            {
                color = "Yellow"
                number = placeNumber + 1
                images[placeNumber]?.image = UIImage(named:"magic\(color)\(number)")

            }
            else if currentColor == "R"
            {
                color = "Red"
                number = placeNumber + 1
                images[placeNumber]?.image = UIImage(named:"magic\(color)\(number)")

            }
            else if currentColor == "B"
            {
                color = "Blue"
                number = placeNumber + 1
                images[placeNumber]?.image = UIImage(named:"magic\(color)\(number)")

            }
            else if currentColor == "D"
            {
                color = "Dark"
                number = placeNumber + 1
                images[placeNumber]?.image = UIImage(named:"magic\(color)\(number)")

            }
            let index = forceColorString.index((forceColorString.startIndex), offsetBy: 0)
            forceColorString.remove(at: index)
            
            //set toast message
            toastLabel = UILabel(frame: CGRect(x:0 , y:0 , width:UIScreen.main.bounds.width * 0.9 , height:UIScreen.main.bounds.height * 0.1))
            toastLabel.center = CGPoint(x: UIScreen.main.bounds.width * 0.5 , y: UIScreen.main.bounds.height * 0.9)
            toastLabel.backgroundColor = UIColor.gray
            toastLabel.textColor = UIColor.white
            toastLabel.textAlignment = NSTextAlignment.center
        }
        
        //picker view
        let picker: UIPickerView
        picker = UIPickerView(frame: CGRect(x:0, y:200, width:view.frame.width, height:120))
        
        picker.showsSelectionIndicator = true
        picker.delegate = self
        picker.dataSource = self
        
        let toolBar = UIToolbar()
        toolBar.barStyle = UIBarStyle.default
        toolBar.isTranslucent = true
        //toolBar.tintColor = UIColor(red: 76/255, green: 217/255, blue: 100/255, alpha: 1)
        toolBar.sizeToFit()
        
        let doneButton = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.plain, target: self, action: #selector(donePicker))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
        let cancelButton = UIBarButtonItem(title: "Cancel", style: UIBarButtonItemStyle.plain, target: self, action: #selector(cancelPicker))
        
        toolBar.setItems([cancelButton, spaceButton, doneButton], animated: false)
        toolBar.isUserInteractionEnabled = true
        
        textfield.inputView = picker
        textfield.inputAccessoryView = toolBar
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func httpGet(URL:String) {
        
        let request = NSURLRequest(url: NSURL(string: URL)! as URL)
        let urlSession = URLSession.shared
        let semaphore = DispatchSemaphore(value: 0)
        var success = 0
        let task = urlSession.dataTask(with: request as URLRequest, completionHandler:{(data, response, error) -> Void in
            
            if let error = error
            {
                print(error)
                
                let netConnectionAlertView = UIAlertController(title: "網路連線異常", message: "請確認網路已連線，才能繼續進行遊戲喔", preferredStyle: .alert)
                let okAction = UIAlertAction(title: "我知道了", style: .default, handler: nil)
                netConnectionAlertView.addAction(okAction)
                self.present(netConnectionAlertView , animated: true , completion: nil)
            }
            else
            {
                if URL == "http://140.119.163.40:8080/DarkEmpire/app/ver1.0/forceColor"
                {
                    let data = data
                    let NSresponseString = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)
                    self.forceColorString = NSresponseString! as String
                }
                
                if URL == "http://140.119.163.40:8080/DarkEmpire/app/ver1.0/releaseForce/\(self.userid)/\(self.textfield.text!)"
                {
                    let data = data
                    let NSresponseString = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)
                    let responseString = NSresponseString as! String
                    
                    if responseString == "false"
                    {
                        let failAlertView = UIAlertController(title: "奉獻超原力失敗", message: "請稍後再嘗試", preferredStyle: .alert)
                        let okAction = UIAlertAction(title: "我知道了", style: .default, handler: nil)
                        failAlertView.addAction(okAction)
                        self.present(failAlertView , animated: true , completion: nil)
                    }
                    
                    else
                    {
                        success = 1
                    }
                }
            }
            semaphore.signal()
        })
        task.resume()
        semaphore.wait()
        
        if success == 1
        {
            //使用者位置
            locationManager = CLLocationManager()
            locationManager.delegate = self
            let latitude = (locationManager.location?.coordinate.latitude)!
            let longitude = (locationManager.location?.coordinate.longitude)!
            
            httpGet(URL: "http://140.119.163.40:8080/DarkEmpire/app/ver1.0/storeAction/\(userid)/9/\(longitude)/\(latitude)/")
        }
    }
    
    //picker View
    // UIPickerView 有幾列
    func numberOfComponents(
        in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    // UIPickerView 各列有多少行資料
    func pickerView(_ pickerView: UIPickerView,numberOfRowsInComponent component: Int) -> Int {
        return places.count
    }
    
    // UIPickerView 每個選項顯示的資料
    func pickerView(_ pickerView: UIPickerView,titleForRow row: Int, forComponent component: Int)-> String? {
        return String(places[row])
    }
    
    // UIPickerView 改變選擇後執行的動作
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int)
    {
        place = row
        textfield.text = String(places[row])
    }
    
    func cancelPicker() {
        textfield.resignFirstResponder()
    }
    
    func donePicker(){
        if (CLLocationManager.authorizationStatus() == .denied)
        {
            // 提示可至[設定]中開啟權限
            let alertController = UIAlertController(
                title: "定位權限已關閉",
                message: "請先開啟定位使用權限，才能繼續進行遊戲喔",
                preferredStyle: .alert)
            let okAction = UIAlertAction(
                title: "我知道了", style: .default, handler:nil)
            alertController.addAction(okAction)
            self.present(alertController, animated: true, completion: nil)
        }
        else
        {
            textfield.resignFirstResponder()
            if(textfield.text == "")
            {
                textfield.text = "1"
            }
            
            //set user location
            locationManager = CLLocationManager()
            locationManager.delegate = self
            let latitude = (locationManager.location?.coordinate.latitude)!
            let longitude = (locationManager.location?.coordinate.longitude)!
            
            //求位置差
            let radLat1 = placeLatitude * Double.pi / 180.0
            let radLat2 = latitude * Double.pi / 180.0
            let a = radLat1 - radLat2
            let b = (placeLongitude * Double.pi / 180.0) - (longitude * Double.pi / 180.0)
            var s = 2 * asin(sqrt(pow(sin(a/2),2) + cos(radLat1) * cos(radLat2) * pow(sin(b/2),2)))
            s = s * 6378137//位置差
            
            //距離太遠
            if s < 100
            {
                //變更拼圖顏色
                httpGet(URL: "http://140.119.163.40:8080/DarkEmpire/app/ver1.0/releaseForce/\(self.userid)/\(self.textfield.text!)")
                
                //取得拼圖顏色
                httpGet(URL: "http://140.119.163.40:8080/DarkEmpire/app/ver1.0/forceColor")
                
                //初始化拼圖
                var images = [self.image1,self.image2,self.image3,self.image4,self.image5,self.image6,self.image7,self.image8]
                for index in 0...7
                {
                    let currentColor = self.forceColorString.characters.first
                    if currentColor == "Y"
                    {
                        self.color = "Yellow"
                        self.number = index + 1
                        images[index]?.image = UIImage(named:"magic\(self.color)\(self.number)")
                    }
                    else if currentColor == "R"
                    {
                        self.color = "Red"
                        self.number = index + 1
                        images[index]?.image = UIImage(named:"magic\(self.color)\(self.number)")
                    }
                    else if currentColor == "B"
                    {
                        self.color = "Blue"
                        self.number = index + 1
                        images[index]?.image = UIImage(named:"magic\(self.color)\(self.number)")
                    }
                    else if currentColor == "D"
                    {
                        self.color = "Dark"
                        self.number = index + 1
                        images[index]?.image = UIImage(named:"magic\(self.color)\(self.number)")
                    }
                    let index = self.forceColorString.index((self.forceColorString.startIndex), offsetBy: 0)
                    self.forceColorString.remove(at: index)
                }
            }
            else
            {
                let distance = Int(abs(s - 99))
                //toast message
                self.view.addSubview(self.toastLabel)
                //self.toastLabel.text = "Loading Data (\(dataCount)/8)"
                self.toastLabel.text = "與該地點距離太遠 還要再\(distance)公尺"
                self.toastLabel.alpha = 1.0
                self.toastLabel.clipsToBounds = true
                self.toastLabel.layer.cornerRadius = self.toastLabel.bounds.size.height * 0.5
                UIView.animate(withDuration: 2.0, delay: 1.0, options: UIViewAnimationOptions.curveEaseOut, animations: {
                    self.toastLabel.alpha = 0.0
                })
            }
        }
    }
}
