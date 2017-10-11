//
//  GameViewController.swift
//  Project
//
//  Created by Knaz on 2016/10/31.
//  Copyright © 2016年 Knaz. All rights reserved.
//

import UIKit
import CoreLocation
import AVFoundation


class GameViewController: UIViewController , CLLocationManagerDelegate {

    @IBOutlet weak var placeNameLabel: UILabel!
    @IBOutlet weak var placeImageView: UIImageView!
    @IBOutlet weak var campLabel: UILabel!
    @IBOutlet weak var keeperNameLabel: UILabel!
    @IBOutlet weak var hpLabel: UILabel!
    @IBOutlet weak var manaLabel: UILabel!
    @IBOutlet weak var userWeaponLabel: UILabel!
    @IBOutlet weak var weaponImageView: UIImageView!
    @IBOutlet weak var checkinButton: UIButton!
    @IBOutlet weak var purifyButton: UIButton!
    @IBOutlet weak var progressView: UIProgressView!
    
    //userid
    var userid:String!
    
    //place data
    var placeID : Int!
    var placeName : String!
    var placeState = PlaceState()
    
    //button color
    let ButtonColor = UIColor(red: 0.408, green: 0.341, blue: 0.275, alpha: 1.0)
    let ButtonCGColor = UIColor(red: 0.408, green: 0.341, blue: 0.275, alpha: 1.0).cgColor
    
    //user location
    var locationManager :CLLocationManager!
    var latitude:Double!
    var longitude:Double!
    
    //place location
    var placeLatitude : Double!
    var placeLongitude : Double!
    
    //user weapon
    var userWeapons = [UserWeapon]()
    var userWeaponID = 1
    var userWeaponNum = 0
    var userWeaponJson : String!
    
    //weapon
    var weapons = [Weapon]()
    var weaponJson : String!
    
    //camp
    var camps = [Camp]()
    var campJson : String!
    
    //total record
    var userTotalRecord = TotalRecord()
    var keeperTotalRecord = TotalRecord()
    
    //toast label
    var toastLabel :UILabel!
    var toastLabel2 :UILabel!
    var responseString : NSString!
    
    //music
    var musicPlayer: AVAudioPlayer!
    
    //alertview
    var firstTimeLoginAlertView = UIAlertController()
    let okAction = UIAlertAction(title: "開始遊戲", style: .default, handler: nil)
    let firstUseApp_gameView = UserDefaults.standard.object(forKey: "firstUseApp_gameView") as? String
    
    var choosePotionAlertView = UIAlertController()
    
    //map image
    var mapImageString = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //讀userid
        userid = UserDefaults.standard.object(forKey: "userid") as! String
        
        //讀weapon資料
        weaponJson = UserDefaults.standard.object(forKey: "weaponJson") as! String
        parseWeaponJson(json: weaponJson)
        
        //讀user weapon資料
        httpGet(URL: "http://140.119.163.40:8080/DarkEmpire/app/ver1.0/userItem/\(userid!)")
        
        //讀camp資料
        campJson = UserDefaults.standard.object(forKey: "campJson") as! String
        parseCampJson(json: campJson)
        
        //讀目前佔領狀況
        httpGet(URL: "http://140.119.163.40:8080/DarkEmpire/app/ver1.0/placeState/\(placeID!)")
        
        //讀 user total record
        httpGet(URL: "http://140.119.163.40:8080/DarkEmpire/app/ver1.0/totalRecord/list/\(self.userid!)")
        
        //讀 keeper total record
        httpGet(URL: "http://140.119.163.40:8080/DarkEmpire/app/ver1.0/totalRecord/list/\(self.placeState.keeper_id)")

        //set 佔領者
        for camp in camps
        {
            if(placeState.camp_id == camp.camp_id)
            {
                campLabel.text = "屬於：\(camp.camp_name)"
            }
        }
        
        //set hp
        hpLabel.text = "生命值：\(String(placeState.hp))"
        
        //set place name
        placeNameLabel.text = placeName
        
        //set keeper name
        keeperNameLabel.text = "石碑守護者：\(placeState.keeperName)"

        //set mana
        manaLabel.text = "馬納值：\(String(userTotalRecord.mana_now))"
        
