//
//  SettingTableViewController.swift
//  Project
//
//  Created by Knaz on 2016/11/3.
//  Copyright © 2016年 Knaz. All rights reserved.
//

import UIKit
import AVFoundation


class SettingTableViewController: UITableViewController {

    //music
    var musicPlayer: AVAudioPlayer = AVAudioPlayer()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //set back ground
        let fullScreenSize = UIScreen.main.bounds.size
        let backgroundImageView = UIImageView()
        backgroundImageView.frame.size = CGSize(width: fullScreenSize.width , height: fullScreenSize.height * 1.4)
        backgroundImageView.center = CGPoint(x: fullScreenSize.width * 0.5 , y: fullScreenSize.height * 0.5)
        backgroundImageView.image = UIImage(named: "background.png")
        self.view.insertSubview(backgroundImageView, at:0)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 3
    }
    
    //每欄的內容
    override func tableView(_ tableView: UITableView,cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if (indexPath.row == 0) || (indexPath.row == 1)
        {
            let cell = tableView.dequeueReusableCell(withIdentifier: "SettingWithSwitchTableViewCell", for: indexPath as IndexPath) as! SettingWithSwitchTableViewCell
            
            if(indexPath.row == 0)
            {
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
            }
            else if(indexPath.row == 1)
            {
                //label
                cell.typeLabel.text = "震動"
                
                //switch
                let settingVibration:String = UserDefaults.standard.object(forKey: "settingVibration") as! String
                if(settingVibration == "true")
                {
                    cell.mySwitch.isOn = true
                }
                else if(settingVibration == "false")
                {
                    cell.mySwitch.isOn = false
                }
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
            cell.typeLabel.text = "登出"
            return cell
        }
    }
    
    //按下其中一欄後
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if (indexPath.row == 2)
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
                //刪除User Default的userid
                UserDefaults.standard.removeObject(forKey: "userid")
                
            
                //跳到 game illustration view
                let storyboard: UIStoryboard = self.storyboard!
                let StartPageView = storyboard.instantiateViewController(withIdentifier: "StartPageView") as! StartPageViewController
                self.present(StartPageView, animated: true, completion: nil)
                SettingTableViewController().dismiss(animated: true, completion: nil)
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
    
    deinit {
        debugPrint("SettingTableView deinitialized")
    }
}
