//
//  HomeCollectionViewController.swift
//  Red
//
//  Created by AJ Ibraheem on 20/07/2015.
//  Copyright © 2015 The Leaf. All rights reserved.
//

import UIKit
import CoreData

private let reuseIdentifier = "wordCell"

class HomeCollectionViewController: UICollectionViewController {
    
    var words: [Word] = []
    var searchResults: [Word] = []
    var searchController: UISearchController!
    var fetchResultsController: NSFetchedResultsController!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.collectionView?.backgroundColor = UIColor.whiteColor()
        self.words = fetchDataFromDB()!
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Register cell classes
        //self.collectionView!.registerClass(UICollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        //self.collectionView!.registerClass(UISearchBar.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "")
        //Additional Setup
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func filterConentForSearchText( searchText:String ){
        searchResults = words.filter({ (word:Word) -> Bool in
            let titleMatch = word.title.rangeOfString(searchText, options: .CaseInsensitiveSearch )
            let descMatch = word.wordDescription.rangeOfString(searchText, options: .CaseInsensitiveSearch )
            return ( (titleMatch != nil) || (descMatch != nil) )
        })
    }
    
    func fetchDataFromDB() -> [Word]?{
        //Core Data
        let fetchRequest = NSFetchRequest( entityName: "Word" )
        let sortDescriptor = NSSortDescriptor( key: "title", ascending: true )
        let managedObjCtx = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
        fetchRequest.sortDescriptors = [sortDescriptor]
        fetchResultsController = NSFetchedResultsController( fetchRequest: fetchRequest, managedObjectContext: managedObjCtx, sectionNameKeyPath: nil, cacheName: nil )
        fetchResultsController.delegate = self
        do{
            try fetchResultsController.performFetch()
            let words = fetchResultsController.fetchedObjects as! [Word]
            return words
        }catch{
            print( error )
            return nil
        }
    }
    
    func addNewWord( newWord:Word, context:NSManagedObjectContext ){
//        let managedObjContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
//        let word = NSEntityDescription.insertNewObjectForEntityForName("Word", inManagedObjectContext: managedObjContext) as! Word
//        word.title = newWord.title
//        word.wordDescription = newWord.wordDescription
//        word.picture = newWord.picture
//        word.audio = newWord.audio
        //Save to DB
        do{
            try context.save()
            self.words = fetchDataFromDB()!
            //TODO: Fix Bug here
            //collectionView?.insertItemsAtIndexPaths([NSIndexPath(forItem: self.words.count, inSection: 0)])
            collectionView?.reloadData()
        }
        catch{ print("Insertion Error:\((error as NSError).localizedDescription)") }
    }
    
    @IBAction func unwindToSegue( segue:UIStoryboardSegue ) {
        if segue.identifier == "cancelAdd" {}
    }

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "addWord" {
            let navController = segue.destinationViewController as! UINavigationController
            let addVC = navController.viewControllers[0] as! AddViewController
            addVC.homeController = self 
        }
    }

    //UICollectionViewDataSource
    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }

    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return words.count
    }

    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as! WordCollectionViewCell
        let word = self.words[indexPath.item]
        cell.titleLabel.text = word.title
        cell.backgroundColor = UIColor( red: 245/255, green: 245/255, blue: 245/255, alpha: 1 )
        cell.layer.borderColor = UIColor( red: 245/255, green: 245/255, blue: 245/255, alpha: 0 ).CGColor
        cell.layer.borderWidth = 1.1
        cell.layer.cornerRadius = 5.0
        if let pic = word.picture {
            cell.imageView.image = UIImage( data: pic )
            cell.imageView.layer.cornerRadius = cell.imageView.frame.width / 2
            cell.imageView.clipsToBounds = true
        }
        return cell
    }

    // MARK: UICollectionViewDelegate

    /*
    // Uncomment this method to specify if the specified item should be highlighted during tracking
    override func collectionView(collectionView: UICollectionView, shouldHighlightItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment this method to specify if the specified item should be selected
    override func collectionView(collectionView: UICollectionView, shouldSelectItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
    override func collectionView(collectionView: UICollectionView, shouldShowMenuForItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        return false
    }

    override func collectionView(collectionView: UICollectionView, canPerformAction action: Selector, forItemAtIndexPath indexPath: NSIndexPath, withSender sender: AnyObject?) -> Bool {
        return false
    }

    override func collectionView(collectionView: UICollectionView, performAction action: Selector, forItemAtIndexPath indexPath: NSIndexPath, withSender sender: AnyObject?) {
    
    }
    */

}

extension HomeCollectionViewController: NSFetchedResultsControllerDelegate {
    
}

extension HomeCollectionViewController: UICollectionViewDelegateFlowLayout {

}