//
//  StartPageViewController.swift
//  Project
//
//  Created by 劉有容 on 2016/10/12.
//  Copyright © 2016年 Knaz. All rights reserved.
//

import UIKit
import CoreLocation
import AVFoundation

class StartPageViewController: UIViewController , CLLocationManagerDelegate{
    
    @IBOutlet weak var firstcoinImage: UIImageView!
    @IBOutlet weak var backgroundImage: UIImageView!
    
    @IBOutlet weak var label: UILabel!
    
    //user location
    var locationManager :CLLocationManager!
    
    //json data
    var placeJson:String!
    var userInformationJson:String!
    var weaponJson:String!
    var badgeJson:String!
    var campJson:String!
    var runeStoneJson:String!
    var userRuneJson:String!
    
    //讀user setting
    let settingMute:String? = UserDefaults.standard.object(forKey: "settingMute") as! String?
    let settingVibration:String? = UserDefaults.standard.object(forKey: "settingVibration") as! String?
    
    //background music
    var musicPlayer: AVAudioPlayer!
    
    //toast label
    var toastLabel: UILabel!
    var dataCount = 1
    
    //檢察網路是否已開啟
    var InternetIsOn = 1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //label
        label.adjustsFontSizeToFitWidth=true
        
        //set user location
        // 建立一個 CLLocationManager
        locationManager = CLLocationManager()
        
        // 設置委任對象
        locationManager.delegate = self
        
        // 距離篩選器 用來設置移動多遠距離才觸發委任方法更新位置
        //        locationManager.distanceFilter = kCLLocationAccuracyBestForNavigation
        
        // 取得自身定位位置的精確度
        //        locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        
        // 首次使用 向使用者詢問定位自身位置權限
        if CLLocationManager.authorizationStatus() == .notDetermined {
            // 取得定位服務授權
            locationManager.requestWhenInUseAuthorization()
        }
        
        if(settingMute == nil) || (settingMute == "false")
        {
            //播放音效
            let path = Bundle.main.path(forResource: "001暗黑帝國主畫面", ofType:"mp3")!
            let url = URL(fileURLWithPath: path)
            
            do {
                let music = try AVAudioPlayer(contentsOf: url)
                musicPlayer = music
                music.numberOfLoops = -1
                music.prepareToPlay()
                music.play()
            } catch {
                print("can't find file!")
            }
        }
        
