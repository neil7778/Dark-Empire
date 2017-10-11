//
//  UserInformationViewController.swift
//  Project
//
//  Created by 劉有容 on 2016/10/17.
//  Copyright © 2016年 Knaz. All rights reserved.
//

import UIKit

class UserInformationViewController: UIViewController {
    
    @IBOutlet weak var userInformationFrameImage: UIImageView!
    @IBOutlet weak var teamLabel: UILabel!
    @IBOutlet weak var useridLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var manaLabel: UILabel!
    @IBOutlet weak var levelLabel: UILabel!
    @IBOutlet weak var chechinLabel: UILabel!
    @IBOutlet weak var purifyLabel: UILabel!
    @IBOutlet weak var updateUserInformationButton: UIButton!
    @IBOutlet weak var forceUserLabel: UILabel!
    @IBOutlet weak var forceImageView: UIImageView!
    
    //button color
    let updateUserInformationButtonColor = UIColor(red: 0.408, green: 0.341, blue: 0.275, alpha: 1.0)
    let updateUserInformationButtonCGColor = UIColor(red: 0.408, green: 0.341, blue: 0.275, alpha: 1.0).cgColor
    
    //user data
    var user = User()
    var userid = UserDefaults.standard.object(forKey: "userid") as! String
    var userInformationJson = UserDefaults.standard.object(forKey: "userInformationJson")
    
    var level = 0
    var getSwitch = 0
    
    //total record
    var totalRecord = TotalRecord()
    
    //force user
    var forceUsers = [ForceUser]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //set button
        MainFunctionViewController().setButtonParameters(button: updateUserInformationButton , UIcolor: updateUserInformationButtonColor, CGColor: updateUserInformationButtonCGColor)
        
        //get user information
        getSwitch = 3
        httpGet(URL: "http://140.119.163.40:8080/DarkEmpire/app/ver1.0/user/\(userid)")
        
        //get total record
        getSwitch = 0
        httpGet(URL: "http://140.119.163.40:8080/DarkEmpire/app/ver1.0/totalRecord/list/\(userid)")
        
        //get user level
        getSwitch = 1
        httpGet(URL: "http://140.119.163.40:8080/DarkEmpire/app/ver1.0/checkLevel/\(userid)")
        
        //get force user
        getSwitch = 2
        httpGet(URL: "http://140.119.163.40:8080/DarkEmpire/app/ver1.0/getForceUser")
        
        if(user.camp == 1)
        {
            teamLabel.text = "安塔雅"
        }
        else if (user.camp == 2)
        {
            teamLabel.text = "席奈"
        }
        useridLabel.text = user.user_name
        emailLabel.text = user.email
        manaLabel.text = String(totalRecord.mana_now)
        levelLabel.text = String(level)
        chechinLabel.text = String(totalRecord.count_checkin)
        purifyLabel.text = String(totalRecord.count_purify)
        
        //force user
        var isForceUser = 0
        for forceUser in forceUsers
        {
            if forceUser.user_id == Int(userid)
            {
                if(forceUser.releaseforce == 0)
                {
                    forceUserLabel.text = "您是超原力使者"
                    //forceUserLabel.textAlignment = .right
                    isForceUser = 1
                    if user.camp == 1
                    {
                        self.forceImageView.image = UIImage(named:"force_red")
                    }
                    else if user.camp == 2
                    {
                        self.forceImageView.image = UIImage(named:"force_blue")
                    }
                }
            }
        }
        if isForceUser == 0
        {
            forceUserLabel.text = "您不是超原力使者"
            //forceUserLabel.textAlignment = .center
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func updateUserInformationButton(_ sender: UIButton) {
        
        let updateAlertView = UIAlertController(title: "變更資料", message: "請輸入您要變更的暱稱及信箱", preferredStyle: .alert)
        updateAlertView.addTextField {
            (usernameTextField: UITextField!) -> Void in
            usernameTextField.text = self.user.user_name
            usernameTextField.placeholder = "暱稱"
        }
        updateAlertView.addTextField {
            (emailTextField: UITextField!) -> Void in
            emailTextField.text = self.user.email
            emailTextField.placeholder = "信箱"
        }
        let cancelAction = UIAlertAction(title: "取消", style: .cancel, handler: nil)
        let okAction = UIAlertAction(title: "確定", style: .default, handler: {
            action in
            self.user.user_name = updateAlertView.textFields!.first!.text! //同let id = updateAlertView.textFields![0]
            self.user.email = updateAlertView.textFields!.last!.text! //同let email = updateAlertView.textFields![1]
            //若暱稱為空值
            if(self.user.user_name.characters.count == 0)
            {
                let usernameAlertView = UIAlertController(title: "注意" , message: "暱稱不可為空白" , preferredStyle: .alert)
                let knowAction = UIAlertAction(title: "我知道了", style: .default, handler: {
                    action in
                    self.present(updateAlertView , animated: true , completion: nil)
                })
                usernameAlertView.addAction(knowAction)
                self.present(usernameAlertView , animated: true , completion: nil)
            }
            //若信箱為空值
            else if (self.user.email.characters.count == 0)
            {
                let emailAlertView = UIAlertController(title: "注意" , message: "信箱不可為空白" , preferredStyle: .alert)
                let knowAction = UIAlertAction(title: "我知道了", style: .default, handler: {
                    action in
                    self.present(updateAlertView , animated: true , completion: nil)
                })
                emailAlertView.addAction(knowAction)
                self.present(emailAlertView , animated: true , completion: nil)
            }
            //暱稱及信箱皆非空值
            else
            {
                self.httpPost(URL:"http://140.119.163.40:8080/DarkEmpire/app/ver1.0/user/\(self.userid)?user_name=\(self.user.user_name)&email=\(self.user.email)")
                self.updateLabelText(label: self.useridLabel, text: self.user.user_name)
                self.updateLabelText(label: self.emailLabel, text: self.user.email)
            }
        })
        updateAlertView.addAction(cancelAction)
        updateAlertView.addAction(okAction)
        self.present(updateAlertView , animated: true , completion: nil)
    }
    
    func httpPost(URL:String) {
        let URL:NSURL = NSURL(string:URL.addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed)!)!
        let jsonUserInformation = ["user_name": user.user_name , "email": user.email] as [String : Any] as [String : Any]
        let request:NSMutableURLRequest = NSMutableURLRequest(url: URL as URL , cachePolicy: NSURLRequest.CachePolicy.reloadIgnoringLocalCacheData, timeoutInterval: 10)
        let semaphore = DispatchSemaphore(value: 0)
        
        request.httpMethod = "POST"
        request.httpBody = try! JSONSerialization.data(withJSONObject: jsonUserInformation , options: [])
        
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
                //print string
                let responseString = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)
                print("responseString = \(responseString)")
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
            
