//
//  PurchaseViewController.swift
//  Project
//
//  Created by Knaz on 2017/2/21.
//  Copyright © 2017年 Knaz. All rights reserved.
//

import UIKit
import CoreLocation

class PurchaseViewController: UIViewController , CLLocationManagerDelegate{

    
    @IBOutlet weak var redPotionImage: UIImageView!
    @IBOutlet weak var bluePotionImage: UIImageView!
    @IBOutlet weak var yellowPotionImage: UIImageView!
    @IBOutlet weak var redPlusImage: UIImageView!
    @IBOutlet weak var redMinusImage: UIImageView!
    @IBOutlet weak var bluePlusImage: UIImageView!
    @IBOutlet weak var blueMinusImage: UIImageView!
    @IBOutlet weak var yellowPlusImage: UIImageView!
    @IBOutlet weak var yellowMinusImage: UIImageView!
    @IBOutlet weak var purchaseLabel: UILabel!
    @IBOutlet weak var confirmButton: UIButton!
    
    //user location
    var locationManager :CLLocationManager!
    
    //potion number
    var redPotionNum = 0
    var bluePotionNum = 0
    var yellowPotionNum = 0
    
    //button color
    let confirmButtonColor = UIColor(red: 0.408, green: 0.341, blue: 0.275, alpha: 1.0)
    let confirmButtonCGColor = UIColor(red: 0.408, green: 0.341, blue: 0.275, alpha: 1.0).cgColor
    
    //user
    var userid = UserDefaults.standard.object(forKey: "userid") as! String
    
    //user weapon
    var userWeapons = [UserWeapon]()
    
    //toast label
    var toastLabel: UILabel!
    var toastLabel2: UILabel!
    var responseString = ""
    
    //alert view
    var alertView = UIAlertController()
    let okAction = UIAlertAction(title: "我知道了", style: .default, handler: nil)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        redPotionImage.image = UIImage(named:"potion_red.png")
        bluePotionImage.image = UIImage(named:"potion_blue.png")
        yellowPotionImage.image = UIImage(named:"potion_yellow.png")
        redPlusImage.image = UIImage(named:"plus.png")
        bluePlusImage.image = UIImage(named:"plus.png")
        yellowPlusImage.image = UIImage(named:"plus.png")
        redMinusImage.image = UIImage(named:"minus.png")
        blueMinusImage.image = UIImage(named:"minus.png")
        yellowMinusImage.image = UIImage(named:"minus.png")
        
