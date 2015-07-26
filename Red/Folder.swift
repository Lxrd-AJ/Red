//
//  Folder.swift
//  My Word Bank
//
//  Created by AJ Ibraheem on 26/07/2015.
//  Copyright © 2015 The Leaf. All rights reserved.
//

import Foundation
import CoreData

class Folder: NSManagedObject {
    @NSManaged var creationDate: NSDate?
    @NSManaged var name: String?
    @NSManaged var words: NSSet?
    
    func addWords( words:[Word] , saveCtx:() -> () ){
        var currentWords = self.words?.allObjects as! [Word]
        currentWords += words
        self.words = NSSet(array: currentWords)
        saveCtx()
    }
    
    class func createFolder( name:String, ctx:NSManagedObjectContext ) -> Folder?{
        let folder = NSEntityDescription.insertNewObjectForEntityForName("Folder", inManagedObjectContext: ctx) as! Folder
        folder.name = name
        folder.creationDate = NSDate()
        do{
            try ctx.save()
            return folder
        }catch{ print( "\(error)" ) ;return nil }
    }
}