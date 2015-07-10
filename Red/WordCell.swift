//
//  WordCell.swift
//  Red
//
//  Created by AJ Ibraheem on 10/07/2015.
//  Copyright © 2015 The Leaf. All rights reserved.
//

import UIKit

class WordCell: UITableViewCell {
    
    @IBOutlet var picture: UIImageView!
    @IBOutlet var title: UILabel!
    @IBOutlet var desc: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
