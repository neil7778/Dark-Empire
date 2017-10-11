//
//  GetCoinViewController.swift
//  Project
//
//  Created by Knaz on 2016/10/20.
//  Copyright © 2016年 Knaz. All rights reserved.
//

import UIKit
import GoogleMaps
import AVFoundation


class GetCoinViewController: UIViewController , CLLocationManagerDelegate , GMSMapViewDelegate{
    
    //coin data
    var coins = [Coin?]()
    
    //timer
    var timer:Timer!
    
    //user location
    var locationManager :CLLocationManager!
    
    //map
    var mapView = GMSMapView()
        
    //user data
    let userid = UserDefaults.standard.object(forKey: "userid") as! String!
    
    //markers
    var markers = [GMSMarker?]()
    
    //overlays
    var overlay1:GMSGroundOverlay! = nil
    var overlay2:GMSGroundOverlay! = nil
    
    //toast label
    var toastLabel :UILabel!
    
    //music
    var musicPlayer: AVAudioPlayer!
    
    //background image
    @IBOutlet weak var backgroundImageView: UIImageView!
    var anotherUIView :UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //set location manager
        locationManager = CLLocationManager()
        locationManager.delegate = self
        let latitude = (locationManager.location?.coordinate.latitude)!
        let longitude = (locationManager.location?.coordinate.longitude)!
        
        // 距離篩選器 用來設置移動多遠距離才觸發委任方法更新位置
        locationManager.distanceFilter = kCLLocationAccuracyBestForNavigation
        
        // 取得自身定位位置的精確度
        locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        
        //set map
        mapView = GMSMapView.map(withFrame: CGRect(x:0 , y:(UIScreen.main.bounds.height) * 0.25 , width:UIScreen.main.bounds.width , height:(UIScreen.main.bounds.height) * 0.6) , camera: GMSCameraPosition.camera(withLatitude: latitude , longitude: longitude , zoom: 17))
        mapView.isMyLocationEnabled = true
        mapView.settings.scrollGestures = false
        mapView.settings.zoomGestures = false
        mapView.settings.tiltGestures = false
        mapView.settings.rotateGestures = false
        mapView.delegate = self
        
        //set marker
        httpGet(URL: "http://140.119.163.40:8080/DarkEmpire/app/ver1.0/runeTradeRecord/search_rune/\(longitude)/\(latitude)/")
        
        for coin in coins
        {
            tossCoinOnMap(mapView: mapView ,id: coin!.id , rune_id:coin!.rune_id , stone:coin!.stone , latitude: coin!.latitude , longitude: coin!.longitude)
        }
        
        //set toast message
        toastLabel = UILabel(frame: CGRect(x:0 , y:0 , width:UIScreen.main.bounds.width * 0.6 , height:UIScreen.main.bounds.height * 0.1))
        toastLabel.center = CGPoint(x: UIScreen.main.bounds.width * 0.5 , y: UIScreen.main.bounds.height * 0.9)
        toastLabel.backgroundColor = UIColor.gray
        toastLabel.textColor = UIColor.white
        toastLabel.textAlignment = NSTextAlignment.center
        
        /*
        // 一個可供移動的 UIView
        anotherUIView = UIView(frame: CGRect(
            x: mapView.center.x , y: mapView.center.y ,
            width: 50, height: 50))
        anotherUIView.backgroundColor = UIColor.orange
        self.mapView.addSubview(anotherUIView)
        
        //pan gesture
        // 拖曳手勢
        let pan = UIPanGestureRecognizer(
            target:self,
            action:#selector(GetCoinViewController.pan(_:)))
        
        // 最少可以用幾指拖曳
        pan.minimumNumberOfTouches = 1
        
        // 最多可以用幾指拖曳
        pan.maximumNumberOfTouches = 1
        
        // 為這個可移動的 UIView 加上監聽手勢
        mapView.addGestureRecognizer(pan)
        */
        
