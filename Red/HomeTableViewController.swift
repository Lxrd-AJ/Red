//
//  HomeTableViewController.swift
//  Red
//
//  Created by AJ Ibraheem on 10/07/2015.
//  Copyright © 2015 The Leaf. All rights reserved.
//

import UIKit
import CoreData

class HomeTableViewController: UITableViewController {
    
    var words: [Word] = []
    var searchResults: [Word] = []
    var searchController: UISearchController!
    var fetchResultsController: NSFetchedResultsController!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Search Customisation
        searchController = UISearchController( searchResultsController: nil )
        searchController.searchBar.sizeToFit()
        tableView.tableHeaderView = searchController.searchBar
        definesPresentationContext = true
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search for a word"
        
        fetchDataFromDB()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        fetchDataFromDB()
        tableView.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == "showWord" {
            let destController = segue.destinationViewController as! WordViewController
            if let indexPath = tableView.indexPathForSelectedRow {
                if searchController.active {
                    destController.word = searchResults[ indexPath.row ]
                }else{ destController.word = words[ indexPath.row ] }
            }
        }
    }
    
    @IBAction func unwindToSegue( segue:UIStoryboardSegue ) {
        if segue.identifier == "cancelAdd" {}
    }
    
    func filterConentForSearchText( searchText:String ){
        searchResults = words.filter({ (word:Word) -> Bool in
            let titleMatch = word.title.rangeOfString(searchText, options: .CaseInsensitiveSearch )
            let descMatch = word.wordDescription.rangeOfString(searchText, options: .CaseInsensitiveSearch )
            return ( (titleMatch != nil) || (descMatch != nil) )
        })
    }
    
    func fetchDataFromDB(){
        //Core Data
        let fetchRequest = NSFetchRequest( entityName: "Word" )
        let sortDescriptor = NSSortDescriptor( key: "title", ascending: true )
        let managedObjCtx = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
        fetchRequest.sortDescriptors = [sortDescriptor]
        fetchResultsController = NSFetchedResultsController( fetchRequest: fetchRequest, managedObjectContext: managedObjCtx, sectionNameKeyPath: nil, cacheName: nil )
        fetchResultsController.delegate = self
        do{
            try fetchResultsController.performFetch()
            self.words = fetchResultsController.fetchedObjects as! [Word]
        }catch{
            print( error )
        }
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchController.active { return searchResults.count }
        else{ return words.count }
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("HomeCell", forIndexPath: indexPath) as! WordCell
        let word = searchController.active ? searchResults[indexPath.row] : words[indexPath.row]
        cell.title.text = word.title
        cell.desc.text = word.wordDescription
        cell.picture.image = UIImage(data: word.picture!)
        cell.picture.layer.cornerRadius = cell.picture.frame.size.width / 2
        cell.picture.clipsToBounds = true 
        return cell
    }

    // MARK: => Table View Delegate
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        if searchController.active { return false }
        else{ return true }
    }
    
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            let managedObjCtx = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
            let wordDelete = self.fetchResultsController.objectAtIndexPath(indexPath) as! Word
            managedObjCtx.deleteObject( wordDelete )
            do{ try managedObjCtx.save() }catch{ print("Delete Error: \(error)") }
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        }
    }
}

extension HomeTableViewController: NSFetchedResultsControllerDelegate {
    func controllerWillChangeContent(controller: NSFetchedResultsController) {
        tableView.beginUpdates()
    }
    
    func controller(controller: NSFetchedResultsController, didChangeObject anObject: NSManagedObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        switch type {
        case .Insert:
            tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: UITableViewRowAnimation.Fade )
        //case .Delete:
            //tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Fade )
        case .Update:
            tableView.reloadRowsAtIndexPaths([indexPath!], withRowAnimation: .Fade )
        default:
            tableView.reloadData()
        }
        words = controller.fetchedObjects as! [Word]
    }
    
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        tableView.endUpdates()
    }
}

extension HomeTableViewController: UISearchResultsUpdating {
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        let search = searchController.searchBar.text
        filterConentForSearchText( search! )
        tableView.reloadData()
    }
}
