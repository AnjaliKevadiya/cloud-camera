//
//  LikeMoreCommentCell.swift
//  CloudCamera
//
//  Created by Anjali Kevadiya on 1/30/19.
//  Copyright © 2019 Anjali Kevadiya. All rights reserved.
//

import UIKit

protocol LikeMoreCommentCellDelegate {
    
    func likeUnlikePic(cell: LikeMoreCommentCell)
    func moreSelection()
    func addComment()
}

class LikeMoreCommentCell: UITableViewCell {

    @IBOutlet weak var btnLike: UIButton!
    @IBOutlet weak var btnLikeCount: UIButton!
    @IBOutlet weak var btnMore: UIButton!
    @IBOutlet weak var btnComment: UIButton!

    var delegate: LikeMoreCommentCellDelegate?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func onClickLikeUnlikeButton(_ sender: UIButton) {
        delegate?.likeUnlikePic(cell: self)
    }
    
    @IBAction func onClickMoreButton(_ sender: UIButton) {
        delegate?.moreSelection()
    }
    
    @IBAction func onClickCommentButton(_ sender: UIButton) {
        delegate?.addComment()
    }
}
