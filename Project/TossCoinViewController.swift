//
//  TossCoinViewController.swift
//  Project
//
//  Created by Knaz on 2016/10/20.
//  Copyright © 2016年 Knaz. All rights reserved.
//

import UIKit
import CoreLocation
import GoogleMaps
import AVFoundation

class TossCoinViewController: UIViewController , UITableViewDataSource, UITableViewDelegate , CLLocationManagerDelegate {
    
    @IBOutlet weak var purchaseButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var getCoinButton: UIButton!
    
    //button color
    let findMoneyButtonColor = UIColor(red: 0.408, green: 0.341, blue: 0.275, alpha: 1.0)
    let findMoneyButtonCGColor = UIColor(red: 0.408, green: 0.341, blue: 0.275, alpha: 1.0).cgColor
    
    //user data
    let useridString = UserDefaults.standard.object(forKey: "userid") as! String
    
    //rune stone data
    var runeStones = [RuneStone]()
    var runeStoneJson : String!
    
    //user rune data
    var userRunes = [UserRune]()
    var userRuneJson : String!
    var userid = 0
    var runeid = 0
    var stone = 0
    
    //user location
    var locationManager :CLLocationManager!
    var userLocation:CLLocationCoordinate2D!
    
    //toss coin type and amount
    var coinTossed = [Int]()
    
    //music
    var musicPlayer: AVAudioPlayer!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //set button
        MainFunctionViewController().setButtonParameters(button: getCoinButton , UIcolor: findMoneyButtonColor, CGColor: findMoneyButtonCGColor)
        MainFunctionViewController().setButtonParameters(button: purchaseButton , UIcolor: findMoneyButtonColor, CGColor: findMoneyButtonCGColor)
        
        //set location manager
        locationManager = CLLocationManager()
        locationManager.delegate = self
        
        //set user location
        userLocation = locationManager.location!.coordinate
        
        //讀user rune json
        userRuneJson = UserDefaults.standard.object(forKey: "userRuneJson") as! String
        parseUserRuneJson(json:userRuneJson)
        
