//
//  GameMapViewController.swift
//  Project
//
//  Created by 劉有容 on 2016/10/17.
//  Copyright © 2016年 Knaz. All rights reserved.
//

import UIKit
import GoogleMaps
import AVFoundation

class GameMapViewController: UIViewController ,CLLocationManagerDelegate , GMSMapViewDelegate{
    
    //user location
    var locationManager :CLLocationManager!
    
    //map
    var mapView = GMSMapView()
    
    //markers
    var markerToBeTapped: GMSMarker!
    
    //timer
    var timer:Timer!
    
    //place
    var places = [Place]()
    
    //place data
    var placeJson = UserDefaults.standard.object(forKey: "placeJson") as! String
    
    //place state
    var placeStates = [PlaceState]()
    
    //music
    var musicPlayer: AVAudioPlayer!
    
    //overlay
    var overlay:GMSGroundOverlay! = nil
    
    //alert view
    var alertView = UIAlertController()
    let okAction = UIAlertAction(title: "開始探索", style: .default, handler: nil)
    let firstUseApp_gameMapView = UserDefaults.standard.object(forKey: "firstUseApp_gameMapView") as? String
    
    //toast label
    var toastLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //取得使用者位置
//        if (CLLocationManager.authorizationStatus() != .denied)
//        {
            locationManager = CLLocationManager()
            locationManager.delegate = self
            let latitude = (locationManager.location?.coordinate.latitude)!
            let longitude = (locationManager.location?.coordinate.longitude)!
        
            // 距離篩選器 用來設置移動多遠距離才觸發委任方法更新位置
            locationManager.distanceFilter = kCLLocationAccuracyBestForNavigation
        
            // 取得自身定位位置的精確度
            locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
//        }
        
        //set map
        mapView = GMSMapView.map(withFrame: CGRect(x:0 , y:0, width:UIScreen.main.bounds.width , height:UIScreen.main.bounds.height) , camera: GMSCameraPosition.camera(withLatitude: latitude , longitude: longitude , zoom: 19))
        mapView.isMyLocationEnabled = true
        mapView.delegate = self
        
        //手勢
        mapView.settings.scrollGestures = false
//        mapView.settings.zoomGestures = false
        mapView.settings.tiltGestures = false
//        mapView.settings.rotateGestures = false
        
        //set places
        places = parseJsonData(placeJson: placeJson)
        
        //show map
//        self.view = mapView
        self.view.insertSubview(mapView, at:1)
        
        //set toast message
        toastLabel = UILabel(frame: CGRect(x:0 , y:0 , width:UIScreen.main.bounds.width  , height:UIScreen.main.bounds.height * 0.1))
        toastLabel.center = CGPoint(x: UIScreen.main.bounds.width * 0.5 , y: UIScreen.main.bounds.height * 0.9)
        toastLabel.backgroundColor = UIColor.gray
        toastLabel.textColor = UIColor.white
        toastLabel.textAlignment = NSTextAlignment.center
        
        print("user location-> latitude:\(latitude) , longitude:\(longitude)")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        locationManager.startUpdatingLocation()

        mapView.clear()
        
        //set place states
        httpGet(URL:"http://140.119.163.40:8080/DarkEmpire/app/ver1.0/placeState/list")
        
        //set marker
        for place in places
        {
            if(place.main_id == 0)
            {
                putPlaceOnMap(mapView:mapView , id:place.place_id , mainid:place.main_id , latitude:place.latitude , longitude:place.longitude)
            }
        }
        
        //camera
        //使用者位置
        let latitude = (locationManager.location?.coordinate.latitude)!
        let longitude = (locationManager.location?.coordinate.longitude)!
        let userLocation = GMSCameraPosition.camera(withLatitude: latitude , longitude: longitude , zoom: 19)
        mapView.camera = userLocation
        
        //底圖
        let southWest = CLLocationCoordinate2DMake(latitude - 92 , longitude - 58)
        let northEast = CLLocationCoordinate2DMake(latitude + 65 , longitude + 58)
        let overlayBounds = GMSCoordinateBounds(coordinate: southWest, coordinate: northEast)
        let icon = UIImage(named: "background.png")
        overlay = GMSGroundOverlay(bounds: overlayBounds, icon: icon)
        overlay.bearing = 0
        overlay.opacity = 0.7
        overlay.map = mapView
        
        //reload map
//        self.view = mapView
        self.view.insertSubview(mapView, at:1)

