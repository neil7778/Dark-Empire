//
//  PlaceTableViewController.swift
//  Project
//
//  Created by Knaz on 2016/10/27.
//  Copyright © 2016年 Knaz. All rights reserved.
//

import UIKit
import CoreLocation

class PlaceTableViewController: UITableViewController , CLLocationManagerDelegate {
    
    //place data
    var places = [Place]()
    var placeLatitude : Double!
    var placeLongitude : Double!
    var placeID : Int!
    var placeName : String!
    var placeJson = UserDefaults.standard.object(forKey: "placeJson") as! String
    
    //user location
    var locationManager :CLLocationManager!
    
    //internet
    var internetIsOn = 1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //set back ground
        let fullScreenSize = UIScreen.main.bounds.size
        let backgroundImageView = UIImageView()
        backgroundImageView.frame.size = CGSize(width: fullScreenSize.width , height: fullScreenSize.height * 1.4)
        backgroundImageView.center = CGPoint(x: fullScreenSize.width * 0.5 , y: fullScreenSize.height * 0.5)
        backgroundImageView.image = UIImage(named: "background.png")
        self.view.insertSubview(backgroundImageView, at:0)
        
        //parse data
        parseJsonData(json: placeJson)
        
        //set location manager
        locationManager = CLLocationManager()
        locationManager.delegate = self
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
    
    //總共顯示幾欄項目
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return places.count
    }
    
    //每欄的內容
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Place", for: indexPath as IndexPath) as! PlaceTableViewCell
        cell.placeNameLabel.text = places[indexPath.row].name
        return cell
    }
    
    //按下其中一欄後
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
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
            self.present(alertController, animated: true, completion: nil)
        }
        else
        {
            //為了檢查網路有沒有連上因此而讀
            httpGet(URL: "http://140.119.163.40:8080/DarkEmpire/app/ver1.0/getForceUser")
            
            if internetIsOn == 1
            {
                placeID = places[indexPath.row].place_id
                placeName = places[indexPath.row].name
                //樟山寺
                if placeID == 51
                {
                    performSegue(withIdentifier: "showPuzzleView", sender: self)
                }
                //非樟山寺
                else
                {
                    performSegue(withIdentifier: "showGameView", sender: self)
                }
            }
            internetIsOn = 1
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any!) {
        //非樟山寺
        if(segue.identifier == "showGameView")
        {
            let gameViewController = segue.destination as! GameViewController
            gameViewController.placeID = placeID
            gameViewController.placeName = placeName
            gameViewController.placeLatitude = placeLatitude
            gameViewController.placeLongitude = placeLongitude
        }
        //樟山寺
        else
        {
            locationManager = CLLocationManager()
            locationManager.delegate = self
            let puzzleViewController = segue.destination as! PuzzleViewController
            puzzleViewController.placeLatitude = placeLatitude
            puzzleViewController.placeLongitude = placeLongitude
        }
    }
    
    func parseJsonData(json:String) {
        
        var tmpPlaces = [Place]()
        let placedata = json.data(using: .utf8)!
            
        if let parsedData = try? JSONSerialization.jsonObject(with: placedata) as! [[String:Any]] {
                
            for jsonPlace in parsedData{
                
                let place = Place()
                
                place.id = jsonPlace["id"] as! Int
                
                place.main_id = jsonPlace["main_id"] as! Int
                
                place.name = jsonPlace["name"] as! String
                
                place.owner = jsonPlace["owner"] as! String
                
                place.longitude = jsonPlace["longitude"] as! Double
                
                place.latitude = jsonPlace["latitude"] as! Double
                                                
                place.place_id = jsonPlace["place_id"] as! Int
                
                tmpPlaces.append(place)
            }
        }
        
        for place in tmpPlaces
        {
            if(place.latitude == placeLatitude)
            {
                if(place.longitude == placeLongitude)
                {
                    places.append(place)
                    break
                }
            }
        }
        
        for place in tmpPlaces
        {
            if(place.main_id == places.first!.place_id)
            {
                places.append(place)
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
                self.internetIsOn = 0
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
        debugPrint("PlaceTableView deinitialized")
    }
}