        //讀rune stone json
        runeStoneJson = UserDefaults.standard.object(forKey: "runeStoneJson") as! String
        parseRuneStoneJson(json:runeStoneJson)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        locationManager.startUpdatingLocation()
        self.httpGet(URL:"http://140.119.163.40:8080/DarkEmpire/app/ver1.0/userRune/\(self.useridString)")
        tableView.reloadData()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        locationManager.stopUpdatingLocation()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source
    
    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    //總共顯示幾欄項目
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return userRunes.count
    }
    
    //每欄的內容
    func tableView(_ tableView: UITableView,cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "userRune", for: indexPath as IndexPath) as! TossCoinTableViewCell
        
        for runeStone in runeStones
        {
            if(userRunes[indexPath.row].rune_id == runeStone.type)
            {
                cell.moneyTypeImageView.image = UIImage(named: runeStone.name)
                cell.moneyAmountLabel.text = String(userRunes[indexPath.row].stone) + "個"
            }
        }
        return cell
    }
    
    //按下其中一欄後
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        userid = userRunes[indexPath.row].user_id
        runeid = userRunes[indexPath.row].rune_id
        stone = userRunes[indexPath.row].stone
        
        if(stone == 0)
        {
            let noMoneyAlertView = UIAlertController(title: "您現在沒有金幣", message: "請先獲得金幣後再丟棄", preferredStyle: .alert)
            let knowAction = UIAlertAction(title: "我知道了", style: .default, handler:
                {
                    action in
                    self.tableView.reloadData()
            })
            noMoneyAlertView.addAction(knowAction)
            self.present(noMoneyAlertView , animated: true , completion: nil)
        }
        else
        {
            let tossCoinAlertView = UIAlertController(title: "請輸入您要丟棄的金幣數量", message: "您現在有\(stone)個金幣", preferredStyle: .alert)
            
            tossCoinAlertView.addTextField {
                (amountTextField: UITextField!) -> Void in
                amountTextField.placeholder = "請輸入數量"
            }
            
            let cancelAction = UIAlertAction(title: "取消", style: .cancel, handler:
                {
                    action in
                    self.tableView.reloadData()
            })
            let okAction = UIAlertAction(title: "確定", style: .default, handler:
                {
                    action in
                    var tossStoneAmountString = ""
                    var tossStoneAmount = 0
                    tossStoneAmountString = tossCoinAlertView.textFields!.first!.text!
                    
                    //若數量為空值
                    if(tossStoneAmountString.characters.count == 0)
                    {
                        let amountAlertView = UIAlertController(title: "注意" , message: "數量不可為空白" , preferredStyle: .alert)
                        let knowAction = UIAlertAction(title: "我知道了", style: .default, handler: {
                            action in
                            self.present(tossCoinAlertView , animated: true , completion: nil)
                        })
                        amountAlertView.addAction(knowAction)
                        self.present(amountAlertView , animated: true , completion: nil)
                    }
                        
                        //若數量為空值
                    else
                    {
                        //檢查是否有非數字存在
                        let number = ["0","1","2","3","4","5","6","7","8","9"]
                        var isNumber = 0
                        var isNumberCount = 0
                        
                        for char in tossStoneAmountString.characters
                        {
                            for index in 0...9
                            {
                                if (String(char) == number[index])
                                {
                                    isNumberCount = isNumberCount + 1
                                }
                            }
                        }
                        
                        if(isNumberCount == tossStoneAmountString.characters.count)
                        {
                            isNumber = 1
                        }
                        
                        //輸入非數字
                        if(isNumber == 0)
                        {
                            let nonNumberAlertView = UIAlertController(title: "注意" , message: "不可輸入非數字字元" , preferredStyle: .alert)
                            let knowAction = UIAlertAction(title: "我知道了", style: .default, handler: {
                                action in
                                self.present(tossCoinAlertView , animated: true , completion: nil)
                            })
                            nonNumberAlertView.addAction(knowAction)
                            self.present(nonNumberAlertView , animated: true , completion: nil)
                        }
                            
                            //輸入皆數字
                        else
                        {
                            tossStoneAmount = Int(tossCoinAlertView.textFields!.first!.text!)!
                            //數量大於擁有的
                            if(tossStoneAmount > self.stone)
                            {
                                let excessAlertView = UIAlertController(title: "注意" , message: "丟棄數量不可大於擁有數量" , preferredStyle: .alert)
                                let knowAction = UIAlertAction(title: "我知道了", style: .default, handler: {
                                    action in
                                    self.present(tossCoinAlertView , animated: true , completion: nil)
                                })
                                excessAlertView.addAction(knowAction)
                                self.present(excessAlertView , animated: true , completion: nil)
                            }
                                
                                //正常
                            else
                            {
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
                                    //set random number
                                    //drand48() Returns a random double between 0.0 and 1.0
                                    //arc4random_uniform(3) may return 0, 1 or 2 but not 3.
                                    let a:Double = Double(arc4random_uniform(10))
                                    let b:Double = Double(arc4random_uniform(10))
                                    var randomNumber1 = a * 0.00003
                                    var randomNumber2 = b * 0.00003
                                    let dice1 = Int(arc4random_uniform(2))
                                    let dice2 = Int(arc4random_uniform(2))
                                    
                                    if(dice1 == 1)
                                    {
                                        randomNumber1 = -randomNumber1
                                    }
                                    if(dice2 == 1)
                                    {
                                        randomNumber2 = -randomNumber2
                                    }
                                    
                                    self.stone = tossStoneAmount
                                    
                                    //更新table view
                                    
                                    self.httpPost(URL: "http://140.119.163.40:8080/DarkEmpire/app/ver1.0/userRune/throw_rune/\(self.userid)/\(self.runeid)/\(self.stone)/\(self.userLocation.longitude + randomNumber1)/\(self.userLocation.latitude + randomNumber2)/")
                                    
                                    self.httpGet(URL:"http://140.119.163.40:8080/DarkEmpire/app/ver1.0/userRune/\(self.useridString)")
                                    
                                    self.tableView.reloadData()
                                    
                                    let settingMute:String = UserDefaults.standard.object(forKey: "settingMute") as! String
                                    if(settingMute == "false")
                                    {
                                        //播放音效
                                        let path = Bundle.main.path(forResource: "008", ofType:"mp3")!
                                        let url = URL(fileURLWithPath: path)
                                        
                                        do {
                                            let music = try AVAudioPlayer(contentsOf: url)
                                            self.musicPlayer = music
                                            music.prepareToPlay()
                                            music.play()
                                        } catch {
                                            print("can't find file!")
                                        }
                                    }
                                    
                                    //記錄使用者位置
                                    let latitude = (self.locationManager.location?.coordinate.latitude)!
                                    let longitude = (self.locationManager.location?.coordinate.longitude)!
                                    self.httpGet(URL: "http://140.119.163.40:8080/DarkEmpire/app/ver1.0/storeAction/\(self.userid)/4/\(longitude)/\(latitude)/")
                                }
                            }
                        }
                    }
            })
            tossCoinAlertView.addAction(cancelAction)
            tossCoinAlertView.addAction(okAction)
            self.present(tossCoinAlertView , animated: true , completion: nil)
        }
    }
    
    func httpPost(URL:String) {
        let URL:NSURL = NSURL(string:URL)!
        let request:NSMutableURLRequest = NSMutableURLRequest(url: URL as URL, cachePolicy: NSURLRequest.CachePolicy.reloadIgnoringLocalCacheData, timeoutInterval: 10)
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
                if URL == "http://140.119.163.40:8080/DarkEmpire/app/ver1.0/userRune/\(self.useridString)"
                {
                    let data = data
                    self.userRunes = self.parseUserRuneJsonInHttpGet(data: data!)
                    //let responseString = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)
                    //print("responseString = \(responseString!)")
                }
            }
            semaphore.signal()
        })
        task.resume()
        semaphore.wait()
    }
    
    func parseUserRuneJsonInHttpGet (data : Data)  -> [UserRune] {
        var userRunes = [UserRune]()
        
        let NSresponseString = NSString(data: data, encoding: String.Encoding.utf8.rawValue)
        let responseString: String = NSresponseString! as String
        let userRuneData = responseString.data(using: .utf8)!
        
        if let parsedData = try? JSONSerialization.jsonObject(with: userRuneData) as! [[String:Any]] {
            
            var a = 0//第二種金幣目前用不到所以先鎖起來
            
            for jsonUserRune in parsedData{
                
                if a == 0//第二種金幣目前用不到所以先鎖起來
                {
                    let userRune = UserRune()
                    
                    userRune.id = jsonUserRune["id"] as! Int
                    
                    userRune.user_id = jsonUserRune["user_id"] as! Int
                    
                    userRune.rune_id = jsonUserRune["rune_id"] as! Int
                    
                    userRune.stone = jsonUserRune["stone"] as! Int
                    
                    userRunes.append(userRune)
                    
                    a = a + 1//第二種金幣目前用不到所以先鎖起來
                }
            }
        }
        return userRunes
    }
    
    func parseUserRuneJson(json: String) {
        
        let userRuneData = json.data(using: .utf8)!
        
        if let parsedData = try? JSONSerialization.jsonObject(with: userRuneData) as! [[String: AnyObject]] {
            
            for jsonUserRune in parsedData {
                
                    let userRune = UserRune()
                    
                    userRune.id = jsonUserRune["id"] as! Int
                    
                    userRune.user_id = jsonUserRune["user_id"] as! Int
                    
                    userRune.rune_id = jsonUserRune["rune_id"] as! Int
                    
                    userRune.stone = jsonUserRune["stone"] as! Int
                    
                    userRunes.append(userRune)
            }
        }
    }
    
    func parseRuneStoneJson(json: String) {
        
        let runeStoneData = json.data(using: .utf8)!
        
        if let parsedData = try? JSONSerialization.jsonObject(with: runeStoneData) as! [[String: AnyObject]] {
            
            for jsonRuneStone in parsedData {
                
                let runeStone = RuneStone()
                
                runeStone.id = jsonRuneStone["id"] as! Int
                
                runeStone.type = jsonRuneStone["type"] as! Int
                
                runeStone.value = jsonRuneStone["value"] as! Int
                
                runeStone.rune_id = jsonRuneStone["rune_id"] as! Int
                
                runeStone.name = jsonRuneStone["name"] as! String
                
                runeStones.append(runeStone)
            }
        }
    }
    
    @IBAction func getCoinButtonClicked(_ sender: UIButton) {
        
        //定位要開啟才能跳到game view
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
            self.present( alertController, animated: true, completion: nil)
        }
        else
        {
            // 開始定位自身位置
            locationManager.startUpdatingLocation()
            
            let settingMute:String = UserDefaults.standard.object(forKey: "settingMute") as! String
            if(settingMute == "false")
            {
                //播放音效
                let path = Bundle.main.path(forResource: "007", ofType:"mp3")!
                let url = URL(fileURLWithPath: path)
                
                do {
                    let music = try AVAudioPlayer(contentsOf: url)
                    musicPlayer = music
                    music.prepareToPlay()
                    music.play()
                } catch {
                    print("can't find file!")
                }
            }
            
            performSegue(withIdentifier: "showGetCoinView", sender: self)
        }
    }
    
    @IBAction func purchaseButtonClicked(_ sender: UIButton) {
        //定位要開啟才能跳到game view
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
            self.present( alertController, animated: true, completion: nil)
        }
        else
        {
            // 開始定位自身位置
            locationManager.startUpdatingLocation()
            
            let settingMute:String = UserDefaults.standard.object(forKey: "settingMute") as! String
            if(settingMute == "false")
            {
                //播放音效
                let path = Bundle.main.path(forResource: "007", ofType:"mp3")!
                let url = URL(fileURLWithPath: path)
                
                do {
                    let music = try AVAudioPlayer(contentsOf: url)
                    musicPlayer = music
                    music.prepareToPlay()
                    music.play()
                } catch {
                    print("can't find file!")
                }
            }
            performSegue(withIdentifier: "showPurchaseView", sender: self)
        }
    }
    
    
    deinit {
        debugPrint("TossCoinView deinitialized")
    }
}

//注意:從storyboard拉segue時是從aViewcontroller上面的outlet拉到bViewcontroller , 而非拉按鈕

//DispatchQueue.main.async(){
//code
//}


