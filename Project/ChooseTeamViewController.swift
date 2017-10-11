//
//  ChooseTeamViewController.swift
//  Project
//
//  Created by 劉有容 on 2016/10/13.
//  Copyright © 2016年 Knaz. All rights reserved.
//

import UIKit

class ChooseTeamViewController: UIViewController {

    //buttons
    @IBOutlet weak var totemShinaiButton: UIButton!
    @IBOutlet weak var totemAnyataButton: UIButton!
    @IBOutlet weak var textView: UITextView!
    
    //navigation bar
    var navBar: UINavigationBar = UINavigationBar()
    var navitem: UINavigationItem = UINavigationItem()
    
    //user data
    let userid = UserDefaults.standard.object(forKey: "userid")
    let firstUseApp_chooseTeamView = UserDefaults.standard.object(forKey: "firstUseApp_chooseTeamView") as? String
    let firstUseApp_gameMapView = UserDefaults.standard.object(forKey: "firstUseApp_gameMapView") as? String
    let firstUseApp_gameView = UserDefaults.standard.object(forKey: "firstUseApp_gameView") as? String

    var campid = 0
    
    //alert view
    let alertView = UIAlertController(title: "歡迎進入遊戲", message: "在拳杉堡對抗黑暗勢力的你\n將選擇加入席奈或是安塔雅族\n\n你必須巡邏並淨化神殿\n以捍衛您族人的勢力\n\n黑暗勢力是兩族共同的敵人\n當所有神殿遭到黑暗勢力全面入侵時\n您必須與族人合作\n到大神殿救援拳杉堡\n\n當您成為超原力使者時\n您將負起保護大神殿的任務", preferredStyle: .alert)
    let okAction = UIAlertAction(title: "我知道了", style: .default, handler: nil)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //set first time use parameters
        UserDefaults.standard.set("true", forKey: "firstUseApp_chooseTeamView")
        UserDefaults.standard.set("true", forKey: "firstUseApp_gameMapView")
        UserDefaults.standard.set("true", forKey: "firstUseApp_gameView")
        UserDefaults.standard.synchronize()
        
        //set navigation bar
        self.setNavBarToTheView()
        self.title = "選擇陣營"
        
        //set game illustration
        textView.text = "\t拳杉堡是新世界的聖地。3000年前，拳杉堡原是兩大勢力的停戰線。這兩大勢力是兩個部落，他們曾經打了1000年的仗。\n\n\t兩大勢力之一的席奈族(Sinae) 是受印琛(Jinzen)大帝迫害的脫逃者，為了躲避追殺，他們帶著具有族人神力的馬納圖騰「超原力」(Super Force)從暗黑大陸逃至新世界。另一方則是海龍王後代安塔雅族(Antayen)。安塔雅人早在50000年前便找到新世界並定居在此；一直到4000年前，席奈人來此落地生根，也因而與安塔雅人開啟了長達千年的衝突。兩軍最後在拳杉堡協議停戰，劃定停戰線，維持了將近2500年的和平。一代代曾經守護和平的首領與將軍，分別在拳杉堡樹立了誓言與族訓，他們的神靈也棲息在這些碑言與神殿之中，提醒著子民們不能再掀起戰爭。而這些子民後代，則共享了超原力的庇佑，每個子民身上都有馬納。\n\n\t500年前，印琛的第七代傳人發生內戰，戰敗的蚋轅(Ruyen)決定尋找4000年前脫逃者所帶走的超原力，一路找尋到新世界。來到新世界的蚋轅為了在拳杉堡建立基地，殺害無數安塔雅人與席奈人，甚至挑起兩族仇恨，擾亂了2500年來的和平。但是，直到臨終前蚋轅都沒有找到超原力，於是他與惡魔立約，如果能讓他找到超原力，他的靈魂願意成為惡魔的坐騎。惡魔於是結束了蚋轅的生命，將他化為一匹黑馬，並開始在拳杉堡四處潛伏，搜尋超原力。而席奈人與阿塔亞人也為了信守族訓，聯合起來保護超原力，並驅趕暗黑勢力。\n\n\t參與這場保衛戰的你我，都是席奈人與安塔雅人的後代，我們同時流著兩族人的血脈。不管你投入哪一方，只代表你決定在這場戰役中扮演甚麼任務。這場戰役，只有靠我們通力合作，才可能守住拳杉堡、保護超原力不被奪走。\n"
        textView.isEditable = false
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        //set alert view
        if(firstUseApp_chooseTeamView != "false")
        {
            alertView.addAction(okAction)
            self.present(alertView , animated: true , completion: nil)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        ChooseTeamViewController().dismiss(animated: true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setNavBarToTheView() {
        self.navBar.frame = CGRect(x:0,y:0,width:UIScreen.main.bounds.width,height:UIScreen.main.bounds.width * 0.2)
        navitem.title = "選擇陣營"
        self.navBar.pushItem(navitem, animated: true)
        self.view.addSubview(navBar)
    }
    
    @IBAction func buttonTouched(_ sender: UIButton) {
        //選擇席奈陣營
        if(sender == totemShinaiButton)
        {
            campid = 2
        }
        //選擇安雅塔陣營
        else if(sender == totemAnyataButton)
        {
            campid = 1
        }
        httpPost(URL: "http://140.119.163.40:8080/DarkEmpire/app/ver1.0/user/camp/\(userid!)/\(campid)")
        
        //使非第一次使用
        UserDefaults.standard.set("false", forKey: "firstUseApp_chooseTeamView")
        UserDefaults.standard.synchronize()
        
        //跳到 main function view
        let storyboard: UIStoryboard = self.storyboard!
        let navigationController = storyboard.instantiateViewController(withIdentifier: "NavigationController") as! UINavigationController
        self.present(navigationController, animated: true, completion: nil)
    }
    
    func httpPost(URL:String) {
        let URL:NSURL = NSURL(string:URL)!
        //let jsonUserInformation = ["user_id": userid ,"camp": campid] as [String : Any]
        let request:NSMutableURLRequest = NSMutableURLRequest(url: URL as URL, cachePolicy: NSURLRequest.CachePolicy.reloadIgnoringLocalCacheData, timeoutInterval: 10)
        let semaphore = DispatchSemaphore(value: 0)
        
        request.httpMethod = "POST"
        //request.httpBody = try! JSONSerialization.data(withJSONObject: jsonUserInformation , options: [])
        
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
            
            //let responseString = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)
            //print("responseString = \(responseString)")
            semaphore.signal()
        }
        task.resume()
        semaphore.wait()
    }
    
    deinit {
        debugPrint("ChooseTeamView deinitialized")
    }
}