        //show map
        self.view.insertSubview(mapView, at:1)//at代表放在view上的第幾層
        print("user location-> latitude:\(latitude) , longitude:\(longitude)")
    }
    
    // The Pan Gesture
    /*
    func pan(_ recognizer:UIPanGestureRecognizer) {
        // 設置 UIView 新的位置
        let point = recognizer.location(in: self.view)
        print(point)
        print()
        anotherUIView.center = point
    }
    */
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        locationManager.startUpdatingLocation()
        
        //set timer
        timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateUserLocation), userInfo: nil, repeats: true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        locationManager.stopUpdatingLocation()
        timer.invalidate()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //reload map
    func updateUserLocation(){
        //update user location
        //camera
        let latitude = (locationManager.location?.coordinate.latitude)!
        let longitude = (locationManager.location?.coordinate.longitude)!
        let userLocation = GMSCameraPosition.camera(withLatitude: latitude , longitude: longitude , zoom: 17)
        mapView.camera = userLocation
        print("\(latitude) , \(longitude)")
        
        //底圖
        let southWest1 = CLLocationCoordinate2DMake(latitude - 0.1 , longitude - 0.1)
        let northEast1 = CLLocationCoordinate2DMake(latitude + 0.1 , longitude + 0.1)
        let overlayBounds1 = GMSCoordinateBounds(coordinate: southWest1, coordinate: northEast1)
        let icon1 = UIImage(named: "magic.png")
        overlay1 = GMSGroundOverlay(bounds: overlayBounds1, icon: icon1)
        overlay1.bearing = 0
        overlay1.map = mapView
        
        //魔法陣
        let southWest2 = CLLocationCoordinate2DMake(latitude - 0.0019 , longitude - 0.002)
        let northEast2 = CLLocationCoordinate2DMake(latitude + 0.0018 , longitude + 0.002)
        let overlayBounds2 = GMSCoordinateBounds(coordinate: southWest2, coordinate: northEast2)
        let icon2 = UIImage(named: "magic.png")
        overlay2 = GMSGroundOverlay(bounds: overlayBounds2, icon: icon2)
        overlay2.bearing = 0
        overlay2.map = mapView
        
        //reload map
        self.view.insertSubview(mapView, at:1)
    }
    
    //點到marker時
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
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
            for markerInMarkers in markers
            {
                //有marker才進入（有可能已被砍掉）
                if(markerInMarkers == marker)
                {
                    let markerLatitude = marker.position.latitude
                    let markerLongitude = marker.position.longitude
                    var finish = 0
                    for var coin in coins
                    {
                        //有marker才進入（有可能已被砍掉）(為取得coin.id才有此迴圈)
                        if(coin != nil)
                        {
                            if(coin!.latitude == markerLatitude)
                            {
                                if(coin!.longitude == markerLongitude)
                                {
                                    //post資料
                                    httpPost(URL:"http://140.119.163.40:8080/DarkEmpire/app/ver1.0/runeTradeRecord/get_rune/\(coin!.id)/\(userid!)")
                                    print("you get a coin!\nruneid: \(coin!.rune_id)\namount: \(coin!.stone)")
                                    
                                    //toast message
                                    self.view.addSubview(toastLabel)
                                    toastLabel.text = "you get \(coin!.stone) coin !"
                                    toastLabel.alpha = 1.0
                                    toastLabel.clipsToBounds  =  true
                                    toastLabel.layer.cornerRadius = toastLabel.bounds.size.height * 0.5
                                    UIView.animate(withDuration: 1.0, delay: 0.1, options: UIViewAnimationOptions.curveEaseOut, animations: {
                                        self.toastLabel.alpha = 0.0
                                    })
                                    
                                    let settingMute:String = UserDefaults.standard.object(forKey: "settingMute") as! String
                                    if(settingMute == "false")
                                    {
                                        //播放音效
                                        let path = Bundle.main.path(forResource: "009", ofType:"mp3")!
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
                                    
                                    coin = nil
                                    finish = 1
                                    
                                    
                                    //記錄使用者位置
                                    let latitude = (locationManager.location?.coordinate.latitude)!
                                    let longitude = (locationManager.location?.coordinate.longitude)!
                                    httpGet(URL: "http://140.119.163.40:8080/DarkEmpire/app/ver1.0/storeAction/\(userid!)/5/\(longitude)/\(latitude)/")
                                    
                                    break
                                }
                            }
                        }
                    }
                    //消marker
                    if (marker.map != nil)
                    {
                        marker.map = nil
                    }
                    
                    if(finish == 1)
                    {
                        break
                    }
                }
            }
        }
        self.view.insertSubview(mapView, at:1)
        return true
    }
    
    func tossCoinOnMap(mapView:GMSMapView , id:Int , rune_id:Int , stone:Int , latitude:Double , longitude:Double){
        
        //add marker
        let marker = GMSMarker()
        var image = UIImage()
        marker.position = CLLocationCoordinate2DMake(latitude , longitude)
        marker.appearAnimation = kGMSMarkerAnimationPop
        if(rune_id == 1)
        {
            image = resizeImage(image: #imageLiteral(resourceName: "a") , targetSize: CGSize(width: UIScreen.main.bounds.width * 0.3, height: UIScreen.main.bounds.height * 0.3))
            marker.icon = image
        }
        else
        {
            image = resizeImage(image: #imageLiteral(resourceName: "b") , targetSize: CGSize(width: UIScreen.main.bounds.width * 0.3, height: UIScreen.main.bounds.height * 0.3))
            marker.icon = image
        }
        marker.map = mapView
        //add marker to markers
        markers.append(marker)
    }
    
    func resizeImage(image: UIImage, targetSize: CGSize) -> UIImage {
        let size = image.size
        
        let widthRatio  = targetSize.width  / image.size.width
        let heightRatio = targetSize.height / image.size.height
        
        // Figure out what our orientation is, and use that to form the rectangle
        var newSize: CGSize
        if(widthRatio > heightRatio) {
            newSize = CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
        } else {
            newSize = CGSize(width: size.width * widthRatio,  height: size.height * widthRatio)
        }
        
        // This is the rect that we've calculated out and this is what is actually used below
        let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)
        
        // Actually do the resizing to the rect using the ImageContext stuff
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        image.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!
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
            else
            {
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
                print(error)
                
                let netConnectionAlertView = UIAlertController(title: "網路連線異常", message: "請確認網路已連線，才能繼續進行遊戲喔", preferredStyle: .alert)
                let okAction = UIAlertAction(title: "我知道了", style: .default, handler: nil)
                netConnectionAlertView.addAction(okAction)
                self.present(netConnectionAlertView , animated: true , completion: nil)
            }
            else
            {
                let data = data
                self.coins = self.parseJsonData(data: data!)
            }
            semaphore.signal()
        })
        task.resume()
        semaphore.wait()
    }
    
    func parseJsonData(data : Data)  -> [Coin] {
        var coins = [Coin]()
        
        let NSresponseString = NSString(data: data, encoding: String.Encoding.utf8.rawValue)
        let responseString: String = NSresponseString! as String
        let coindata = responseString.data(using: .utf8)!
        
        if let parsedData = try? JSONSerialization.jsonObject(with: coindata) as! [[String:Any]] {
            
            for jsonCoin in parsedData{
                
                let coin = Coin()
                
                coin.id = jsonCoin["id"] as! Int
                
                coin.alice_id = jsonCoin["alice_id"] as! Int
                
                coin.rune_id = jsonCoin["rune_id"] as! Int
                
                coin.stone = jsonCoin["stone"] as! Int
                
                coin.bob_id = jsonCoin["bob_id"] as! Int
                
                coin.longitude = jsonCoin["longitude"] as! Double
                
                coin.latitude = jsonCoin["latitude"] as! Double
                
                coins.append(coin)
            }
        }
        return coins
    }
    
    deinit {
        debugPrint("GetCoinView deinitialized")
    }
}

