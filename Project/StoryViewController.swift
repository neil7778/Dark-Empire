//
//  StoryViewController.swift
//  Project
//
//  Created by Knaz on 2016\12\29.
//  Copyright © 2016年 Knaz. All rights reserved.
//

import UIKit

class StoryViewController: UIViewController {

    @IBOutlet weak var storyTextView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        storyTextView.isEditable = false

        storyTextView.text="\t拳杉堡是新世界的聖地。3000年前，拳杉堡原是兩大勢力的停戰線。這兩大勢力是兩個部落，他們曾經打了1000年的仗。\n\n\t兩大勢力之一的席奈族(Sinae) 是受印琛(Jinzen)大帝迫害的脫逃者，為了躲避追殺，他們帶著具有族人神力的馬納圖騰「超原力」(Super Force)從暗黑大陸逃至新世界。另一方則是海龍王後代安塔雅族(Antayen)。安塔雅人早在50000年前便找到新世界並定居在此；一直到4000年前，席奈人來此落地生根，也因而與安塔雅人開啟了長達千年的衝突。兩軍最後在拳杉堡協議停戰，劃定停戰線，維持了將近2500年的和平。一代代曾經守護和平的首領與將軍，分別在拳杉堡樹立了誓言與族訓，他們的神靈也棲息在這些碑言與神殿之中，提醒著子民們不能再掀起戰爭。而這些子民後代，則共享了超原力的庇佑，每個子民身上都有馬納。\n\n\t500年前，印琛的第七代傳人發生內戰，戰敗的蚋轅(Ruyen)決定尋找4000年前脫逃者所帶走的超原力，一路找尋到新世界。來到新世界的蚋轅為了在拳杉堡建立基地，殺害無數安塔雅人與席奈人，甚至挑起兩族仇恨，擾亂了2500年來的和平。但是，直到臨終前蚋轅都沒有找到超原力，於是他與惡魔立約，如果能讓他找到超原力，他的靈魂願意成為惡魔的坐騎。惡魔於是結束了蚋轅的生命，將他化為一匹黑馬，並開始在拳杉堡四處潛伏，搜尋超原力。而席奈人與阿塔亞人也為了信守族訓，聯合起來保護超原力，並驅趕暗黑勢力。\n\n\t參與這場保衛戰的你我，都是席奈人與安塔雅人的後代，我們同時流著兩族人的血脈。不管你投入哪一方，只代表你決定在這場戰役中扮演甚麼任務。這場戰役，只有靠我們通力合作，才可能守住拳杉堡、保護超原力不被奪走。\n"
 
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    

}
