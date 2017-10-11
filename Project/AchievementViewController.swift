//
//  AchievementViewController.swift
//  Project
//
//  Created by Knaz on 2016/10/30.
//  Copyright © 2016年 Knaz. All rights reserved.
//

import UIKit
import AVFoundation

class AchievementViewController: UIViewController , UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var mySegmentedControl: UISegmentedControl!
    
    //badge
    var badges = [Badge]()
    var selectedBadges = [Badge]()
    var userBadges = [Int]()
    
    //classification
    var classifications = [String]()
    
    //現在使用者選到的title
    var currentTitle = ""
    
    //badge json
    var badgeJson : String!
    
    //music
    var musicPlayer: AVAudioPlayer!
    
    //userid
    var userid : String!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //讀badge json 
        badgeJson = UserDefaults.standard.object(forKey: "badgeJson") as! String
        parseBadgeJson(json: badgeJson)
        
        //讀userid
        userid = UserDefaults.standard.object(forKey: "userid") as! String
        
        //get user badge
        httpGet(URL:"http://140.119.163.40:8080/DarkEmpire/app/ver1.0/userBadge/\(userid!)")
        
        //get badge type
        httpGet(URL:"http://140.119.163.40:8080/DarkEmpire/app/ver1.0/badgeType")

        //set segmented control
