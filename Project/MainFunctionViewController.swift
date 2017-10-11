//
//  MainFunctionViewController.swift
//  Project
//
//  Created by 劉有容 on 2016/10/14.
//  Copyright © 2016年 Knaz. All rights reserved.
//
import UIKit
import CoreLocation
import AVFoundation

class MainFunctionViewController: UIViewController , CLLocationManagerDelegate {
    
    @IBOutlet weak var gameStartButton: UIButton!
    @IBOutlet weak var earnMoneyButton: UIButton!
    @IBOutlet weak var showUserInformationButton: UIButton!
    @IBOutlet weak var storyButton: UIButton!
    @IBOutlet weak var achievementButton: UIButton!
    @IBOutlet weak var communicationBUtton: UIButton!
    @IBOutlet weak var settingButton: UIButton!
    
    //button colors
    let gameStartButtonColor = UIColor(red: 0.8, green: 0.306, blue: 0.035, alpha: 1.0)
    let gameStartButtonCGColor = UIColor(red: 0.8, green: 0.306, blue: 0.035, alpha: 1.0).cgColor
    
    let earnMoneyButtonColor = UIColor(red: 0.949, green: 0.69, blue: 0.129, alpha: 1.0)
    let earnMoneyButtonCGColor = UIColor(red: 0.949, green: 0.69, blue: 0.129, alpha: 1.0).cgColor
    
    let showUserInformationButtonColor = UIColor(red: 0.553, green: 0.412, blue: 0.243, alpha: 1.0)
    let showUserInformationButtonCGColor = UIColor(red: 0.553, green: 0.412, blue: 0.243, alpha: 1.0).cgColor
    
    let storyButtonColor = UIColor(red: 0.714, green: 0.416, blue: 0.169, alpha: 1.0)
    let storyButtonCGColor = UIColor(red: 0.714, green: 0.416, blue: 0.169, alpha: 1.0).cgColor
    
    let achievementButtonColor = UIColor(red: 0.376, green: 0.231, blue: 0.133, alpha: 1.0)
    let achievementButtonCGColor = UIColor(red: 0.376, green: 0.231, blue: 0.133, alpha: 1.0).cgColor
    
    let communicationBUttonColor = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 1.0)
    let communicationBUttonCGColor = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 1.0).cgColor
    
    let gradientColor = UIColor(red: 0.949, green: 0.906, blue: 0.808, alpha: 1.0)
    let gradientCGColor = UIColor(red: 0.949, green: 0.906, blue: 0.808, alpha: 1.0).cgColor
    
    //user location
    var locationManager :CLLocationManager!
    
    //music
    var musicPlayer: AVAudioPlayer!
    
    //internet
    var InternetIsOn = 1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //set buttons
        setButtonParameters(button: gameStartButton , UIcolor: gameStartButtonColor , CGColor: gameStartButtonCGColor)
        setButtonParameters(button: showUserInformationButton , UIcolor: showUserInformationButtonColor, CGColor: showUserInformationButtonCGColor)
        setButtonParameters(button: earnMoneyButton , UIcolor: earnMoneyButtonColor, CGColor: earnMoneyButtonCGColor)
        setButtonParameters(button: storyButton , UIcolor: storyButtonColor, CGColor: storyButtonCGColor)
        setButtonParameters(button: achievementButton , UIcolor: achievementButtonColor, CGColor: achievementButtonCGColor)
        setButtonParameters(button: communicationBUtton , UIcolor: communicationBUttonColor, CGColor: communicationBUttonCGColor)
        
        //set location manager
        locationManager = CLLocationManager()
        locationManager.delegate = self
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        _ = MainFunctionViewController().navigationController?.popViewController(animated: true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func buttonClicked(_ sender: UIButton) {
        //button pressed color
        sender.backgroundColor = UIColor(red: 0.282, green: 0.204, blue: 0.165, alpha: 1.0)
        
        let settingMute:String = UserDefaults.standard.object(forKey: "settingMute") as! String
        if(settingMute == "false")
        {
            //播放音效
            let path = Bundle.main.path(forResource: "002六按鍵音效", ofType:"mp3")!
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
    }
    
    @IBAction func buttonReleased(_ sender: UIButton) {
        switch sender {
            case gameStartButton :
                sender.backgroundColor = gameStartButtonColor
                
                //定位要開啟才能跳到game map view
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
                    //測試有無網路
                    httpGet(URL: "http://140.119.163.40:8080/DarkEmpire/app/ver1.0/place")
                    if InternetIsOn == 1
                    {
                        performSegue(withIdentifier: "showGameView", sender: self)
                    }
                }
            
            case earnMoneyButton :
                sender.backgroundColor = earnMoneyButtonColor
                
                //定位要開啟才能跳到game map view
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
                    //測試有無網路
                    httpGet(URL: "http://140.119.163.40:8080/DarkEmpire/app/ver1.0/place")
                    if InternetIsOn == 1
                    {
                        performSegue(withIdentifier: "showTossCoinView", sender: self)
                    }
                }
            
            case showUserInformationButton :
                sender.backgroundColor = showUserInformationButtonColor
                //測試有無網路
                httpGet(URL: "http://140.119.163.40:8080/DarkEmpire/app/ver1.0/place")
                if InternetIsOn == 1
                {
                    performSegue(withIdentifier: "showUserInformationView", sender: self)
                }
            
            case storyButton :
                sender.backgroundColor = storyButtonColor
                performSegue(withIdentifier: "showStoryView", sender: self)
            
            case achievementButton :
                sender.backgroundColor = achievementButtonColor
                //測試有無網路
                httpGet(URL: "http://140.119.163.40:8080/DarkEmpire/app/ver1.0/place")
                if InternetIsOn == 1
                {
                    performSegue(withIdentifier: "showAchievementView", sender: self)
                }
            
            case communicationBUtton :
                sender.backgroundColor = communicationBUttonColor
                //測試有無網路
                httpGet(URL: "http://140.119.163.40:8080/DarkEmpire/app/ver1.0/place")
                if InternetIsOn == 1
                {
                    performSegue(withIdentifier: "showCommunicationView", sender: self)
                }
            
            case settingButton :
                sender.backgroundColor = sender.backgroundColor
                performSegue(withIdentifier: "showSettingTableView", sender: self)
            
            default:
                sender.backgroundColor = sender.backgroundColor
        }
    }
    
    func setButtonParameters(button: UIButton , UIcolor: UIColor , CGColor: CGColor)
    {
        //button shape
        if(UIcolor == UserInformationViewController().updateUserInformationButtonColor) || (UIcolor == TossCoinViewController().findMoneyButtonColor) || (UIcolor == GameViewController().ButtonColor)
        {
            button.layer.cornerRadius = button.bounds.size.width * 0.3
            button.clipsToBounds = true
        }
        else
        {
            button.layer.cornerRadius = button.bounds.size.width * 0.5
            button.clipsToBounds = true
        }
        
        //button color
        button.backgroundColor = UIcolor
        
        //button border
        button.layer.borderWidth = 2
        button.layer.borderColor = CGColor
        
        /*
        //button gradient
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = button.bounds
        gradientLayer.colors = [CGColor , gradientCGColor]
        gradientLayer.locations = [0.85, 1.0]
        button.layer.addSublayer(gradientLayer)
        */
        
    }
    
    func httpGet(URL:String) {
        
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
                self.InternetIsOn = 1
            }
            semaphore.signal()
        })
        task.resume()
        semaphore.wait()
    }
    
    deinit {
        debugPrint("MainFunctionView deinitialized")
    }
}