        //set:觸碰image
        let tapGestureRecognizer1 = UITapGestureRecognizer(target:self , action:#selector(redPlusImageTapped))
        redPlusImage.isUserInteractionEnabled = true
        redPlusImage.addGestureRecognizer(tapGestureRecognizer1)
        
        let tapGestureRecognizer2 = UITapGestureRecognizer(target:self , action:#selector(redMinusImageTapped))
        redMinusImage.isUserInteractionEnabled = true
        redMinusImage.addGestureRecognizer(tapGestureRecognizer2)
        
        let tapGestureRecognizer3 = UITapGestureRecognizer(target:self , action:#selector(bluePlusImageTapped))
        bluePlusImage.isUserInteractionEnabled = true
        bluePlusImage.addGestureRecognizer(tapGestureRecognizer3)
        
        let tapGestureRecognizer4 = UITapGestureRecognizer(target:self , action:#selector(blueMinusImageTapped))
        blueMinusImage.isUserInteractionEnabled = true
        blueMinusImage.addGestureRecognizer(tapGestureRecognizer4)
        
        let tapGestureRecognizer5 = UITapGestureRecognizer(target:self , action:#selector(yellowPlusImageTapped))
        yellowPlusImage.isUserInteractionEnabled = true
        yellowPlusImage.addGestureRecognizer(tapGestureRecognizer5)
        
        let tapGestureRecognizer6 = UITapGestureRecognizer(target:self , action:#selector(yellowMinusImageTapped))
        yellowMinusImage.isUserInteractionEnabled = true
        yellowMinusImage.addGestureRecognizer(tapGestureRecognizer6)
        
        //set label
        purchaseLabel.text! = "紅水\(redPotionNum)瓶，藍水\(bluePotionNum)瓶，黃水\(yellowPotionNum)瓶"
        
        //set button
        MainFunctionViewController().setButtonParameters(button: confirmButton , UIcolor: confirmButtonColor, CGColor: confirmButtonCGColor)
        
        //set toast message
        toastLabel = UILabel(frame: CGRect(x:0 , y:0 , width:UIScreen.main.bounds.width * 0.6 , height:UIScreen.main.bounds.height * 0.1))
        toastLabel.center = CGPoint(x: UIScreen.main.bounds.width * 0.5 , y: UIScreen.main.bounds.height * 0.9)
        toastLabel.backgroundColor = UIColor.gray
        toastLabel.textColor = UIColor.white
        toastLabel.textAlignment = NSTextAlignment.center
        
        //第一次登入：顯示金幣說明
        let firstUseApp_purchaseView = UserDefaults.standard.object(forKey: "firstUseApp_purchaseView") as? String
        if(firstUseApp_purchaseView != "false")
        {
            alertView = UIAlertController(title: "金幣說明", message: "如何獲得金幣\n1.佔領神殿\n連續佔一神殿5天，第5天獲得金幣100枚，第6天200枚，第7天300枚，第8天400枚，第9天500枚。第10天起，每天維持500枚獎勵。\n2.成為超原力使者\n成為超原力使者，立即獲得1000枚金幣。\n\n金幣用途\n每1000枚金幣可以購買1個藍聖水\n每500枚金幣可以購買1個黃聖水\n每200枚金幣可以購買1個紅聖水", preferredStyle: .alert)
            alertView.addAction(okAction)
            self.present(alertView , animated: true , completion: nil)
            UserDefaults.standard.set("false", forKey: "firstUseApp_purchaseView")
            UserDefaults.standard.synchronize()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func redPlusImageTapped(img: AnyObject)
    {
        if redPotionNum != 99
        {
            redPotionNum = redPotionNum + 1
        }
        purchaseLabel.text! = "紅水\(redPotionNum)瓶，藍水\(bluePotionNum)瓶，黃水\(yellowPotionNum)瓶"
    }
    
    func redMinusImageTapped(img: AnyObject)
    {
        if redPotionNum != 0
        {
            redPotionNum = redPotionNum - 1
        }
        purchaseLabel.text! = "紅水\(redPotionNum)瓶，藍水\(bluePotionNum)瓶，黃水\(yellowPotionNum)瓶"
    }
    
    func bluePlusImageTapped(img: AnyObject)
    {
        if bluePotionNum != 99
        {
            bluePotionNum = bluePotionNum + 1
        }
        purchaseLabel.text! = "紅水\(redPotionNum)瓶，藍水\(bluePotionNum)瓶，黃水\(yellowPotionNum)瓶"
    }
    
    func blueMinusImageTapped(img: AnyObject)
    {
        if bluePotionNum != 0
        {
            bluePotionNum = bluePotionNum - 1
        }
        purchaseLabel.text! = "紅水\(redPotionNum)瓶，藍水\(bluePotionNum)瓶，黃水\(yellowPotionNum)瓶"
    }
    
    func yellowPlusImageTapped(img: AnyObject)
    {
        if yellowPotionNum != 99
        {
            yellowPotionNum = yellowPotionNum + 1
        }
        purchaseLabel.text! = "紅水\(redPotionNum)瓶，藍水\(bluePotionNum)瓶，黃水\(yellowPotionNum)瓶"
    }
    
    func yellowMinusImageTapped(img: AnyObject)
    {
        if yellowPotionNum != 0
        {
            yellowPotionNum = yellowPotionNum - 1
        }
        purchaseLabel.text! = "紅水\(redPotionNum)瓶，藍水\(bluePotionNum)瓶，黃水\(yellowPotionNum)瓶"
    }
    
    @IBAction func confirmButtonClicked(_ sender: UIButton) {
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
            if(redPotionNum != 0) && (bluePotionNum != 0) && (yellowPotionNum != 0)
            {
                httpPost(url: "http://140.119.163.40:8080/DarkEmpire/app/ver1.0/buyItem/\(userid)/\(redPotionNum)/\(yellowPotionNum)/\(bluePotionNum)")
                if responseString == "success"
                {
                    //get user weapons
                    userWeapons.removeAll()
                    httpGet(URL: "http://140.119.163.40:8080/DarkEmpire/app/ver1.0/userItem/\(self.userid)")
                    var userRedPotionNum = 0
                    var userYellowPotionNum = 0
                    var userBluePotionNum = 0
                    for weapon in userWeapons
                    {
                        if weapon.item_id == 2
                        {
                            userRedPotionNum = weapon.quantity
                        }
                        else if weapon.item_id == 3
                        {
                            userYellowPotionNum = weapon.quantity
                        }
                        else if weapon.item_id == 4
                        {
                            userBluePotionNum = weapon.quantity
                        }
                    }
                    
                    //alert view
                    let successAlertView = UIAlertController(title: "購買成功!", message: "紅藥水餘剩數量:\(userRedPotionNum)\n黃藥水餘剩數量:\(userYellowPotionNum)\n藍藥水餘剩數量:\(userBluePotionNum)", preferredStyle: .alert)
                    let okAction = UIAlertAction(title: "我知道了", style: .default, handler: nil)
                    successAlertView.addAction(okAction)
                    self.present(successAlertView , animated: true , completion: nil)
                    
                    
                    //set location manager
                    locationManager = CLLocationManager()
                    locationManager.delegate = self
                    
                    //記錄使用者位置
                    let latitude = (locationManager.location?.coordinate.latitude)!
                    let longitude = (locationManager.location?.coordinate.longitude)!
                    
                    httpGet(URL: "http://140.119.163.40:8080/DarkEmpire/app/ver1.0/storeAction/\(userid)/6/\(longitude)/\(latitude)/")
                    
                }
                else if responseString == "rune not enough"
                {
                    //toast message
                    self.view.addSubview(self.toastLabel)
                    self.toastLabel.text = "金幣不足"
                    self.toastLabel.alpha = 1.0
                    self.toastLabel.clipsToBounds  =  true
                    self.toastLabel.layer.cornerRadius = self.toastLabel.bounds.size.height * 0.5
                    UIView.animate(withDuration: 1.0, delay: 0.1, options: UIViewAnimationOptions.curveEaseOut, animations: {
                        self.toastLabel.alpha = 0.0
                    })
                }
            }
        }
    }
    
    func httpPost(url:String) {
        let url:NSURL = NSURL(string:url)!
        let request:NSMutableURLRequest = NSMutableURLRequest(url: url as URL, cachePolicy: NSURLRequest.CachePolicy.reloadIgnoringLocalCacheData, timeoutInterval: 10)
        let semaphore = DispatchSemaphore(value: 0)
        
        request.httpMethod = "POST"
        
        let task = URLSession.shared.dataTask(with: request as URLRequest) {
            data, response, error in
            
            if error != nil
            {
                print("error=\(error)")
                
                let netConnectionAlertView = UIAlertController(title: "網路連線異常", message: "請確認網路已連線，才能繼續進行遊戲喔", preferredStyle: .alert)
                let okAction = UIAlertAction(title: "我知道了", style: .default, handler: nil)
                netConnectionAlertView.addAction(okAction)
                self.present(netConnectionAlertView , animated: true , completion: nil)
            }
            else
            {
                self.responseString = NSString(data: data!, encoding: String.Encoding.utf8.rawValue) as! String
            }
            semaphore.signal()
        }
        task.resume()
        semaphore.wait()
    }
    
    func httpGet(URL:String) {
        
        let request = NSURLRequest(url: NSURL(string: URL)! as URL)
        let urlSession = URLSession.shared
        let semaphore = DispatchSemaphore(value: 0)
        let task = urlSession.dataTask(with: request as URLRequest, completionHandler:{(data, response, error) -> Void in
            
            if let error = error
            {
                print("error = \(error)")
                
                let netConnectionAlertView = UIAlertController(title: "網路連線異常", message: "請確認網路已連線，才能繼續進行遊戲喔", preferredStyle: .alert)
                let okAction = UIAlertAction(title: "我知道了", style: .default, handler: nil)
                netConnectionAlertView.addAction(okAction)
                self.present(netConnectionAlertView , animated: true , completion: nil)
            }
            else
            {
                if URL == "http://140.119.163.40:8080/DarkEmpire/app/ver1.0/userItem/\(self.userid)"
                {
                    self.parseUserWeapon(data:data!)
                }
            }
            semaphore.signal()
        })
        task.resume()
        semaphore.wait()
    }
    
    func parseUserWeapon(data: Data) {
        
        let NSresponseString = NSString(data: data, encoding: String.Encoding.utf8.rawValue)
        let responseString: String = NSresponseString! as String
        let userWeapondata = responseString.data(using: .utf8)!
        
        if let parsedData = try? JSONSerialization.jsonObject(with: userWeapondata) as! [[String: AnyObject]] {
            
            for jsonWeapon in parsedData {
                
                let userWeapon = UserWeapon()
                
                userWeapon.id = jsonWeapon["id"] as! Int
                
                userWeapon.user_id = jsonWeapon["user_id"] as! Int
                
                userWeapon.item_id = jsonWeapon["item_id"] as! Int
                
                userWeapon.quantity = jsonWeapon["quantity"] as! Int
                
                userWeapons.append(userWeapon)
                
                //              userWeaponJson: {"id":3,"user_id":1232436286,"item_id":1,"timestamp":1477887042000}
                //
                //              parsedData: ["id":3,"user_id":1232436286,"item_id":1,"timestamp":1477887042000]
                //
                //              [                       \
                //                  []-->jsonWeapon       \
                //                  []                      weaponInJson
                //                  []                    /
                //              ]                       /
                
            }
        }
    }

}
