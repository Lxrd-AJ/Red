//
//  Extensions.swift
//  Capchit
//
//  Created by AJ Ibraheem on 18/10/2015.
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

func normalizedPowerLevelFromDecibels( decibels:CGFloat ) -> CGFloat {
    if( decibels < -60.0 || decibels == 0.0 ) { return 0.0 }
    return CGFloat(powf((powf(10.0, Float(0.05) * Float(decibels)) - powf(10.0, 0.05 * -60.0)) * (1.0 / (1.0 - powf(10.0, 0.05 * -60.0))), 1.0 / 2.0));
}