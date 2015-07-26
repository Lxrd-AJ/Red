//
//  Extensions.swift
//  My Word Bank
//
//  Created by AJ Ibraheem on 25/07/2015.
//  Copyright © 2015 The Leaf. All rights reserved.
//

import Foundation
import UIKit
import CoreData

extension UIView{
    class func loadFromNibName( nibNamed:String, bundle:NSBundle? = nil ) -> UIView? {
        return UINib(nibName: nibNamed, bundle: bundle).instantiateWithOwner(nil , options: nil)[0] as? UIView
    }
}





