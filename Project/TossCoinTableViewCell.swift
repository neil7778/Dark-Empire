//
//  TossCoinTableViewCell.swift
//  Project
//
//  Created by Knaz on 2016/10/20.
//  Copyright © 2016年 Knaz. All rights reserved.
//

import UIKit

class TossCoinTableViewCell: UITableViewCell {

    @IBOutlet weak var moneyTypeImageView: UIImageView!
    @IBOutlet weak var moneyAmountLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}
