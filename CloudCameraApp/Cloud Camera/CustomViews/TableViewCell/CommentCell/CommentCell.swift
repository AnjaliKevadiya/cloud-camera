//
//  CommentCell.swift
//  CloudCamera
//
//  Created by Anjali Kevadiya on 1/30/19.
//  Copyright © 2019 Anjali Kevadiya. All rights reserved.
//

import UIKit

class CommentCell: UITableViewCell {

    @IBOutlet weak var lblUsername: UILabel!
    @IBOutlet weak var lblComment: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
