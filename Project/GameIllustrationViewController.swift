//
//  GameIllustrationViewController.swift
//  Project
//
//  Created by Knaz on 2016/12/22.
//  Copyright © 2016年 Knaz. All rights reserved.
//

import UIKit

class GameIllustrationViewController: UIViewController {

    @IBOutlet weak var textView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        textView.text = "巡邏：\n藉由巡邏神殿可以累積馬納值，若對象是友方族人佔有的神殿，則可以為神殿補充馬納值。\n\n淨化：\n透過淨化消耗馬納值以將暗黑勢力驅離、佔領神殿。\n\n聖水：\n共有紅、黃、藍三色聖水，可以在執行淨化時選用，藉以強化淨化效果。聖水可經由前一天的活躍程度來獲得，亦可用金幣購買。\n前一天巡邏神殿滿15座未達30座，可得10瓶紅色。\n前一天巡邏神殿滿30座未達全部，可得10瓶紅色、5瓶黃色。\n前一天巡邏過包含大神殿的所有神殿，可得紅色15瓶、黃色10瓶、藍色5瓶。\n\n超原力：\n每隔一星期，雙方陣營將各有隨機的七個人，代表自己的族人獲得超原力的庇佑，超原力擁有者可以選擇留為己用，其個人將得到能力強化（當週巡邏與淨化效率增加1.5倍）；也可以選擇供奉到大神殿，當一個陣營的超原力供奉數量先達到5個，那麼全族將可獲得每人500枚金幣。然而若碰到雙方陣營的供奉數各佔一半（四比四），將會導致馬納發生碰撞而削弱大神殿的庇護力量，使得暗黑勢力入侵速度增快。\n\n金幣：\n可以透過佔領神殿獲得，持續佔領一座神殿，第5天獲得金幣100枚，第6天200枚，第7天300枚，第8天400枚，第9天500枚。第10天起，每天維持500枚獎勵。\n得到超原力的獎勵，成為超原力使者，不論是否供奉到大神殿，皆可獲得1000枚金幣。\n金幣可用來買聖水，紅、黃、藍三色聖水所需金幣分別為200、500、1000枚。\n\n升級條件一覽：\nL1：首次登入\nL2：累積巡邏達100次\nL3：累積巡邏達500次\nL4：累積巡邏達1000次\nL5：累積巡邏達2000次，成功淨化神殿（黑轉紅or藍）1次\nL6：累積巡邏達3000次；成功淨化神殿2次；集滿「校園尋奇」徽章\nL7：累積巡邏達4000次；成功淨化神殿3次\nL8：累積巡邏達5000次；成功淨化神殿4次\nL9：累積巡邏達6000次；成功淨化神殿5次\nL10：累積巡邏達7000次；成功淨化神殿6次；集滿「探索」徽章"
        textView.isEditable = false
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

}
