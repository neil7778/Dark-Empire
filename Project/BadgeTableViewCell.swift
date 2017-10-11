//
//  BadgeTableViewCell.swift
//  Project
//
//  Created by Knaz on 2016/10/30.
//  Copyright © 2016年 Knaz. All rights reserved.
//

import UIKit

class BadgeTableViewCell: UITableViewCell {

    @IBOutlet weak var badgeTypeImageView: UIImageView!
    @IBOutlet weak var badgeNameLabel: UILabel!
    @IBOutlet weak var badgeDiscriptionLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
