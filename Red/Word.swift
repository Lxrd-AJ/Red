//
//  Word.swift
//  Red
//
//  Created by AJ Ibraheem on 10/07/2015.
//  Copyright © 2015 The Leaf. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class Word: NSManagedObject {
    @NSManaged var title: String!
    @NSManaged var wordDescription: String!
    @NSManaged var audio: NSData?
    @NSManaged var picture: NSData?
    
}