        //set button
        MainFunctionViewController().setButtonParameters(button: checkinButton , UIcolor: ButtonColor, CGColor: ButtonCGColor)
        MainFunctionViewController().setButtonParameters(button: purifyButton , UIcolor: ButtonColor, CGColor: ButtonCGColor)
        
        //set location manager
        locationManager = CLLocationManager()
        locationManager.delegate = self
        latitude = (locationManager.location?.coordinate.latitude)!
        longitude = (locationManager.location?.coordinate.longitude)!
        print("user location:\nlon:\(longitude!)\nlat:\(latitude!)")
        
        //set toast message
        toastLabel = UILabel(frame: CGRect(x:0 , y:0 , width:UIScreen.main.bounds.width * 0.6 , height:UIScreen.main.bounds.height * 0.1))
        toastLabel.center = CGPoint(x: UIScreen.main.bounds.width * 0.5 , y: UIScreen.main.bounds.height * 0.9)
        toastLabel.backgroundColor = UIColor.gray
        toastLabel.textColor = UIColor.white
        toastLabel.textAlignment = NSTextAlignment.center
        
        toastLabel2 = UILabel(frame: CGRect(x:0 , y:0 , width:UIScreen.main.bounds.width * 0.9 , height:UIScreen.main.bounds.height * 0.1))
        toastLabel2.center = CGPoint(x: UIScreen.main.bounds.width * 0.5 , y: UIScreen.main.bounds.height * 0.9)
        toastLabel2.backgroundColor = UIColor.gray
        toastLabel2.textColor = UIColor.white
        toastLabel2.textAlignment = NSTextAlignment.center
        
        //set progress view
        // UIProgressView 的進度條顏色
        progressView.progressTintColor=UIColor.red
        
        // UIProgressView 進度條尚未填滿時底下的顏色
        progressView.trackTintColor=UIColor.gray
        progressView.progress = Float(placeState.hp) / Float(self.placeState.maxHP)
        progressView.transform = progressView.transform.scaledBy(x: 1, y: 5)
        progressView.clipsToBounds = true
        progressView.layer.cornerRadius = 4.0
        
        //set map image
        httpGet(URL: "http://140.119.163.40:8080/GameImg/image/app/\(placeID!)")
        let imageData = NSData(base64Encoded: mapImageString , options: .ignoreUnknownCharacters)
        let image = UIImage(data: imageData as! Data)
        placeImageView.image = image
        
