//
//  SettingViewController.swift
//  Project
//
//  Created by Knaz on 2016/12/22.
//  Copyright © 2016年 Knaz. All rights reserved.
//

import UIKit
import CoreLocation
import AVFoundation


class SettingViewController: UIViewController , UITableViewDataSource, UITableViewDelegate , CLLocationManagerDelegate{

    //user location
    var locationManager :CLLocationManager!
    
    //userid
    var userid = UserDefaults.standard.object(forKey: "userid") as? String
    
    //music
    var musicPlayer: AVAudioPlayer = AVAudioPlayer()
    
    //table view
    @IBOutlet weak var tableView: UITableView!
    
    //button
    @IBOutlet weak var gameIllustrationButton: UIButton!
    let gameIllustrationButtonColor = UIColor(red: 0.408, green: 0.341, blue: 0.275, alpha: 1.0)
    let gameIllustrationButtonCGColor = UIColor(red: 0.408, green: 0.341, blue: 0.275, alpha: 1.0).cgColor
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //set back ground
        let fullScreenSize = UIScreen.main.bounds.size
        let backgroundImageView = UIImageView()
        backgroundImageView.frame.size = CGSize(width: fullScreenSize.width , height: fullScreenSize.height * 1.4)
        backgroundImageView.center = CGPoint(x: fullScreenSize.width * 0.5 , y: fullScreenSize.height * 0.5)
        backgroundImageView.image = UIImage(named: "background.png")
        self.view.insertSubview(backgroundImageView, at:0)
        
        //set button color
        MainFunctionViewController().setButtonParameters(button: gameIllustrationButton , UIcolor: gameIllustrationButtonColor, CGColor: gameIllustrationButtonCGColor)

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
        return 3
    }
    
    //每欄的內容
    func tableView(_ tableView: UITableView,cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if (indexPath.row == 0)
        {
            let cell = tableView.dequeueReusableCell(withIdentifier: "SettingWithSwitchTableViewCell", for: indexPath as IndexPath) as! SettingWithSwitchTableViewCell
            
            //label
            cell.typeLabel.text = "音效"
            
            //switch
            let settingMute:String = UserDefaults.standard.object(forKey: "settingMute") as! String
            if(settingMute == "false")
            {
                cell.mySwitch.isOn = true
            }
            else if(settingMute == "true")
            {
                cell.mySwitch.isOn = false
            }
            
            cell.mySwitch.addTarget(self, action: #selector(switchTriggered), for: .valueChanged)
            cell.mySwitch.tag = indexPath.row
            
            //讓cell不能按
            cell.selectionStyle = UITableViewCellSelectionStyle.none
            
            return cell
        }
        else
        {
            let cell = tableView.dequeueReusableCell(withIdentifier: "SettingWithoutSwitchTableViewCell", for: indexPath as IndexPath) as! SettingWithoutSwitchTableViewCell
            if(indexPath.row == 1)
            {
                cell.typeLabel.text = "查看超原力"
            }
            else if(indexPath.row == 2)
            {
                cell.typeLabel.text = "登出"
            }
            return cell
        }
    }
    
    //按下其中一欄後
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 1
        {
            self.tableView.reloadData()
            performSegue(withIdentifier: "showPuzzleViewingView", sender: self)
        }
        else if (indexPath.row == 2)
        {
            let logoutAlertView = UIAlertController(title: "登出", message: "您確定要登出嗎？", preferredStyle: .alert)
            let cancelAction = UIAlertAction(title: "取消", style: .cancel, handler:
                {
                    action in
                    self.tableView.reloadData()
            })
            let okAction = UIAlertAction(title: "確定", style: .default, handler:
                {
                    action in
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
                        //紀錄使用者位置
                        self.locationManager = CLLocationManager()
                        self.locationManager.delegate = self
                        let latitude = (self.locationManager.location?.coordinate.latitude)!
                        let longitude = (self.locationManager.location?.coordinate.longitude)!
                        self.httpGet(URL: "http://140.119.163.40:8080/DarkEmpire/app/ver1.0/storeAction/\(self.userid!)/9/\(longitude)/\(latitude)/")
                        
                        //刪除User Default的userid
                        UserDefaults.standard.removeObject(forKey: "userid")
                        
                        //跳到 game illustration view
                        let storyboard: UIStoryboard = self.storyboard!
                        let StartPageView = storyboard.instantiateViewController(withIdentifier: "StartPageView") as! StartPageViewController
                        self.present(StartPageView, animated: true, completion: nil)
                        SettingViewController().dismiss(animated: true, completion: nil)
                    }
            })
            logoutAlertView.addAction(cancelAction)
            logoutAlertView.addAction(okAction)
            self.present(logoutAlertView , animated: true , completion: nil)
        }
    }
    
    func switchTriggered(sender: UISwitch)
    {
        if(sender.tag == 0)
        {
            if(sender.isOn == true)
            {
                //開音效
                UserDefaults.standard.set("false", forKey: "settingMute")
                UserDefaults.standard.synchronize()
            }
            else if(sender.isOn == false)
            {
                //關音效
                UserDefaults.standard.set("true", forKey: "settingMute")
                UserDefaults.standard.synchronize()
            }
        }
        else if(sender.tag == 1)
        {
            if(sender.isOn == true)
            {
                //開震動
                UserDefaults.standard.set("true", forKey: "settingVibration")
                UserDefaults.standard.synchronize()
            }
            else if(sender.isOn == false)
            {
                //關震動
                UserDefaults.standard.set("false", forKey: "settingVibration")
                UserDefaults.standard.synchronize()
            }
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
            semaphore.signal()
        })
        task.resume()
        semaphore.wait()
    }
    
    deinit {
        debugPrint("SettingView deinitialized")
    }
}