        //set timer        
        timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateUserLocation), userInfo: nil, repeats: true)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if(firstUseApp_gameMapView != "false")
        {
            alertView = UIAlertController(title: "攻塔攻略", message: "點選您要攻下的神殿名字！進入神殿所在準備攻擊嘍！", preferredStyle: .alert)
            alertView.addAction(okAction)
            self.present(alertView , animated: true , completion: nil)
            UserDefaults.standard.set("false", forKey: "firstUseApp_gameMapView")
            UserDefaults.standard.synchronize()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        locationManager.stopUpdatingLocation()
        GameMapViewController().dismiss(animated: true, completion: nil)
        timer.invalidate()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func updateUserLocation(){
        //update user location
        locationManager.startUpdatingLocation()
        let latitude = (locationManager.location?.coordinate.latitude)!//////////////////////
        let longitude = (locationManager.location?.coordinate.longitude)!////////////////////
        let currentZoom = self.mapView.camera.zoom
        let currentBearing = self.mapView.camera.bearing
//        print("\(latitude) , \(longitude)")
        let userLocation = GMSCameraPosition.camera(withLatitude: latitude , longitude: longitude , zoom: currentZoom , bearing:currentBearing , viewingAngle:0)
        mapView.camera = userLocation
        
        //reload map
        self.view.insertSubview(mapView, at:1)
//        self.view = mapView
    }
    
//    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
//        let location = locations.last as! CLLocation
//        
//        let center = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
//        let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
//        
//        self.map.setRegion(region, animated: true)
//    }

    
    func putPlaceOnMap(mapView:GMSMapView , id:Int , mainid:Int , latitude:Double , longitude:Double){
        
        //add marker
        let marker = GMSMarker()
        var image = UIImage()
        marker.position = CLLocationCoordinate2DMake(latitude , longitude)
        marker.appearAnimation = kGMSMarkerAnimationPop
        for placeState in placeStates
        {
            if(id == placeState.place_id)
            {
                //非樟山寺
                if placeState.place_id != 51
                {
                    if(placeState.camp_id == 0)
                    {
                        image = resizeImage(image: #imageLiteral(resourceName: "fortress_yellow") , targetSize: CGSize(width: UIScreen.main.bounds.width * 0.3, height: UIScreen.main.bounds.height * 0.3))
                    }
                    else if(placeState.camp_id == 1)
                    {
                        image = resizeImage(image: #imageLiteral(resourceName: "fortress_red") , targetSize: CGSize(width: UIScreen.main.bounds.width * 0.3, height: UIScreen.main.bounds.height * 0.17))
                    }
                    else if(placeState.camp_id == 2)
                    {
                        image = resizeImage(image: #imageLiteral(resourceName: "fortress_blue") , targetSize: CGSize(width: UIScreen.main.bounds.width * 0.3, height: UIScreen.main.bounds.height * 0.17))
                    }
                    else if(placeState.camp_id == 3)
                    {
                        image = resizeImage(image: #imageLiteral(resourceName: "fortress_black") , targetSize: CGSize(width: UIScreen.main.bounds.width * 0.3, height: UIScreen.main.bounds.height * 0.17))
                    }
                }
                //樟山寺
                else
                {
                    if(placeState.camp_id == 0)
                    {
                        image = resizeImage(image: #imageLiteral(resourceName: "bigFortress_yellow") , targetSize: CGSize(width: UIScreen.main.bounds.width * 0.3, height: UIScreen.main.bounds.height * 0.3))
                    }
                    else if(placeState.camp_id == 1)
                    {
                        image = resizeImage(image: #imageLiteral(resourceName: "bigFortress_red") , targetSize: CGSize(width: UIScreen.main.bounds.width * 0.3, height: UIScreen.main.bounds.height * 0.17))
                    }
                    else if(placeState.camp_id == 2)
                    {
                        image = resizeImage(image: #imageLiteral(resourceName: "bigFortress_blue") , targetSize: CGSize(width: UIScreen.main.bounds.width * 0.3, height: UIScreen.main.bounds.height * 0.17))
                    }
                    else if(placeState.camp_id == 3)
                    {
                        image = resizeImage(image: #imageLiteral(resourceName: "bigFortress_black") , targetSize: CGSize(width: UIScreen.main.bounds.width * 0.3, height: UIScreen.main.bounds.height * 0.17))
                    }
                }
            }
        }
        marker.icon = image
        marker.map = mapView
    }
    
    //點到marker時
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        markerToBeTapped = marker
        
        //取得使用者位置
        locationManager = CLLocationManager()
        locationManager.delegate = self
        let latitude = (locationManager.location?.coordinate.latitude)!
        let longitude = (locationManager.location?.coordinate.longitude)!
        
//        print((markerToBeTapped.position.latitude - latitude)/0.00001)
//        print((markerToBeTapped.position.longitude - longitude)/0.00001)
//        print(pow((markerToBeTapped.position.latitude - latitude)/0.00001 , 2))
//        print(pow((markerToBeTapped.position.longitude - longitude)/0.00001 , 2))
//        print(pow((markerToBeTapped.position.latitude - latitude)/0.00001 , 2) + pow((markerToBeTapped.position.longitude - longitude)/0.00001 , 2))
        
        //求位置差
        let radLat1 = markerToBeTapped.position.latitude * Double.pi / 180.0
        let radLat2 = latitude * Double.pi / 180.0
        let a = radLat1 - radLat2
        let b = (markerToBeTapped.position.longitude * Double.pi / 180.0) - (longitude * Double.pi / 180.0)
        var s = 2 * asin(sqrt(pow(sin(a/2),2) + cos(radLat1) * cos(radLat2) * pow(sin(b/2),2)))
        s = s * 6378137//位置差
        
        //樟山寺
        if markerToBeTapped.position.latitude == 24.9729947
        {
            if s < 100
            {
                let settingMute:String = UserDefaults.standard.object(forKey: "settingMute") as! String
                if(settingMute == "false")
                {
                    //播放音效
                    let path = Bundle.main.path(forResource: "003地圖點選(文字)", ofType:"mp3")!
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
                performSegue(withIdentifier: "showPlaceTableView", sender: self)
            }
            
            else
            {
                let distance = Int(abs(s - 99))
                //toast message
                self.view.addSubview(self.toastLabel)
                //self.toastLabel.text = "Loading Data (\(dataCount)/8)"
                self.toastLabel.text = "與該地點距離太遠 還要再\(distance)公尺"
                self.toastLabel.alpha = 1.0
                self.toastLabel.clipsToBounds = true
                self.toastLabel.layer.cornerRadius = self.toastLabel.bounds.size.height * 0.5
                UIView.animate(withDuration: 2.0, delay: 1.0, options: UIViewAnimationOptions.curveEaseOut, animations: {
                    self.toastLabel.alpha = 0.0
                })
            }
        }
            
        //非樟山寺
        else
        {
            if s < 50
            {
                let settingMute:String = UserDefaults.standard.object(forKey: "settingMute") as! String
                if(settingMute == "false")
                {
                    //播放音效
                    let path = Bundle.main.path(forResource: "003地圖點選(文字)", ofType:"mp3")!
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
                performSegue(withIdentifier: "showPlaceTableView", sender: self)
            }
                
            else
            {
                let distance = Int(abs(s - 29))
                //toast message
                self.view.addSubview(self.toastLabel)
                //self.toastLabel.text = "Loading Data (\(dataCount)/8)"
                self.toastLabel.text = "與該地點距離太遠 還要再\(distance)公尺"
                self.toastLabel.alpha = 1.0
                self.toastLabel.clipsToBounds = true
                self.toastLabel.layer.cornerRadius = self.toastLabel.bounds.size.height * 0.5
                UIView.animate(withDuration: 2.0, delay: 1.0, options: UIViewAnimationOptions.curveEaseOut, animations: {
                    self.toastLabel.alpha = 0.0
                })
            }
        }
        
        return true
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any!) {
        if(segue.identifier == "showPlaceTableView")
        {
            let placeTableViewController = segue.destination as! PlaceTableViewController
            placeTableViewController.placeLatitude = markerToBeTapped.position.latitude
            placeTableViewController.placeLongitude = markerToBeTapped.position.longitude
        }
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
                self.parsePlaceStateJson(data: data)
            }
            semaphore.signal()
        })
        task.resume()
        semaphore.wait()
    }
    
    func parsePlaceStateJson(data: Data) {
        
        let NSresponseString = NSString(data: data, encoding: String.Encoding.utf8.rawValue)
        let responseString: String = NSresponseString! as String
        let placeStatedata = responseString.data(using: .utf8)!
        
        if let parsedData = try? JSONSerialization.jsonObject(with: placeStatedata) as! [[String:Any]] {
            
            for jsonPlaceState in parsedData{
                
                let placeState = PlaceState()
                
                placeState.id = jsonPlaceState["id"] as! Int
                
                placeState.camp_id = jsonPlaceState["camp_id"] as! Int
                
                placeState.place_id = jsonPlaceState["place_id"] as! Int
                
                placeState.keeper_id = jsonPlaceState["keeper_id"] as! Int
                
                placeState.hp = jsonPlaceState["hp"] as! Int
                
                placeState.maxHP = jsonPlaceState["maxHp"] as! Int
                
                placeStates.append(placeState)
            }
        }
    }
    
    func parseJsonData(placeJson: String)  -> [Place] {
        var places = [Place]()
        let placedata = placeJson.data(using: .utf8)!
        
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
                
                places.append(place)
            }
        }
        return places
    }
    
    deinit {
        debugPrint("GameMapView deinitialized")
    }
}