        //set:觸碰image並換頁
        let imageView = backgroundImage
        let tapGestureRecognizer = UITapGestureRecognizer(target:self , action:#selector(imageTapped))
        imageView?.isUserInteractionEnabled = true
        imageView?.addGestureRecognizer(tapGestureRecognizer)
        
        //set toast message
        toastLabel = UILabel(frame: CGRect(x:0 , y:0 , width:UIScreen.main.bounds.width * 0.6 , height:UIScreen.main.bounds.height * 0.1))
        toastLabel.center = CGPoint(x: UIScreen.main.bounds.width * 0.5 , y: UIScreen.main.bounds.height * 0.9)
        toastLabel.backgroundColor = UIColor.gray
        toastLabel.textColor = UIColor.white
        toastLabel.textAlignment = NSTextAlignment.center
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if musicPlayer != nil {
            musicPlayer.stop()
            musicPlayer = nil
        }
        StartPageViewController().dismiss(animated: true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func imageTapped(img: AnyObject)
    {
        if (CLLocationManager.authorizationStatus() == .denied)
        {
            // 提示可至[設定]中開啟權限
            let alertController = UIAlertController(
                title: "定位權限已關閉",
                message: "請先開啟定位使用權限，才能繼續進行遊戲喔",
                preferredStyle: .alert)
            let okAction = UIAlertAction(
                title: "確認", style: .default, handler:nil)
            alertController.addAction(okAction)
            self.present(alertController, animated: true, completion: nil)
        }
        else
        {
            //讀userid
            let userid:String? = UserDefaults.standard.object(forKey: "userid") as! String?
            
            //為了檢查網路有沒有連上，所以拉出來讀
            //讀建築物資料: placeJson  ,  for : GameMapViewController
            httpGet(URL: "http://140.119.163.40:8080/DarkEmpire/app/ver1.0/place" , json:"placeJson")
            UserDefaults.standard.set(placeJson, forKey: "placeJson")
            UserDefaults.standard.synchronize()
            
            //userid 存在
            if(userid != nil)
            {
                //預設聲音及振動打開
                UserDefaults.standard.set("false", forKey: "settingMute")
                UserDefaults.standard.set("true", forKey: "settingVibration")
                UserDefaults.standard.synchronize()
                
                print("userid = \(userid!)")
                
                //讀User個人資料: userInformationJson  ,  for : UserInformationViewController
                httpGet(URL: "http://140.119.163.40:8080/DarkEmpire/app/ver1.0/user/\(userid!)" , json:"userInformationJson")
                UserDefaults.standard.set(userInformationJson, forKey: "userInformationJson")
                UserDefaults.standard.synchronize()
                
                //讀武器資料: weaponJson  ,  for : GameViewController
                httpGet(URL: "http://140.119.163.40:8080/DarkEmpire/app/ver1.0/item/list" , json:"weaponJson")
                UserDefaults.standard.set(weaponJson, forKey: "weaponJson")
                UserDefaults.standard.synchronize()
                
                //讀徽章資料: badgeJson  ,  for : AchievementViewController
                httpGet(URL: "http://140.119.163.40:8080/DarkEmpire/app/ver1.0/badge/list" , json:"badgeJson")
                UserDefaults.standard.set(badgeJson, forKey: "badgeJson")
                UserDefaults.standard.synchronize()
                
                //讀陣營資料: campJson  ,  for : GameMapViewController
                httpGet(URL: "http://140.119.163.40:8080/DarkEmpire/app/ver1.0/camp/list" , json:"campJson")
                UserDefaults.standard.set(campJson, forKey: "campJson")
                UserDefaults.standard.synchronize()
                
                //讀硬幣種類資料: runeStoneJson  ,  for : TossCoinViewController
                httpGet(URL: "http://140.119.163.40:8080/DarkEmpire/app/ver1.0/runeStone/list" , json:"runeStoneJson")
                UserDefaults.standard.set(runeStoneJson, forKey: "runeStoneJson")
                UserDefaults.standard.synchronize()
                
                //讀user硬幣資料: userRuneJson  ,  for : TossCoinViewController
                httpGet(URL: "http://140.119.163.40:8080/DarkEmpire/app/ver1.0/userRune/\(userid!)" , json:"userRuneJson")
                UserDefaults.standard.set(userRuneJson, forKey: "userRuneJson")
                UserDefaults.standard.synchronize()
                
                //檢查後端表格是否都建立了
                httpGet(URL: "http://140.119.163.40:8080/DarkEmpire/app/ver1.0/init/\(userid!)" , json: "none")
                
                //取得使用者位置
                if (CLLocationManager.authorizationStatus() != .denied)
                {
                    locationManager = CLLocationManager()
                    locationManager.delegate = self
                    let latitude = (locationManager.location?.coordinate.latitude)!
                    let longitude = (locationManager.location?.coordinate.longitude)!
                    httpGet(URL: "http://140.119.163.40:8080/DarkEmpire/app/ver1.0/storeAction/\(userid!)/1/\(longitude)/\(latitude)/" , json: "none")
                }
                
                if InternetIsOn == 1
                {
                    let userCampID = parseJsonData(json: userInformationJson!)
                    if(userCampID != 0)
                    {
                        //跳到 main function view
                        let storyboard: UIStoryboard = self.storyboard!
                        let navigationController = storyboard.instantiateViewController(withIdentifier: "NavigationController") as! UINavigationController
                        self.present(navigationController, animated: true, completion: nil)
                    }
                    else
                    {
                        //跳到 user login view
                        let storyboard: UIStoryboard = self.storyboard!
                        let userLoginView = storyboard.instantiateViewController(withIdentifier: "UserLoginView") as! UserLoginViewController
                        self.present(userLoginView, animated: true, completion: nil)
                    }
                }
                else
                {
                    InternetIsOn = 1
                    dataCount = 1
                }
            }
                //userid 不存在
            else
            {
                //跳到 user login view
                let storyboard: UIStoryboard = self.storyboard!
                let userLoginView = storyboard.instantiateViewController(withIdentifier: "UserLoginView") as! UserLoginViewController
                self.present(userLoginView, animated: true, completion: nil)
                
                //預設聲音及振動打開
                UserDefaults.standard.set("false", forKey: "settingMute")
                UserDefaults.standard.set("true", forKey: "settingVibration")
                UserDefaults.standard.synchronize()
            }
        }
    }
    
    func httpGet(URL:String , json:String) {
        
        let request = NSURLRequest(url: NSURL(string: URL)! as URL)
        let urlSession = URLSession.shared
        let semaphore = DispatchSemaphore(value: 0)
        let task = urlSession.dataTask(with: request as URLRequest, completionHandler:{(data, response, error) -> Void in
            
            if let error = error
            {
                self.InternetIsOn = 0
                print(error)
                
                let netConnectionAlertView = UIAlertController(title: "網路連線異常", message: "請確認網路已連線，才能繼續進行遊戲喔", preferredStyle: .alert)
                let okAction = UIAlertAction(title: "我知道了", style: .default, handler: nil)
                netConnectionAlertView.addAction(okAction)
                self.present(netConnectionAlertView , animated: true , completion: nil)
            }
                
            else
            {
                let data = data
                
                //處理連上Wireless但還未輸入帳密時，會有data而沒有error的bug
                if NSString(data: data!, encoding: String.Encoding.utf8.rawValue) != nil
                {
                    if(json == "placeJson")
                    {
                        self.placeJson = self.returnJsonData(data: data!)
                    }
                    else if(json == "userInformationJson")
                    {
                        self.userInformationJson = self.returnJsonData(data: data!)
                    }
                    else if(json == "weaponJson")
                    {
                        self.weaponJson = self.returnJsonData(data: data!)
                    }
                    else if(json == "badgeJson")
                    {
                        self.badgeJson = self.returnJsonData(data: data!)
                    }
                    else if(json == "campJson")
                    {
                        self.campJson = self.returnJsonData(data: data!)
                    }
                    else if(json == "runeStoneJson")
                    {
                        self.runeStoneJson = self.returnJsonData(data: data!)
                    }
                    else if(json == "userRuneJson")
                    {
                        self.userRuneJson = self.returnJsonData(data: data!)
                    }
                }
                    
                else
                {
                    self.InternetIsOn = 0
                    let netConnectionAlertView = UIAlertController(title: "網路連線異常", message: "請確認網路已連線，才能繼續進行遊戲喔", preferredStyle: .alert)
                    let okAction = UIAlertAction(title: "我知道了", style: .default, handler: nil)
                    netConnectionAlertView.addAction(okAction)
                    self.present(netConnectionAlertView , animated: true , completion: nil)
                }
            }
            semaphore.signal()
        })
        task.resume()
        semaphore.wait()
        
        //toast message
        self.view.addSubview(self.toastLabel)
        //self.toastLabel.text = "Loading Data (\(dataCount)/8)"
        self.toastLabel.text = "讀取資料中"
        self.toastLabel.alpha = 1.0
        self.toastLabel.clipsToBounds  =  true
        self.toastLabel.layer.cornerRadius = self.toastLabel.bounds.size.height * 0.5
        UIView.animate(withDuration: 1.0, delay: 0.1, options: UIViewAnimationOptions.curveEaseOut, animations: {
            self.toastLabel.alpha = 0.0
        })
        
        dataCount = dataCount + 1
    }
    
    func returnJsonData(data : Data)  -> String {
        let NSresponseString = NSString(data: data, encoding: String.Encoding.utf8.rawValue)
        let responseString: String = NSresponseString! as String
        return responseString
    }
    
    func parseJsonData(json:String) -> Int {
        
        let userInformationData = json.data(using: .utf8)!
        var userCampID:Int!
        
        if let parsedData = try? JSONSerialization.jsonObject(with: userInformationData , options:.allowFragments) as! [String:AnyObject] {
            userCampID  = parsedData["camp"] as! Int
        }
        return userCampID
    }
    
    deinit {
        debugPrint("StartPageView deinitialized")
    }
}

