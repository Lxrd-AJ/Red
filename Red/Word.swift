//
//  Word.swift
//  Red
//
//  Created by AJ Ibraheem on 10/07/2015.
//  Copyright © 2015 The Leaf. All rights reserved.
//

import Foundation
import UIKit

class Word {
    var title: String!
    var description: String!
    var audioURL: NSURL?
    var picture: UIImage?
    
    init( title:String, desc:String ){
        self.title = title
        description = desc;
    }
}
