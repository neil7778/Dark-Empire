//
//  CommunicationViewController.swift
//  Project
//
//  Created by Knaz on 2016/12/14.
//  Copyright © 2016年 Knaz. All rights reserved.
//

import UIKit
import Starscream

class CommunicationViewController: UIViewController , WebSocketDelegate , UITableViewDataSource, UITableViewDelegate ,UIPickerViewDelegate, UIPickerViewDataSource {
    
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    
    //user data
    var user = User()
    var userid = UserDefaults.standard.object(forKey: "userid") as! String
    
    //user list
    var userLists = [UserList]()
    var userInCommunication = UserList()
    
    //socket
    var socket:WebSocket!
    
    //message
    var messageCount = 0
    var useridCountArray:[Int] = []
    var usernameCountArray:[Int] = []
    var textCountArray:[Int] = []
    var messages = [Message]()
    var selectedMessages = [Message]()
    var uidForMsgPerson = ""
    
    //picker view
    @IBOutlet weak var methodTextField: UITextField!
    @IBOutlet weak var countTextField: UITextField!
    //@IBOutlet weak var pickerView: UIPickerView!
    var pickerView = UIPickerView()
    var methods = ["全頻",/*"群組","密語"*/]//群組,密語目前沒用到先鎖起來
    var methodChosen = 1//全頻1 , 群組2 , 密語3
    var countText = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //取得使用者資料
        httpGet(URL: "http://140.119.163.40:8080/DarkEmpire/app/ver1.0/user/\(userid)")
        
        //註冊uid(不要管為什麼反正每次都用)
        httpGet(URL:"http://140.119.163.40:9000/WebsocketTest/msg/newuser/\(user.user_id)/\(user.camp)")
        
        //取得使用者uid
        httpGet(URL: "http://140.119.163.40:9000/WebsocketTest/player/json4/\(userid)")
        
        //socket
        socket = WebSocket(url: URL(string:"ws://140.119.163.40:9000/WebsocketTest/ws?uid=\(userInCommunication.uid)")! , protocols: ["chat", "superchat"])
        socket.delegate = self
        socket.connect()
        
        //messgae method picker view
        let picker: UIPickerView
        picker = UIPickerView(frame: CGRect(x:0, y:200, width:view.frame.width, height:120))
        
        picker.showsSelectionIndicator = true
        picker.delegate = self
        picker.dataSource = self
        
        let toolBar = UIToolbar()
        toolBar.barStyle = UIBarStyle.default
        toolBar.isTranslucent = true
        //toolBar.tintColor = UIColor(red: 76/255, green: 217/255, blue: 100/255, alpha: 1)
        toolBar.sizeToFit()
        