            if let data = data
            {
                if(self.getSwitch == 0)
                {
                    self.parseTotalRecordJson(data: data)
                }
                else if (self.getSwitch == 1)
                {
                    self.parseLevelJson(data:data)
                }
                else if (self.getSwitch == 2)
                {
                    self.parseForceUserJson(data:data)
                }
                else if (self.getSwitch == 3)
                {
                    self.parseJsonData(data:data)
                }
            }
            semaphore.signal()
        })
        task.resume()
        semaphore.wait()
    }
    
    func parseJsonData(data:Data) {
        let NSresponseString = NSString(data: data, encoding: String.Encoding.utf8.rawValue)
        let responseString: String = NSresponseString! as String
        let userInformationData = responseString.data(using: .utf8)!
        
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
    
    func parseTotalRecordJson(data: Data) {
        
        let NSresponseString = NSString(data: data, encoding: String.Encoding.utf8.rawValue)
        let responseString: String = NSresponseString! as String
        let totalRecordData = responseString.data(using: .utf8)!
        
        if let parsedData = try? JSONSerialization.jsonObject(with: totalRecordData) as! [String:Any] {
            
            let recordInJson = [parsedData]
            
            for jsonTotalRecord in recordInJson{
                
                totalRecord.id = jsonTotalRecord["id"] as! Int
                
                totalRecord.user_id = jsonTotalRecord["user_id"] as! Int
                
                totalRecord.mana_now = jsonTotalRecord["mana_now"] as! Int
                
                totalRecord.mana_total = jsonTotalRecord["mana_total"] as! Int
                
                totalRecord.count_checkin = jsonTotalRecord["count_checkin"] as! Int
                    
                totalRecord.count_purify = jsonTotalRecord["count_purify"] as! Int
                
                totalRecord.keeper_times = jsonTotalRecord["keeper_times"] as! Int
                
                totalRecord.other = jsonTotalRecord["other"] as? Int
                
                totalRecord.user_name = jsonTotalRecord["user_name"] as? String
                
            }
        }
    }
    
    func parseLevelJson(data: Data) {
        
        let NSresponseString = NSString(data: data, encoding: String.Encoding.utf8.rawValue)
        let responseString: String = NSresponseString! as String
        let levelData = responseString.data(using: .utf8)!
        
        if let parsedData = try? JSONSerialization.jsonObject(with: levelData) as! [String:Any] {
            let levelString = parsedData["level"] as! String
            level = Int(levelString)!
        }
    }
    
    func parseForceUserJson(data: Data) {
        
        let NSresponseString = NSString(data: data, encoding: String.Encoding.utf8.rawValue)
        let responseString: String = NSresponseString! as String
        let totalForceUser = responseString.data(using: .utf8)!
        
        if let parsedData = try? JSONSerialization.jsonObject(with: totalForceUser) as! [[String:Any]] {
            
            //let forceUserInJson = [parsedData]
            
            for jsonTotalRecord in parsedData{
                
                let forceUser = ForceUser()
                
                forceUser.id = jsonTotalRecord["id"] as! Int
                
                forceUser.user_id = jsonTotalRecord["user_id"] as! Int
                
                forceUser.camp_id = jsonTotalRecord["camp_id"] as! Int
                
                forceUser.releaseforce = jsonTotalRecord["releaseforce"] as! Int
                
                forceUser.now = jsonTotalRecord["now"] as! Int
                
                forceUsers.append(forceUser)
            }
        }
    }

    func updateLabelText (label: UILabel , text: String) {
        DispatchQueue.main.async {
            label.text = "\(text)"
        }
    }
    
    deinit {
        debugPrint("UserInformationView deinitialized")
    }
}
