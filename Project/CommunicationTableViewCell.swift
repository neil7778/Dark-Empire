//
//  CommunicationTableViewCell.swift
//  Project
//
//  Created by Knaz on 2017/1/1.
//  Copyright © 2017年 Knaz. All rights reserved.
//

import UIKit

class CommunicationTableViewCell: UITableViewCell {

    @IBOutlet weak var messageLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