        let doneButton = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.plain, target: self, action: #selector(messageDonePicker))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
        let cancelButton = UIBarButtonItem(title: "Cancel", style: UIBarButtonItemStyle.plain, target: self, action: #selector(cancelPicker))
        
        toolBar.setItems([cancelButton, spaceButton, doneButton], animated: false)
        toolBar.isUserInteractionEnabled = true
        
        methodTextField.inputView = picker
        methodTextField.inputAccessoryView = toolBar
        methodTextField.text = methods[0]
        
        //messgae count picker view
        let toolBar3 = UIToolbar()
        toolBar3.barStyle = UIBarStyle.default
        toolBar3.isTranslucent = true
        //toolBar.tintColor = UIColor(red: 76/255, green: 217/255, blue: 100/255, alpha: 1)
        toolBar3.sizeToFit()
        
        let doneButton3 = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.plain, target: self, action: #selector(countDonePicker))
        let spaceButton3 = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
        let cancelButton2 = UIBarButtonItem(title: "Cancel", style: UIBarButtonItemStyle.plain, target: self, action: #selector(cancelPicker))
        
        toolBar3.setItems([cancelButton2, spaceButton3, doneButton3], animated: false)
        toolBar3.isUserInteractionEnabled = true
        
        countTextField.inputAccessoryView = toolBar3
        countTextField.text = "50"
        countText = countTextField.text!
        
        //textfield button
        let toolBar2 = UIToolbar()
        toolBar2.barStyle = UIBarStyle.default
        toolBar2.isTranslucent = true
        //toolBar.tintColor = UIColor(red: 76/255, green: 217/255, blue: 100/255, alpha: 1)
        toolBar2.sizeToFit()
        
        let doneButton2 = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.plain, target: self, action: #selector(cancelPicker))
        let spaceButton2 = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
        
        toolBar2.setItems([/*cancelButton2, */spaceButton2, doneButton2], animated: false)
        toolBar2.isUserInteractionEnabled = true
        textField.inputAccessoryView = toolBar2
        
        //guesture
        // 增加一個觸控事件
        let tap = UITapGestureRecognizer(target: self,action:#selector(endSelecting))
        tap.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tap)
        
        //get user list
        httpGet(URL: "http://140.119.163.40:9000/WebsocketTest/player/json4/list")
        
        //get history message
        httpGet(URL: "http://140.119.163.40:9000/WebsocketTest/msglist/app/1232436286/501")
        
        //set countTextField
        countTextField.keyboardType = UIKeyboardType(rawValue: 4)!
        countTextField.addTarget(self, action: #selector(countTextFieldTouched), for: UIControlEvents.touchDown)
        
        //set selectedMessages
        for index in 0...49
        {
            //selectedMessages.append(messages[index])
            selectedMessages.insert(messages[index] , at:0)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        socket.disconnect()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //websocket
    func websocketDidConnect(socket: WebSocket) {
        print("web socket connected!")
    }
    
    func websocketDidDisconnect(socket: WebSocket, error: NSError?) {
        print("websocket is disconnected: \(error?.localizedDescription)")
    }
    
    func websocketDidReceiveMessage(socket: WebSocket, text: String) {
        print("got some text: \(text)")
        
        //get user id frame
        var startOffset1 = 0
        var endOffset1 = 6
        var startIndex1 = text.index(text.startIndex, offsetBy: startOffset1)
        var endIndex1 = text.index(text.startIndex, offsetBy: endOffset1)
        while(text[startIndex1...endIndex1] != "fromuid")
        {
            startOffset1 = startOffset1 + 1
            endOffset1 = endOffset1 + 1
            startIndex1 = text.index(text.startIndex, offsetBy: startOffset1)
            endIndex1 = text.index(text.startIndex, offsetBy: endOffset1)
        }
        startOffset1 = startOffset1 + 9
        endOffset1 = endOffset1 + 10
        var startOffset2 = startOffset1
        var endOffset2 = endOffset1 - 7
        var startIndex2 = text.index(text.startIndex, offsetBy: startOffset2)
        var endIndex2 = text.index(text.startIndex, offsetBy: endOffset2)
        while(text[startIndex2...endIndex2] != ",")
        {
            startOffset2 = startOffset2 + 1
            endOffset2 = endOffset2 + 1
            startIndex2 = text.index(text.startIndex, offsetBy: startOffset2)
            endIndex2 = text.index(text.startIndex, offsetBy: endOffset2)
        }
        endOffset1 = endOffset2 - 1
        startIndex1 = text.index(text.startIndex, offsetBy: startOffset1)
        endIndex1 = text.index(text.startIndex, offsetBy: endOffset1)
        
        let userid = text[startIndex1...endIndex1] //id
        let useridCount = text[startIndex1...endIndex1].characters.count as Int
        useridCountArray.append(useridCount)

        //get user name frame
        startOffset1 = 0
        endOffset1 = 7
        startIndex1 = text.index(text.startIndex, offsetBy: startOffset1)
        endIndex1 = text.index(text.startIndex, offsetBy: endOffset1)
        while(text[startIndex1...endIndex1] != "fromName")
        {
            startOffset1 = startOffset1 + 1
            endOffset1 = endOffset1 + 1
            startIndex1 = text.index(text.startIndex, offsetBy: startOffset1)
            endIndex1 = text.index(text.startIndex, offsetBy: endOffset1)
        }
        startOffset1 = startOffset1 + 11
        endOffset1 = endOffset1 + 12
        startOffset2 = startOffset1
        endOffset2 = endOffset1 - 8
        startIndex2 = text.index(text.startIndex, offsetBy: startOffset2)
        endIndex2 = text.index(text.startIndex, offsetBy: endOffset2)
        while(text[startIndex2...endIndex2] != "\"")
        {
            startOffset2 = startOffset2 + 1
            endOffset2 = endOffset2 + 1
            startIndex2 = text.index(text.startIndex, offsetBy: startOffset2)
            endIndex2 = text.index(text.startIndex, offsetBy: endOffset2)
        }
        endOffset1 = endOffset2 - 1
        startIndex1 = text.index(text.startIndex, offsetBy: startOffset1)
        endIndex1 = text.index(text.startIndex, offsetBy: endOffset1)
        
        let username = text[startIndex1...endIndex1] //name
        let usernameCount = text[startIndex1...endIndex1].characters.count as Int
        usernameCountArray.append(usernameCount)
        
        //get user text frame
        startOffset1 = 0
        endOffset1 = 3
        startIndex1 = text.index(text.startIndex, offsetBy: startOffset1)
        endIndex1 = text.index(text.startIndex, offsetBy: endOffset1)
        while(text[startIndex1...endIndex1] != "text")
        {
            startOffset1 = startOffset1 + 1
            endOffset1 = endOffset1 + 1
            startIndex1 = text.index(text.startIndex, offsetBy: startOffset1)
            endIndex1 = text.index(text.startIndex, offsetBy: endOffset1)
        }
        startOffset1 = startOffset1 + 7
        endOffset1 = endOffset1 + 8
        startOffset2 = startOffset1
        endOffset2 = endOffset1 - 4
        startIndex2 = text.index(text.startIndex, offsetBy: startOffset2)
        endIndex2 = text.index(text.startIndex, offsetBy: endOffset2)
        while(text[startIndex2...endIndex2] != "\"")
        {
            startOffset2 = startOffset2 + 1
            endOffset2 = endOffset2 + 1
            startIndex2 = text.index(text.startIndex, offsetBy: startOffset2)
            endIndex2 = text.index(text.startIndex, offsetBy: endOffset2)
        }
        endOffset1 = endOffset2 - 1
        startIndex1 = text.index(text.startIndex, offsetBy: startOffset1)
        endIndex1 = text.index(text.startIndex, offsetBy: endOffset1)
        
        let usertext = text[startIndex1...endIndex1] //text
        let textCount = text[startIndex1...endIndex1].characters.count as Int
        
        textCountArray.append(textCount)
        messageCount = messageCount + 1
        
        let message = Message()
        message.userid = Int(userid)!
        message.username = username
        message.text = usertext
        
        //將新訊息加入總訊息中
        //messages.insert(message, at: 0)
        messages.append(message)
        
        //將新訊息加入欲顯示的訊息中，並移除最舊的訊息
        //selectedMessages.insert(message, at: 0)
        selectedMessages.append(message)
        //selectedMessages.remove(at: selectedMessages.count - 1)
        selectedMessages.remove(at: 0)

        tableView.reloadData()
    }
    
    func websocketDidReceiveData(socket: WebSocket, data: Data) {
        print("got some data: \(data.count)")
    }
    
    @IBAction func sendMessage(_ sender: UIButton) {
        if(textField.text?.characters.count != 0)
        {
            //全頻
            if methodChosen == 1
            {
                socket.write(string: "{\"fromuid\":\(userInCommunication.playerid),\"fromName\":\"\(user.user_name)\",\"touid\":1,\"text\":\"\(textField.text!)\"}")
                textField.text = ""
                print("send message : \(textField.text!)")
            }
                
            //群組
            else if methodChosen == 2
            {
                socket.write(string: "{\"fromuid\":1481027130576,\"fromName\":\"暱稱\",\"touid\":\(userInCommunication.groupid),\"text\":\"\(textField.text!)\"}")
                textField.text = ""
                print("send message : \(textField.text!)")
            }
                
            //密語
            else if methodChosen == 3
            {
                socket.write(string: "{\"fromuid\":1481027130576,\"fromName\":\"暱稱\",\"touid\":\(uidForMsgPerson),\"text\":\"\(textField.text!)\"}")
                textField.text = ""
                print("send message : \(textField.text!)")
            }
        }
    }
    
    //table view
    //總共顯示幾欄項目
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return selectedMessages.count
    }
    
    //每欄的內容
    func tableView(_ tableView: UITableView,cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "message", for: indexPath as IndexPath) as! CommunicationTableViewCell
        
        if Int(selectedMessages[indexPath.row].userid) == userInCommunication.playerid
        {
            cell.messageLabel.text = "我 : \(selectedMessages[indexPath.row].text)"
        }
        else
        {
            cell.messageLabel.text = "\(selectedMessages[indexPath.row].username) : \(selectedMessages[indexPath.row].text)"
        }
        return cell
    }
    
    //按下其中一欄後
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    
    //picker View
    // UIPickerView 有幾列
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    // UIPickerView 各列有多少行資料
    func pickerView(_ pickerView: UIPickerView,numberOfRowsInComponent component: Int) -> Int {
        return methods.count
    }
    
    // UIPickerView 每個選項顯示的資料
    func pickerView(_ pickerView: UIPickerView,titleForRow row: Int, forComponent component: Int)-> String? {
        return methods[row]
    }
    
    // UIPickerView 改變選擇後執行的動作
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int)
    {
        methodChosen = row
        methodTextField.text = methods[row]
    }
    
    //gesture
    func endSelecting(tapG:UITapGestureRecognizer){
        self.view.endEditing(true)
    }
    
    func countTextFieldTouched(textField: UITextField) {
        countTextField.text = ""
    }
    
    //http get
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
//                if(URL.characters.count > 63)
//                {
//                    let start = 0
//                    let end = 63
//                    let startIndex = URL.index(URL.startIndex, offsetBy: start)
//                    let endIndex = URL.index(URL.startIndex, offsetBy: end)
//                    if URL[startIndex...endIndex] == "http://140.119.163.40:9000/WebsocketTest/msglist/app/1232436286/"
//                    {
//                        self.messages.removeAll()
//                        self.parseHistoryMessages(data:data)
//                        self.tableView.reloadData()
//                    }
//                }
                if URL == "http://140.119.163.40:9000/WebsocketTest/player/json4/list"
                {
                    self.parseUserList(data: data)
                }
                if URL == "http://140.119.163.40:9000/WebsocketTest/player/json4/\(self.userid)"
                {
                    self.parseUser(data: data)
                }
                if URL == "http://140.119.163.40:8080/DarkEmpire/app/ver1.0/user/\(self.userid)"
                {
                    self.parseUserData(data: data)
                }
                if URL == "http://140.119.163.40:9000/WebsocketTest/msglist/app/1232436286/501"
                {
                    self.parseHistoryMessages(data:data)
                }
            }
            semaphore.signal()
        })
        task.resume()
        semaphore.wait()
    }
    
    func parseUserList(data: Data) {
        
        let NSresponseString = NSString(data: data, encoding: String.Encoding.utf8.rawValue)
        let responseString: String = NSresponseString! as String
        let placeUserListData = responseString.data(using: .utf8)!
        
        if let parsedData = try? JSONSerialization.jsonObject(with: placeUserListData) as! [[String: AnyObject]] {
            
            for jsonUser in parsedData
            {
                let user = UserList()
                
                user.id = jsonUser["id"] as! Int
                
                user.name = jsonUser["name"] as! String
                
                user.playerid = jsonUser["playerid"] as! Int
                
                user.uid = jsonUser["uid"] as! Int64
                
                user.groupid = jsonUser["groupid"] as! Int
                
                userLists.append(user)
            }
            
        }
    }
    
    func parseUser(data: Data) {
        
        let NSresponseString = NSString(data: data, encoding: String.Encoding.utf8.rawValue)
        let responseString: String = NSresponseString! as String
        let placeUserListData = responseString.data(using: .utf8)!
        
        if let parsedData = try? JSONSerialization.jsonObject(with: placeUserListData) as! [[String: AnyObject]] {
            
            for jsonUser in parsedData
            {
                userInCommunication.id = jsonUser["id"] as! Int
                
                userInCommunication.name = jsonUser["name"] as! String
                
                userInCommunication.playerid = jsonUser["playerid"] as! Int
                
                userInCommunication.uid = jsonUser["uid"] as! Int64
                
                userInCommunication.groupid = jsonUser["groupid"] as! Int
            }
        }
    }
    
    func parseUserData(data:Data){
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
    
    func parseHistoryMessages(data:Data){
        
        let NSresponseString = NSString(data: data, encoding: String.Encoding.utf8.rawValue)
        let responseString: String = NSresponseString! as String
        let historyMessages = responseString.data(using: .utf8)!
        
        if let parsedData = try? JSONSerialization.jsonObject(with: historyMessages) as! [[String: Any]] {
            
            for jsonMessage in parsedData{
                
                let message = Message()
                
                message.userid = jsonMessage["fromuid"] as! Int
                message.username = jsonMessage["fromName"] as! String
                if Int(message.userid) == userInCommunication.playerid
                {
                    message.username = "我"
                }
                message.text = jsonMessage["text"] as! String
                messages.append(message)
            }
        }
    }
    
    func cancelPicker() {
        methodTextField.resignFirstResponder()
        countTextField.resignFirstResponder()
        textField.resignFirstResponder()
        countTextField.text = countText
    }
    
    func messageDonePicker() {
        methodTextField.resignFirstResponder()
        //get method
        if methodTextField.text! == "全頻"
        {
            methodChosen = 1
        }
        else if methodTextField.text! == "群組"
        {
            methodChosen = 2
        }
        if methodTextField.text! == "密語"
        {
            methodChosen = 3
        }
        
        //deal with method
        if methodChosen == 3
        {
            let addFriendAlertView = UIAlertController(title: "請輸入您要密語的對象", message: "請輸入您要密語的對象", preferredStyle: .alert)
            
            addFriendAlertView.addTextField {
                (amountTextField: UITextField!) -> Void in
                amountTextField.placeholder = "請輸入暱稱"
            }
            
            let cancelAction = UIAlertAction(title: "取消", style: .cancel, handler: nil)
            let okAction = UIAlertAction(title: "確定", style: .default, handler:
                {
                    action in
                    var inputString = ""
                    inputString = addFriendAlertView.textFields!.first!.text!
                    
                    //若暱稱為空值
                    if(inputString.characters.count == 0)
                    {
                        let amountAlertView = UIAlertController(title: "注意" , message: "暱稱不可為空白" , preferredStyle: .alert)
                        let knowAction = UIAlertAction(title: "我知道了", style: .default, handler: {
                            action in
                            self.present(addFriendAlertView , animated: true , completion: nil)
                        })
                        amountAlertView.addAction(knowAction)
                        self.present(amountAlertView , animated: true , completion: nil)
                    }
                        
                    //若暱稱不為空值
                    else
                    {
                        self.uidForMsgPerson = inputString
                    }
            })
            addFriendAlertView.addAction(cancelAction)
            addFriendAlertView.addAction(okAction)
            self.present(addFriendAlertView , animated: true , completion: nil)
        }
    }
    
    func countDonePicker() {
        if (countTextField.text == "") || (countTextField.text == countText)//輸入""或原數值
        {
            countTextField.resignFirstResponder()
            countTextField.text = countText
        }
        else if Int(countTextField.text!)! > Int(countText)!//新數值大於原數值
        {
            countTextField.resignFirstResponder()
            if messages.count < 500//留言總數 < 500(上界:留言總數)
            {
                if(Int(countTextField.text!)! >= messages.count)//輸入值 >= 留言總數
                {
                    if Int(countText)! < (messages.count - 1)
                    {
                        for index in Int(countText)!...(messages.count - 1)
                        {
                            //selectedMessages.append(messages[index])
                            selectedMessages.insert(messages[index], at:0)
                        }
                    }
                    countText = String(messages.count)
                    countTextField.text = String(messages.count)
                }
                else//輸入值 < 留言總數
                {
                    if Int(countText)! < Int(countTextField.text!)!
                    {
                        for index in Int(countText)!...(Int(countTextField.text!)! - 1)
                        {
                            //selectedMessages.append(messages[index])
                            selectedMessages.insert(messages[index], at:0)
                        }
                    }
                    countText = countTextField.text!
                }
            }
            else//留言總數 > 500(上界:500)
            {
                if Int(countTextField.text!)! >= 500//輸入值 >= 500
                {
                    if Int(countText)! < (Int(countTextField.text!)! - 1)
                    {
                        for index in Int(countText)!...(Int(countTextField.text!)! - 1)
                        {
                            //selectedMessages.append(messages[index])
                            selectedMessages.insert(messages[index], at:0)
                        }
                    }
                        countText = "500"
                        countTextField.text = "500"
                }
                else//輸入值 < 500
                {
                    if Int(countText)! < Int(countTextField.text!)!
                    {
                        for index in Int(countText)!...(Int(countTextField.text!)! - 1)
                        {
                            //selectedMessages.append(messages[index])
                            selectedMessages.insert(messages[index], at:0)
                        }
                    }
                    countText = countTextField.text!
                }
            }
            self.tableView.reloadData()
        }
        else if Int(countTextField.text!)! < Int(countText)!//新數值小於原數值
        {
            countTextField.resignFirstResponder()
            for _ in 0...(Int(countText)! - Int(countTextField.text!)!) - 1
            {
                //selectedMessages.remove(at: selectedMessages.count - 1)
                selectedMessages.remove(at: 0)
            }
            countText = countTextField.text!
            self.tableView.reloadData()
        }
    }
    
    deinit {
        debugPrint("CommunicationView deinitialized")
    }
}