        //set weapon image
        weaponImageView.image = UIImage(named:"potion_gray.png")
        let tapGestureRecognizer = UITapGestureRecognizer(target:self , action:#selector(imageTapped))
        weaponImageView?.isUserInteractionEnabled = true
        weaponImageView?.addGestureRecognizer(tapGestureRecognizer)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        locationManager.startUpdatingLocation()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if(firstUseApp_gameView != "false")
        {
            firstTimeLoginAlertView = UIAlertController(title: "遊戲規則", message: "您點選的是\(placeName!)\n\n選擇「巡邏」增加馬納值來守護神殿\n當不幸神殿守護者是敵方的時候以「淨化」掠取，但是會減少馬納值。\n要注意有秒數限制哦！><\n\n開始吧！勇士！", preferredStyle: .alert)
            firstTimeLoginAlertView.addAction(okAction)
            self.present(firstTimeLoginAlertView , animated: true , completion: nil)
            UserDefaults.standard.set("false", forKey: "firstUseApp_gameView")
            UserDefaults.standard.synchronize()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        locationManager.stopUpdatingLocation()
    }
    
    @IBAction func checkin(_ sender: UIButton) {
        
        //set location manager
        locationManager = CLLocationManager()
        locationManager.delegate = self
        latitude = (locationManager.location?.coordinate.latitude)!
        longitude = (locationManager.location?.coordinate.longitude)!
        
        //求位置差
        let radLat1 = placeLatitude * Double.pi / 180.0
        let radLat2 = latitude * Double.pi / 180.0
        let a = radLat1 - radLat2
        let b = (placeLongitude * Double.pi / 180.0) - (longitude * Double.pi / 180.0)
        var s = 2 * asin(sqrt(pow(sin(a/2),2) + cos(radLat1) * cos(radLat2) * pow(sin(b/2),2)))
        s = s * 6378137//位置差
        
        //距離太遠
        if s < 30
        {
            httpPost(url: "http://140.119.163.40:8080/DarkEmpire/app/ver1.0/checkinPurify/\(userid!)/\(placeID!)/1/\(longitude!)/\(latitude!)/\(userWeaponID)")
            
            //讀目前佔領狀況
            httpGet(URL: "http://140.119.163.40:8080/DarkEmpire/app/ver1.0/placeState/\(placeID!)")
            
            //讀 user total record
            httpGet(URL: "http://140.119.163.40:8080/DarkEmpire/app/ver1.0/totalRecord/list/\(self.userid!)")
            
            let settingMute:String = UserDefaults.standard.object(forKey: "settingMute") as! String
            if responseString == "success"
            {
                if(settingMute == "false")
                {
                    //播放音效
                    let path = Bundle.main.path(forResource: "005 巡邏成功", ofType:"mp3")!
                    let musicURL = URL(fileURLWithPath: path)
                    
                    do {
                        let music = try AVAudioPlayer(contentsOf: musicURL)
                        self.musicPlayer = music
                        music.prepareToPlay()
                        music.play()
                    } catch {
                        print("can't find file!")
                    }
                }
            }
            else if responseString == "false"
            {
                if(settingMute == "false")
                {
                    //播放音效
                    let path = Bundle.main.path(forResource: "006巡邏cool down", ofType:"mp3")!
                    let musicURL = URL(fileURLWithPath: path)
                    
                    do {
                        let music = try AVAudioPlayer(contentsOf: musicURL)
                        self.musicPlayer = music
                        music.prepareToPlay()
                        music.play()
                    } catch {
                        print("can't find file!")
                    }
                }
            }
            
            //set 佔領者
            for camp in camps
            {
                if(self.placeState.camp_id == camp.camp_id)
                {
                    self.campLabel.text = "屬於：\(camp.camp_name)"
                }
            }
            
            //讀 total record
            httpGet(URL: "http://140.119.163.40:8080/DarkEmpire/app/ver1.0/totalRecord/list")
            
            //set hp
            self.hpLabel.text = "生命值：\(String(placeState.hp))"
            
            //set progress view
            self.progressView.progress = Float(placeState.hp) / Float(placeState.maxHP)
            
            //set keeper name
            keeperNameLabel.text = "石碑守護者：\(placeState.keeperName)"
            
            //set mana
            manaLabel.text = "馬納值：\(String(userTotalRecord.mana_now))"
            
            //記錄使用者位置
            httpGet(URL: "http://140.119.163.40:8080/DarkEmpire/app/ver1.0/storeAction/\(userid!)/2/\(longitude!)/\(latitude!)/")
        }
        else
        {
            let distance = Int(abs(s - 29))
            //toast message
            self.view.addSubview(self.toastLabel2)
            //self.toastLabel.text = "Loading Data (\(dataCount)/8)"
            self.toastLabel2.text = "與該地點距離太遠 還要再\(distance)公尺"
            self.toastLabel2.alpha = 1.0
            self.toastLabel2.clipsToBounds = true
            self.toastLabel2.layer.cornerRadius = self.toastLabel2.bounds.size.height * 0.5
            UIView.animate(withDuration: 2.0, delay: 1.0, options: UIViewAnimationOptions.curveEaseOut, animations: {
                self.toastLabel2.alpha = 0.0
            })
        }
    }
    
    @IBAction func purify(_ sender: UIButton) {
        if(placeState.camp_id == 0) || (placeState.camp_id == 3)
        {
            //set location manager
            locationManager = CLLocationManager()
            locationManager.delegate = self
            latitude = (locationManager.location?.coordinate.latitude)!
            longitude = (locationManager.location?.coordinate.longitude)!
            
            //求位置差
            let radLat1 = placeLatitude * Double.pi / 180.0
            let radLat2 = latitude * Double.pi / 180.0
            let a = radLat1 - radLat2
            let b = (placeLongitude * Double.pi / 180.0) - (longitude * Double.pi / 180.0)
            var s = 2 * asin(sqrt(pow(sin(a/2),2) + cos(radLat1) * cos(radLat2) * pow(sin(b/2),2)))
            s = s * 6378137//位置差
            
            //距離太遠
            if s < 30
            {
                httpPost(url: "http://140.119.163.40:8080/DarkEmpire/app/ver1.0/checkinPurify/\(userid!)/\(placeID!)/2/\(longitude!)/\(latitude!)/\(userWeaponID)")
                
                //讀目前佔領狀況
                httpGet(URL: "http://140.119.163.40:8080/DarkEmpire/app/ver1.0/placeState/\(placeID!)")
                
                //讀 user total record
                httpGet(URL: "http://140.119.163.40:8080/DarkEmpire/app/ver1.0/totalRecord/list/\(self.userid!)")
                
                let settingMute:String = UserDefaults.standard.object(forKey: "settingMute") as! String
                if responseString == "success"
                {
                    if(settingMute == "false")
                    {
                        //播放音效
                        let path = Bundle.main.path(forResource: "004", ofType:"mp3")!
                        let musicURL = URL(fileURLWithPath: path)
                        
                        do {
                            let music = try AVAudioPlayer(contentsOf: musicURL)
                            self.musicPlayer = music
                            music.prepareToPlay()
                            music.play()
                        } catch {
                            print("can't find file!")
                        }
                    }
                }
                else if responseString == "false"
                {
                    if(settingMute == "false")
                    {
                        //播放音效
                        let path = Bundle.main.path(forResource: "006巡邏cool down", ofType:"mp3")!
                        let musicURL = URL(fileURLWithPath: path)
                        
                        do {
                            let music = try AVAudioPlayer(contentsOf: musicURL)
                            self.musicPlayer = music
                            music.prepareToPlay()
                            music.play()
                        } catch {
                            print("can't find file!")
                        }
                    }
                }
                
                //set 佔領者
                for camp in camps
                {
                    if(self.placeState.camp_id == camp.camp_id)
                    {
                        self.campLabel.text = "屬於：\(camp.camp_name)"
                    }
                }
                
                //讀 total record
                httpGet(URL: "http://140.119.163.40:8080/DarkEmpire/app/ver1.0/totalRecord/list")
                
                //set hp
                self.hpLabel.text = "生命值：\(String(placeState.hp))"
                
                //set progress view
                self.progressView.progress = Float(placeState.hp) / Float(placeState.maxHP)
                
                //set keeper name
                keeperNameLabel.text = "石碑守護者：\(placeState.keeperName)"
                
                //set mana
                manaLabel.text = "馬納值：\(String(userTotalRecord.mana_now))"
                print(userTotalRecord.mana_now)
                
                //記錄使用者位置
                httpGet(URL: "http://140.119.163.40:8080/DarkEmpire/app/ver1.0/storeAction/\(userid!)/3/\(longitude!)/\(latitude!)/")
            }
            else
            {
                let distance = Int(abs(s - 29))
                //toast message
                self.view.addSubview(self.toastLabel2)
                //self.toastLabel.text = "Loading Data (\(dataCount)/8)"
                self.toastLabel2.text = "與該地點距離太遠 還要再\(distance)公尺"
                self.toastLabel2.alpha = 1.0
                self.toastLabel2.clipsToBounds = true
                self.toastLabel2.layer.cornerRadius = self.toastLabel2.bounds.size.height * 0.5
                UIView.animate(withDuration: 2.0, delay: 1.0, options: UIViewAnimationOptions.curveEaseOut, animations: {
                    self.toastLabel2.alpha = 0.0
                })
            }
        }
        else
        {
            let purifyAlertView = UIAlertController(title: "不能淨化同陣營的據點", message: "不能淨化同陣營的據點", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "我知道了", style: .default, handler: nil)
            purifyAlertView.addAction(okAction)
            self.present(purifyAlertView , animated: true , completion: nil)
        }
    }
    
    func imageTapped(img: AnyObject)
    {
        choosePotionAlertView = UIAlertController(title: "請選擇要使用的聖水", message: "不能淨化同陣營的據點",preferredStyle: .alert)
        let grayPotionAction = UIAlertAction(title: "灰聖水", style: .default, handler: {
            action in
            self.weaponImageView.image = UIImage(named:"potion_gray.png")
            self.userWeaponID = 1
            self.userWeaponLabel.text = ""
        })
        let redPotionAction = UIAlertAction(title: "紅聖水", style: .default, handler: {
            action in
            self.weaponImageView.image = UIImage(named:"potion_red.png")
            self.userWeaponID = 2
            for userWeapon in self.userWeapons
            {
                if userWeapon.item_id == self.userWeaponID
                {
                    self.userWeaponNum = userWeapon.quantity
                }
            }
            self.userWeaponLabel.text = "x\(self.userWeaponNum)"
        })
        let yellowPotionAction = UIAlertAction(title: "黃聖水", style: .default, handler: {
            action in
            self.weaponImageView.image = UIImage(named:"potion_yellow.png")
            self.userWeaponID = 3
            for userWeapon in self.userWeapons
            {
                if userWeapon.item_id == self.userWeaponID
                {
                    self.userWeaponNum = userWeapon.quantity
                }
            }
            self.userWeaponLabel.text = "x\(self.userWeaponNum)"
        })
        let bluePotionAction = UIAlertAction(title: "藍聖水", style: .default, handler: {
            action in
            self.weaponImageView.image = UIImage(named:"potion_blue.png")
            self.userWeaponID = 4
            for userWeapon in self.userWeapons
            {
                if userWeapon.item_id == self.userWeaponID
                {
                    self.userWeaponNum = userWeapon.quantity
                }
            }
            self.userWeaponLabel.text = "x\(self.userWeaponNum)"
        })
        choosePotionAlertView.addAction(grayPotionAction)
        choosePotionAlertView.addAction(redPotionAction)
        choosePotionAlertView.addAction(yellowPotionAction)
        choosePotionAlertView.addAction(bluePotionAction)
        self.present(choosePotionAlertView , animated: true , completion: nil)
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
                self.responseString = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)!
                print(self.responseString)
            }
            semaphore.signal()
        }
        task.resume()
        semaphore.wait()
        
        //淨化or巡邏成功
        if(self.responseString == "success")
        {
            //toast message
            self.view.addSubview(self.toastLabel)
            self.toastLabel.text = "Success !"
            self.toastLabel.alpha = 1.0
            self.toastLabel.clipsToBounds  =  true
            self.toastLabel.layer.cornerRadius = self.toastLabel.bounds.size.height * 0.5
            UIView.animate(withDuration: 1.0, delay: 0.1, options: UIViewAnimationOptions.curveEaseOut, animations: {
                self.toastLabel.alpha = 0.0
            })
            
            //聖水數量標籤更改
            if(userWeaponID == 2) || (userWeaponID == 3) || (userWeaponID == 4)
            {
                let index = userWeaponLabel.text?.index((userWeaponLabel.text?.startIndex)!, offsetBy: 1)
                let numSubString = userWeaponLabel.text?.substring(from: index!)
                userWeaponLabel.text = "x\(String(Int(numSubString!)! - 1))"
            }
        }
        /*
        //巡邏己方陣營成功
        else if(self.responseString == "your team")
        {
            let settingMute:String = UserDefaults.standard.object(forKey: "settingMute") as! String
            if(settingMute == "false")
            {
                //播放音效
                let path = Bundle.main.path(forResource: "005 巡邏成功", ofType:"mp3")!
                let musicURL = URL(fileURLWithPath: path)
                
                do {
                    let music = try AVAudioPlayer(contentsOf: musicURL)
                    self.musicPlayer = music
                    music.prepareToPlay()
                    music.play()
                } catch {
                    print("can't find file!")
                }
            }
            
            //toast message
            self.view.addSubview(self.toastLabel)
            self.toastLabel.text = "checkin success !"
            self.toastLabel.alpha = 1.0
            self.toastLabel.clipsToBounds  =  true
            self.toastLabel.layer.cornerRadius = self.toastLabel.bounds.size.height * 0.5
            UIView.animate(withDuration: 1.0, delay: 0.1, options: UIViewAnimationOptions.curveEaseOut, animations: {
                self.toastLabel.alpha = 0.0
            })
        }
        */  
        //淨化失敗 or 巡邏失敗
        //魔力不足
        else if(self.responseString == "Mana not enough")
        {
            let settingMute:String = UserDefaults.standard.object(forKey: "settingMute") as! String
            if(settingMute == "false")
            {
                //播放音效
                let path = Bundle.main.path(forResource: "006巡邏cool down", ofType:"mp3")!
                let musicURL = URL(fileURLWithPath: path)
                
                do {
                    let music = try AVAudioPlayer(contentsOf: musicURL)
                    self.musicPlayer = music
                    music.prepareToPlay()
                    music.play()
                } catch {
                    print("can't find file!")
                }
            }
            
            //toast message
            self.view.addSubview(self.toastLabel)
            self.toastLabel.text = "Mana not enough !"
            self.toastLabel.alpha = 1.0
            self.toastLabel.clipsToBounds  =  true
            self.toastLabel.layer.cornerRadius = self.toastLabel.bounds.size.height * 0.5
            UIView.animate(withDuration: 1.0, delay: 0.1, options: UIViewAnimationOptions.curveEaseOut, animations: {
                self.toastLabel.alpha = 0.0
            })
        }
            
        //技能冷卻
        else if(self.responseString == "Cool Down")
        {
            let settingMute:String = UserDefaults.standard.object(forKey: "settingMute") as! String
            if(settingMute == "false")
            {
                //播放音效
                let path = Bundle.main.path(forResource: "006巡邏cool down", ofType:"mp3")!
                let musicURL = URL(fileURLWithPath: path)
                
                do {
                    let music = try AVAudioPlayer(contentsOf: musicURL)
                    self.musicPlayer = music
                    music.prepareToPlay()
                    music.play()
                } catch {
                    print("can't find file!")
                }
            }
            
            //toast message
            self.view.addSubview(self.toastLabel)
            self.toastLabel.text = "Cool down !"
            self.toastLabel.alpha = 1.0
            self.toastLabel.clipsToBounds  =  true
            self.toastLabel.layer.cornerRadius = self.toastLabel.bounds.size.height * 0.5
            UIView.animate(withDuration: 1.0, delay: 0.1, options: UIViewAnimationOptions.curveEaseOut, animations: {
                self.toastLabel.alpha = 0.0
            })
        }
            
        //聖水不足
        else if(self.responseString == "Water not enough")
        {
            let settingMute:String = UserDefaults.standard.object(forKey: "settingMute") as! String
            if(settingMute == "false")
            {
                //播放音效
                let path = Bundle.main.path(forResource: "006巡邏cool down", ofType:"mp3")!
                let musicURL = URL(fileURLWithPath: path)
                
                do {
                    let music = try AVAudioPlayer(contentsOf: musicURL)
                    self.musicPlayer = music
                    music.prepareToPlay()
                    music.play()
                } catch {
                    print("can't find file!")
                }
            }
            
            //toast message
            self.view.addSubview(self.toastLabel)
            self.toastLabel.text = "water not enough !"
            self.toastLabel.alpha = 1.0
            self.toastLabel.clipsToBounds  =  true
            self.toastLabel.layer.cornerRadius = self.toastLabel.bounds.size.height * 0.5
            UIView.animate(withDuration: 1.0, delay: 0.1, options: UIViewAnimationOptions.curveEaseOut, animations: {
                self.toastLabel.alpha = 0.0
            })
        }
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
            
            if let data = data
            {
                if(URL == "http://140.119.163.40:8080/DarkEmpire/app/ver1.0/placeState/\(self.placeID!)")
                {
                    self.parsePlaceStateJson(data: data)
                }
                if (URL == "http://140.119.163.40:8080/DarkEmpire/app/ver1.0/totalRecord/list/\(self.userid!)")
                {
                    self.userTotalRecord = self.parseTotalRecord(data: data)
                }
                if (URL == "http://140.119.163.40:8080/DarkEmpire/app/ver1.0/totalRecord/list/\(self.placeState.keeper_id)")
                {
                    self.keeperTotalRecord = self.parseTotalRecord(data: data)
                }
                if (URL == "http://140.119.163.40:8080/GameImg/image/app/\(self.placeID!)")
                {
                    self.parseMapImage(data:data)
                }
                if (URL == "http://140.119.163.40:8080/DarkEmpire/app/ver1.0/userItem/\(self.userid!)")
                {
                    self.parseUserWeapon(data:data)
                }
            }
            semaphore.signal()
        })
        task.resume()
        semaphore.wait()
    }
    
    func parsePlaceStateJson(data: Data) {
        
        let NSresponseString = NSString(data: data, encoding: String.Encoding.utf8.rawValue)
        let responseString: String = NSresponseString! as String
        let placeStateData = responseString.data(using: .utf8)!
        
        if let parsedData = try? JSONSerialization.jsonObject(with: placeStateData) as! [String: AnyObject] {
            
            let placeStateInJson = [parsedData]
            
            for jsonPlaceState in placeStateInJson
            {
                placeState.id = jsonPlaceState["id"] as! Int
                
                placeState.camp_id = jsonPlaceState["camp_id"] as! Int
                
                placeState.place_id = jsonPlaceState["place_id"] as! Int
                
                placeState.keeper_id = jsonPlaceState["keeper_id"] as! Int
                
                placeState.keeperName = jsonPlaceState["keeperName"] as! String
                
                placeState.hp = jsonPlaceState["hp"] as! Int
                
                placeState.maxHP = jsonPlaceState["maxHp"] as! Int
            }
        }
    }
    
    func parseTotalRecord(data: Data) -> TotalRecord {
        
        let NSresponseString = NSString(data: data, encoding: String.Encoding.utf8.rawValue)
        let responseString: String = NSresponseString! as String
        let totalRecordData = responseString.data(using: .utf8)!
        
        let totalRecord = TotalRecord()
        
        if let parsedData = try? JSONSerialization.jsonObject(with: totalRecordData) as! [String:Any] {
            
            let totalRecordJson = [parsedData]
            
            for jsonTotalRecord in totalRecordJson{
                                
                totalRecord.id = jsonTotalRecord["id"] as! Int
                
                totalRecord.user_id = jsonTotalRecord["user_id"] as! Int
                
                totalRecord.mana_now = jsonTotalRecord["mana_now"] as! Int
                
                totalRecord.mana_total = jsonTotalRecord["mana_total"] as! Int
                
                totalRecord.count_checkin = jsonTotalRecord["count_checkin"] as! Int
                
                totalRecord.count_purify = jsonTotalRecord["count_purify"] as! Int
                
                totalRecord.other = jsonTotalRecord["other"] as? Int
                
                totalRecord.user_name = jsonTotalRecord["user_name"] as? String

            }
        }
        return totalRecord
    }
    
    func parseMapImage(data: Data) {
        
        let NSresponseString = NSString(data: data, encoding: String.Encoding.utf8.rawValue)
        mapImageString = NSresponseString! as String
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
    
    func parseWeaponJson(json: String) {
        
        let weapondata = json.data(using: .utf8)!
        
        if let parsedData = try? JSONSerialization.jsonObject(with: weapondata) as! [[String: AnyObject]] {
            
            for jsonWeapon in parsedData {
                
                let weapon = Weapon()
                
                weapon.id = jsonWeapon["id"] as! Int
                
                weapon.atk = jsonWeapon["atk"] as! Int

                weapon.mana = jsonWeapon["mana"] as! Int

                weapon.item_id = jsonWeapon["item_id"] as! Int

                weapon.name = jsonWeapon["name"] as! String
                
                weapons.append(weapon)
            }
        }
    }
    
    func parseCampJson(json: String) {
        
        let campdata = campJson.data(using: .utf8)!

        if let parsedData = try? JSONSerialization.jsonObject(with: campdata) as! [[String: AnyObject]] {
            for jsonCamp in parsedData {
                
                let camp = Camp()
                
                camp.id = jsonCamp["id"] as! Int
                
                camp.camp_id = jsonCamp["camp_id"] as! Int
                
                camp.camp_name = jsonCamp["camp_name"] as! String
                
                camps.append(camp)
            }
        }
    }
    
    deinit {
        debugPrint("GameView deinitialized")
    }
}
