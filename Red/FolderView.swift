//
//  FolderView.swift
//  My Word Bank
//
//  Created by AJ Ibraheem on 26/07/2015.
//  Copyright © 2015 The Leaf. All rights reserved.
//

import UIKit

class FolderView: MyView {

    @IBOutlet weak var nameLabel: UILabel!

    class func instanceFromNib() -> FolderView{
        let view = UIView.loadFromNibName("FolderView") as! FolderView
        view.layer.cornerRadius = 5
        view.layer.borderColor = UIColor( red: 245/255, green: 245/255, blue: 245/255, alpha: 0 ).CGColor
        view.layer.borderWidth = 1.1
        view.backgroundColor = UIColor( red: 245/255, green: 245/255, blue: 245/255, alpha: 1 )
        return view
    }
}