//        let mySegmentedControl = UISegmentedControl(items: classifications)
        
        // 設置外觀顏色 預設為藍色
        mySegmentedControl.tintColor = UIColor.gray
        
        // 設置底色 沒有預設的顏色
        mySegmentedControl.backgroundColor = UIColor.white
        
        // 設置預設選擇的選項
        // 從 0 開始算起 所以這邊設置為第一個選項
        mySegmentedControl.selectedSegmentIndex = 0
        currentTitle = mySegmentedControl.titleForSegment(at: 0)!
        
        // 設置切換選項時執行的動作
        mySegmentedControl.addTarget(
            self,action:
            #selector(changeTitle),for: .valueChanged)
        
        // 初始化表格內容
        for badge in badges
        {
            if(badge.badge_type == currentTitle)
            {
                selectedBadges.append(badge)
            }
        }
        
        // 設置尺寸及位置並放入畫面中
//        let fullScreenSize = UIScreen.main.bounds.size
//        mySegmentedControl.frame.size = CGSize(width: fullScreenSize.width , height: fullScreenSize.height * 0.1)
//        mySegmentedControl.center = CGPoint(x: fullScreenSize.width * 0.5 , y: fullScreenSize.height * 0.16)
//        self.view.addSubview(mySegmentedControl)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // 切換選項時執行動作的方法
    func changeTitle(_ sender: UISegmentedControl) {
        currentTitle = sender.titleForSegment(at:sender.selectedSegmentIndex)!
        print(currentTitle)
        selectedBadges.removeAll()
        for badge in badges
        {
            if(badge.badge_type == currentTitle)
            {
                selectedBadges.append(badge)
            }
        }
        
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
        self.tableView.reloadData()
    }
    
    // MARK: - Table view data source
    
    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    //總共顯示幾欄項目
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        var count = 0
        for badge in badges
        {
            if(badge.badge_type == currentTitle)
            {
                count = count + 1
            }
        }
        return count
    }
    
    //每欄的內容
    func tableView(_ tableView: UITableView,cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Badge", for: indexPath as IndexPath) as! BadgeTableViewCell

        if(selectedBadges[indexPath.row].badge_type == "專家")
        {
            var isEmpty = 0
            for userBadge in userBadges
            {
                if (selectedBadges[indexPath.row].badge_id == userBadge)
                {
                    isEmpty = 1
                }
            }
            if(isEmpty == 1)
            {
                cell.badgeTypeImageView.image = UIImage(named: "achievement_Expert")
            }
            else
            {
                cell.badgeTypeImageView.image = UIImage(named: "achievement_Empty.png")
            }
        }
        else if(selectedBadges[indexPath.row].badge_type == "校園尋奇")
        {
            var isEmpty = 0
            for userBadge in userBadges
            {
                if (selectedBadges[indexPath.row].badge_id == userBadge)
                {
                    isEmpty = 1
                }
            }
            if(isEmpty == 1)
            {
                cell.badgeTypeImageView.image = UIImage(named: "achievement_campus1")
            }
            else
            {
                cell.badgeTypeImageView.image = UIImage(named: "achievement_Empty.png")
            }
        }
        else
        {
            var isEmpty = 0
            for userBadge in userBadges
            {
                if (selectedBadges[indexPath.row].badge_id == userBadge)
                {
                    isEmpty = 1
                }
            }
            if(isEmpty == 1)
            {
                cell.badgeTypeImageView.image = UIImage(named: "achievement_Explore")
            }
            else
            {
                cell.badgeTypeImageView.image = UIImage(named: "achievement_Empty.png")
            }
        }
        cell.badgeNameLabel.text = String(selectedBadges[indexPath.row].name)
        
        return cell
    }
    
    //按下其中一欄後
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let descriptionAlertView = UIAlertController(title: selectedBadges[indexPath.row].name, message: selectedBadges[indexPath.row].description, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "我知道了", style: .default, handler:
        {
            action in
            tableView.reloadData()
        })
        descriptionAlertView.addAction(okAction)
        self.present(descriptionAlertView , animated: true , completion: nil)
    }
    
    func parseBadgeJson(json : String) {
        
        let badgedata = json.data(using: .utf8)!
        
        if let parsedData = try? JSONSerialization.jsonObject(with: badgedata , options:.allowFragments)  as! [[String:AnyObject]] {
            
            //badges
            //if let badgeInJson = parsedData["badge"] as? [[String: AnyObject]] {
                
                for jsonBadge in parsedData{
                
                    let badge = Badge()
                    
                    badge.id = jsonBadge["id"] as! Int
                    
                    badge.badge_id = jsonBadge["badge_id"] as! Int
                    
                    badge.group_id = jsonBadge["group_id"] as! Int
                
                    badge.level = jsonBadge["level"] as! Int
                
                    badge.name = jsonBadge["name"] as! String
                
                    badge.description = jsonBadge["description"] as! String
                    
                    badge.requirement = jsonBadge["requirement"] as! String
                    
                    badge.badge_type = jsonBadge["badge_type"] as! String

                    badge.include_place = jsonBadge["include_place"] as! String
                
                    badge.exclude_place = jsonBadge["exclude_place"] as! String
                
                    badge.time_interval = jsonBadge["time_interval"] as! Int
                
                    badge.times_per_place = jsonBadge["times_per_place"] as! Int
                
                    badge.sumption = jsonBadge["sumption"] as! Int

                    badges.append(badge)
                }
                
            //}
            
            /*
            //classifications
            if let classificationInJson = parsedData["classification"] as? [String] {
                
                for jsonClassification in classificationInJson {
                    
                    let classification = jsonClassification
                    
                    classifications.append(classification)
                }
            }
            */
        }
    }
    
    func httpGet(URL:String) {
        
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
                if URL == "http://140.119.163.40:8080/DarkEmpire/app/ver1.0/userBadge/\(self.userid!)"
                {
                    self.userBadges = self.parseJsonData(data: data!)
                }
                else if URL == "http://140.119.163.40:8080/DarkEmpire/app/ver1.0/badgeType"
                {
                    self.parseBadgeType(data: data!)
                }
            }
            semaphore.signal()
        })
        task.resume()
        semaphore.wait()
    }
    
    func parseBadgeType(data: Data) {
        
        let NSresponseString = NSString(data: data, encoding: String.Encoding.utf8.rawValue)
        var responseString: String = NSresponseString! as String
        /*
        let badgeTypeData = responseString.data(using: .utf8)!
        
        if let parsedData = try? JSONSerialization.jsonObject(with: badgeTypeData) as! [String] {
            
            for jsonBadgeType in parsedData{
                
                let classification = jsonBadgeType
                
                classifications.append(classification)
                
            }
        }
        */
        var index1 = responseString.index((responseString.startIndex), offsetBy: 9)
        responseString = responseString.substring(from: index1)
        index1 = responseString.index((responseString.startIndex), offsetBy: responseString.characters.count - 1)
        responseString = responseString.substring(to: index1)
        var offsetNow = 1
        index1 = responseString.index((responseString.startIndex), offsetBy: 0)
        var index2 = responseString.index((responseString.startIndex), offsetBy: 1)
        var index3 = responseString.index((responseString.startIndex), offsetBy: 1)
        while (offsetNow+1) != responseString.characters.count + 1
        {
            let char = responseString[index2...index2]
            if (char == ",") || (char == "\"")
            {
                index3 = responseString.index((responseString.startIndex), offsetBy: offsetNow - 1)
                let classification = responseString[index1...index3]
                classifications.append(classification)
                index1 = responseString.index((responseString.startIndex), offsetBy: offsetNow + 1)
            }
            offsetNow = offsetNow + 1
            index2 = responseString.index((responseString.startIndex), offsetBy: offsetNow)
        }
    }

    
    func parseJsonData(data : Data)  -> [Int] {
        var userBadges = [Int]()
        
        let NSresponseString = NSString(data: data, encoding: String.Encoding.utf8.rawValue)
        var responseString: String = NSresponseString! as String
        /*
        let userBadgeData = responseString.data(using: .utf8)
        
        if let parsedData = try? JSONSerialization.jsonObject(with: userBadgeData!) as! [[String: Int]]{
            
            for jsonUserBadge in parsedData{
                
                var badge = Int()
                
                badge = jsonUserBadge["userBadge"]!
                
                userBadges.append(badge)
            }
        }
        */
        var index1 = responseString.index((responseString.startIndex), offsetBy: 13)
        responseString = responseString.substring(from: index1)
        index1 = responseString.index((responseString.startIndex), offsetBy: responseString.characters.count)
        responseString = responseString.substring(to: index1)
        var offsetNow = 1
        index1 = responseString.index((responseString.startIndex), offsetBy: 0)
        var index2 = responseString.index((responseString.startIndex), offsetBy: 1)
        var index3 = responseString.index((responseString.startIndex), offsetBy: 1)
        while (offsetNow+1) != responseString.characters.count + 1
        {
            let char = responseString[index2...index2]
            if (char == ",") || (char == "}")
            {
                index3 = responseString.index((responseString.startIndex), offsetBy: offsetNow - 1)
                let badgeNum = Int(responseString[index1...index3])
                userBadges.append(badgeNum!)
                index1 = responseString.index((responseString.startIndex), offsetBy: offsetNow + 1)
            }
            offsetNow = offsetNow + 1
            index2 = responseString.index((responseString.startIndex), offsetBy: offsetNow)
        }
        return userBadges
    }
    
    deinit {
        debugPrint("AchievementView deinitialized")
    }
}
