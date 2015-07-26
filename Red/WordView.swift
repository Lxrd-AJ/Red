//
//  WordView.swift
//  My Word Bank
//
//  Created by AJ Ibraheem on 25/07/2015.
//  Copyright © 2015 The Leaf. All rights reserved.
//

import UIKit

class WordView: UIView {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var audioImageView: UIImageView!
    var index: Int = 0
    
    class func instanceFromNib() -> WordView {
        let view = UIView.loadFromNibName("WordView") as! WordView
        //Configure the View
        view.layer.cornerRadius = 5
        view.layer.borderColor = UIColor( red: 245/255, green: 245/255, blue: 245/255, alpha: 0 ).CGColor
        view.layer.borderWidth = 1.1
        view.backgroundColor = UIColor( red: 245/255, green: 245/255, blue: 245/255, alpha: 1 )
        return view
    }

}