//var timer1:Timer!

//override func viewWillAppear(_ animated: Bool) {
//    super.viewWillAppear(animated)
//    timer1 = Timer.scheduledTimer(timeInterval: 5.0, target: self, selector: #selector(getCoin), userInfo: nil, repeats: true)
//}

//override func viewWillDisappear(_ animated: Bool) {
//    super.viewWillDisappear(animated)
//    timer1.invalidate()
//}

//    func getCoin(){
//        var userLatitude = (locationManager.location?.coordinate.latitude)!
//        var userLongitude = (locationManager.location?.coordinate.longitude)!
//
//        for var marker in markers
//        {
//            //有marker才進入（有可能已被砍掉）
//            if(marker != nil)
//            {
//                //若在使用者附近
//                if(abs(abs(userLatitude) - abs(marker!.position.latitude)) <= 0.00005)//abs()代表取絕對值
//                {
//                    if(abs(abs(userLongitude) - abs(marker!.position.longitude)) <= 0.00005)
//                    {
//                        //post資料
//                        var markerLatitude = marker!.position.latitude
//                        var markerLongitude = marker!.position.longitude
//                        var finish = 0
//                        for var coin in coins
//                        {
//                            //有marker才進入（有可能已被砍掉）(為取得coin.id才有此迴圈)
//                            if(coin != nil)
//                            {
//                                if(coin!.latitude == markerLatitude)
//                                {
//                                    if(coin!.longitude == markerLongitude)
//                                    {
//                                        httpPost(URL: "http://140.119.163.40:8080/DarkEmpire/app/ver1.0/runeTradeRecord/get_rune/\(coin!.id)/\(userid)")
//                                        coin = nil
//                                        finish = 1
//                                        break
//                                    }
//                                }
//                            }
//                        }
//
//                        //消marker
//                        if (marker!.map != nil)
//                        {
//                            marker!.map = nil
//                        }
//                        marker = nil
//                        if(finish == 1)
//                        {
//                            break
//                        }
//                    }
//                }
//            }
//        }
//        self.view.insertSubview(mapView, at:1)
//    }

