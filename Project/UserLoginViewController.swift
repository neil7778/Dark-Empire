//
//  UserLoginViewController.swift
//  Project
//
//  Created by 劉有容 on 2016/10/5.
//  Copyright © 2016年 Knaz. All rights reserved.
//

import UIKit
import CoreLocation

class UserLoginViewController: UIViewController , UIWebViewDelegate , CLLocationManagerDelegate{

    @IBOutlet weak var webView: UIWebView!
    
    //user location
    var locationManager :CLLocationManager!
    
    //json data
    var placeJson:String!
    var userInformationJson:String!
    var userWeaponJson:String!
    var weaponJson:String!
    var badgeJson:String!
    var campJson:String!
    var runeStoneJson:String!
    var userRuneJson:String!
    
    //user data
    var user = User()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //跳到登入畫面
        if let url = NSURL(string: "http://140.119.163.40:8080/DarkEmpire/app/login")
        {
            let request = NSURLRequest(url: url as URL)
            webView.delegate = self
            webView.loadRequest(request as URLRequest)
        }
        else
        {
            let netConnectionAlertView = UIAlertController(title: "網路連線異常", message: "請確認網路已連線，才能繼續進行遊戲喔", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "我知道了", style: .default, handler: nil)
            netConnectionAlertView.addAction(okAction)
            self.present(netConnectionAlertView , animated: true , completion: nil)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        UserLoginViewController().dismiss(animated: true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //當每次讀取網址完成時work
    func webViewDidFinishLoad(_ webView: UIWebView) {

        let authenticationURL = webView.request!.url!.absoluteString
        //print("authticationURL: \(authenticationURL)")
        let subAuthenticationURL = (authenticationURL as NSString).substring(to: 54)
        
        if( subAuthenticationURL == "http://140.119.163.40:8080/DarkEmpire/app/authenticate")
        {
            //從抓取回傳頁面的html
            let html = webView.stringByEvaluatingJavaScript(from: "document.documentElement.outerHTML")
            
            //取得userid字串
            let index1 = html!.index((html!.startIndex), offsetBy: 96)
            var tmpSubstring = html!.substring(from: index1)//從index開始讀
            var stringLength = tmpSubstring.characters.count
            var stringLengthMinusOne = tmpSubstring.characters.count - 1
            var index2 = tmpSubstring.index(tmpSubstring.startIndex , offsetBy: stringLength)
            var index3 = tmpSubstring.index(tmpSubstring.startIndex , offsetBy: stringLengthMinusOne)
            var userid = ""
            var lastChar = tmpSubstring.substring(from: index3)
            var finish = 0
            let number = [0,1,2,3,4,5,6,7,8,9]
            var lastCharIsNumber = 0
            
            while(finish != 1)
            {
                if(lastCharIsNumber != 1)
                {
                    stringLength = stringLength - 1
                    stringLengthMinusOne = stringLengthMinusOne - 1
                    index2 = tmpSubstring.index(tmpSubstring.startIndex , offsetBy: stringLength)
                    index3 = tmpSubstring.index(tmpSubstring.startIndex , offsetBy: stringLengthMinusOne)
                    tmpSubstring = tmpSubstring.substring(to: index2)
                    lastChar = tmpSubstring.substring(from: index3)
                    for index in number
                    {
                        if(Int(lastChar) == index)
                        {
                            lastCharIsNumber = 1
                        }
                    }
                }
                else
                {
                    finish = 1
                }
            }
            
            //將userid寫入UserDefault
            userid = tmpSubstring
            UserDefaults.standard.set(userid, forKey: "userid")
            UserDefaults.standard.synchronize()
            print("userid = \(userid)")
            
            //讀建築物資料: placeJson  ,  for : GameMapViewController
            httpGet(URL: "http://140.119.163.40:8080/DarkEmpire/app/ver1.0/place" , json:"placeJson")
            UserDefaults.standard.set(placeJson, forKey: "placeJson")
            UserDefaults.standard.synchronize()
            
            //讀User個人資料: userInformationJson  ,  for : UserInformationViewController
            httpGet(URL: "http://140.119.163.40:8080/DarkEmpire/app/ver1.0/user/\(userid)" , json:"userInformationJson")
            UserDefaults.standard.set(userInformationJson, forKey: "userInformationJson")
            UserDefaults.standard.synchronize()
            parseJsonData(json: userInformationJson as String)
            
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
            httpGet(URL: "http://140.119.163.40:8080/DarkEmpire/app/ver1.0/userRune/\(userid)" , json:"userRuneJson")
            UserDefaults.standard.set(userRuneJson, forKey: "userRuneJson")
            UserDefaults.standard.synchronize()
            
            //檢查後端表格是否都建立了
            httpGet(URL: "http://140.119.163.40:8080/DarkEmpire/app/ver1.0/init/\(userid)" , json: "none")
            
            //取得使用者位置
            if (CLLocationManager.authorizationStatus() != .denied)
            {
                locationManager = CLLocationManager()
                locationManager.delegate = self
                let latitude = (locationManager.location?.coordinate.latitude)!
                let longitude = (locationManager.location?.coordinate.longitude)!
                httpGet(URL: "http://140.119.163.40:8080/DarkEmpire/app/ver1.0/storeAction/\(userid)/8/\(longitude)/\(latitude)/" , json: "none")
            }
            
            if(user.camp == 0)
            {
                //跳到 game illustration view
                let storyboard: UIStoryboard = self.storyboard!
                let chooseTeamView = storyboard.instantiateViewController(withIdentifier: "ChooseTeamView") as! ChooseTeamViewController
                self.present(chooseTeamView, animated: true, completion: nil)
            }
            else
            {
                //跳到 main function view
                let storyboard: UIStoryboard = self.storyboard!
                let navigationController = storyboard.instantiateViewController(withIdentifier: "NavigationController") as! UINavigationController
                self.present(navigationController, animated: true, completion: nil)
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
                print(error)
                
                let netConnectionAlertView = UIAlertController(title: "網路連線異常", message: "請確認網路已連線，才能繼續進行遊戲喔", preferredStyle: .alert)
                let okAction = UIAlertAction(title: "我知道了", style: .default, handler: nil)
                netConnectionAlertView.addAction(okAction)
                self.present(netConnectionAlertView , animated: true , completion: nil)
            }
            else
            {
                let data = data
                
                if(json == "placeJson")
                {
                    self.placeJson = self.returnJsonData(data: data!)
                }
                else if(json == "userInformationJson")
                {
                    self.userInformationJson = self.returnJsonData(data: data!)
                }
                else if(json == "userWeaponJson")
                {
                    self.userWeaponJson = self.returnJsonData(data: data!)
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
            semaphore.signal()
        })
        task.resume()
        semaphore.wait()
    }
    
    func returnJsonData(data : Data)  -> String {
        let NSresponseString = NSString(data: data, encoding: String.Encoding.utf8.rawValue)
        let responseString: String = NSresponseString! as String
        return responseString
    }
    
    func parseJsonData(json:String) {
        
        let userInformationData = json.data(using: .utf8)!
        
        if let parsedData = try? JSONSerialization.jsonObject(with: userInformationData , options:.allowFragments) as! [String:AnyObject] {
            user.id = parsedData["id"] as! Int
            user.user_id = parsedData["user_id"] as! Int
            user.camp = parsedData["camp"] as! Int
            user.email = parsedData["email"] as! String
            user.studentid = parsedData["student_id"] as! String
            user.user_name = parsedData["user_name"] as! String
            user.count = parsedData["count"] as! Int
        }
    }
    
    deinit {
        debugPrint("UserLoginView deinitialized")
    }
}
