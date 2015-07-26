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

//TODO: Add SearchController
class HomeCollectionViewController: UICollectionViewController {
    
    var words: [Word] = []
    var searchResults: [Word] = []
    var searchController: UISearchController!
    var fetchResultsController: NSFetchedResultsController!
    let managedObjCtx = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext

    override func viewDidLoad() {
        super.viewDidLoad()
        self.collectionView?.backgroundColor = UIColor.whiteColor()
        self.words = fetchDataFromDB()!
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
        let sortDescriptor = NSSortDescriptor( key: "displayOrder", ascending: true )
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
    
    func saveWord( newWord:Word?, context:NSManagedObjectContext ){
        //Save to DB
        do{
            try context.save()
            self.words = fetchDataFromDB()!
            //FIXME: CollectionView complains about the way we insert new items
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
            //addVC.homeController = self
        }else if segue.identifier == "showWord" {
            let wordVC = segue.destinationViewController as! WordViewController
            let indexPath = collectionView?.indexPathsForSelectedItems()![0]
            wordVC.word = self.words[ indexPath!.item ]
            //wordVC.homeVC = self
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
        //FIXME: Fix Audio bug: audio image noe showing for some cells
        if word.audio == nil { cell.playButton.hidden = true }
        return cell
    }

    // MARK: UICollectionViewDelegate
    override func collectionView(collectionView: UICollectionView, shouldHighlightItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }

    override func collectionView(collectionView: UICollectionView, shouldSelectItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }

    override func collectionView(collectionView: UICollectionView, shouldDeselectItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        
    }
}

extension HomeCollectionViewController: NSFetchedResultsControllerDelegate {
    func controller(controller: NSFetchedResultsController, didChangeObject anObject: NSManagedObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        do{ try managedObjCtx.save() }catch{ print("\(error)") }
    }
}

extension HomeCollectionViewController: UICollectionViewDelegateFlowLayout {

}

//extension HomeCollectionViewController: LXReorderableCollectionViewDataSource {
//    override func collectionView(collectionView: UICollectionView, canMoveItemAtIndexPath indexPath: NSIndexPath) -> Bool {
//        return true
//    }
//    
//    func collectionView(collectionView: UICollectionView!, itemAtIndexPath fromIndexPath: NSIndexPath!, willMoveToIndexPath toIndexPath: NSIndexPath!) {
//        let word = self.words[ fromIndexPath.item ]
//        self.words.removeAtIndex( fromIndexPath.item )
//        self.words.insert(word, atIndex: toIndexPath.item )
//    }
//    
//    func collectionView(collectionView: UICollectionView!, itemAtIndexPath fromIndexPath: NSIndexPath!, didMoveToIndexPath toIndexPath: NSIndexPath!) {
//        //Update the display order
//        var i = 0
//        self.words.map({ $0.setValue(i++, forKey:"displayOrder") })
//    }
//
//}














