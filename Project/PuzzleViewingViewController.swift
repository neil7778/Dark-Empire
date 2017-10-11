//
//  PuzzleViewingViewController.swift
//  Project
//
//  Created by Knaz on 2017/4/12.
//  Copyright © 2017年 Knaz. All rights reserved.
//

import UIKit

class PuzzleViewingViewController: UIViewController {
    
    //images
    @IBOutlet weak var image1: UIImageView!
    @IBOutlet weak var image2: UIImageView!
    @IBOutlet weak var image3: UIImageView!
    @IBOutlet weak var image4: UIImageView!
    @IBOutlet weak var image5: UIImageView!
    @IBOutlet weak var image6: UIImageView!
    @IBOutlet weak var image7: UIImageView!
    @IBOutlet weak var image8: UIImageView!
    @IBOutlet weak var image9: UIImageView!
    
    //get userid
    let userid = UserDefaults.standard.object(forKey: "userid") as! String
    
    //超原力目前擺放位置
    var forceColorString = ""
    var color = ""
    var number = 0

    override func viewDidLoad() {
        super.viewDidLoad()

        var images = [image1,image2,image3,image4,image5,image6,image7,image8]
        
        //取得拼圖顏色
        httpGet(URL:"http://140.119.163.40:8080/DarkEmpire/app/ver1.0/forceColor")
        
        //初始化拼圖
        image9.image = UIImage(named:"magicBorder")
        
        for placeNumber in 0...7
        {
            let currentColor = forceColorString.characters.first
            if currentColor == "Y"
            {
                color = "Yellow"
                number = placeNumber + 1
                images[placeNumber]?.image = UIImage(named:"magic\(color)\(number)")
                
            }
            else if currentColor == "R"
            {
                color = "Red"
                number = placeNumber + 1
                images[placeNumber]?.image = UIImage(named:"magic\(color)\(number)")
                
            }
            else if currentColor == "B"
            {
                color = "Blue"
                number = placeNumber + 1
                images[placeNumber]?.image = UIImage(named:"magic\(color)\(number)")
                
            }
            else if currentColor == "D"
            {
                color = "Dark"
                number = placeNumber + 1
                images[placeNumber]?.image = UIImage(named:"magic\(color)\(number)")
                
            }
            let index = forceColorString.index((forceColorString.startIndex), offsetBy: 0)
            forceColorString.remove(at: index)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
                let NSresponseString = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)
                self.forceColorString = NSresponseString! as String
            }
            semaphore.signal()
        })
        task.resume()
        semaphore.wait()
        
    }
}
