//
//  SettingWithSwitchTableViewCell.swift
//  Project
//
//  Created by Knaz on 2016/11/3.
//  Copyright © 2016年 Knaz. All rights reserved.
//

import UIKit

class SettingWithSwitchTableViewCell: UITableViewCell {

    @IBOutlet weak var typeLabel: UILabel!
    @IBOutlet weak var mySwitch: UISwitch!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
