//
//  HomeViewController.swift
//  My Word Bank
//
//  Created by AJ Ibraheem on 25/07/2015.
//  Copyright © 2015 The Leaf. All rights reserved.
//

import UIKit
import CoreData

let ROOT_FOLDER: String = "RootFolder"

class HomeViewController: UIViewController {
    
    var words: [Word] = []
    var wordViews: [WordView] = []
    var folders: [Folder] = []
    var folderViews: [FolderView] = []
    var rootFolder: Folder?
    var animationColor: UIColor?
    var fetchResultsController: NSFetchedResultsController!
    let managedObjCtx = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
    let saveContext = (UIApplication.sharedApplication().delegate as! AppDelegate).saveContext

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        setupViewData()
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        self.wordViews.map({ $0.removeFromSuperview() })
        self.folderViews.map({ $0.removeFromSuperview() })
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "add" {
            let nav = segue.destinationViewController as! UINavigationController
            let addVC = nav.viewControllers[0] as! AddViewController
            addVC.folder = self.rootFolder
        }
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        let touch = touches.first!
        let touchedView = touch.view
        if let wordView = touchedView as? MyView {
            UIView.animateWithDuration(0.5, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 1, options: UIViewAnimationOptions.CurveEaseInOut, animations: {
                    self.view.bringSubviewToFront(wordView)
                    wordView.alpha = 0.9
            }, completion: nil)
        }
    }
    
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        let touch = touches.first!
        let touchedView = touch.view
        if let wordView = touchedView as? MyView{
            UIView.animateWithDuration(0.25, animations: {
                wordView.center = touch.locationInView(self.view)
            })
        }
        //Find all intersecting views
//        let intersectingViews = (self.view.subviews as! [MyView]).filter({ return CGRectIntersectsRect( touchedView!.frame, $0.frame) })
//        intersectingViews.map({ print( $0.index ) })
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if let touchedView = touches.first!.view as? MyView{
            UIView.animateWithDuration(0.5, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 1, options: UIViewAnimationOptions.CurveEaseInOut, animations: {
                self.view.bringSubviewToFront(touchedView)
                touchedView.alpha = 1
            }, completion: nil)
            var obj:NSManagedObject?
            if let _ = touchedView as? WordView { obj = self.words[ touchedView.index ] }
            if let _ = touchedView as? FolderView { obj = self.folders[ touchedView.index ] }
            saveObjectPosition(touchedView, obj: obj!)
        }
    }
    
    @IBAction func unwindToHome( segue:UIStoryboardSegue ){}
    
    @IBAction func createFolder(){
        let folderController = UIAlertController(title: "New Folder", message: "Enter Folder name", preferredStyle: .Alert )
        let cancelAction = UIAlertAction(title: "Cancel 👎🏾", style: .Destructive , handler: nil)
        let addAction = UIAlertAction(title: "Add 👍🏻", style: .Default , handler: { _ in
            let folderName = (folderController.textFields![0] as UITextField).text
            //Only create a folder if in ROOT_FOLDER #BusinessRule
            if self.rootFolder?.name == ROOT_FOLDER {
                let folder = Folder.createFolder( folderName!, ctx: self.managedObjCtx )
                if folder == nil { print("Failed to create Folder") }
                self.setupViewData()
                self.view.setNeedsDisplay()
            }else{
                let alert = UIAlertController(title: "Oops 😐", message: "You can't create a folder here, yet! 😉", preferredStyle: .Alert )
                alert.addAction( UIAlertAction(title: "Ok", style: .Cancel , handler: nil) )
                self.presentViewController(alert, animated: true, completion: nil)
            }
        })
        addAction.enabled = false
        folderController.addTextFieldWithConfigurationHandler({ (textField:UITextField) -> Void in
            textField.placeholder = "Folder Name"
            NSNotificationCenter.defaultCenter().addObserverForName(UITextFieldTextDidChangeNotification, object: textField, queue: NSOperationQueue.mainQueue(), usingBlock: { _ in addAction.enabled = true })
        })
        
        folderController.addAction( addAction )
        folderController.addAction( cancelAction )
        presentViewController( folderController, animated: true, completion: nil)
    }
    
    func setupViewData(){
        self.wordViews.map({ $0.removeFromSuperview() })
        self.folderViews.map({ $0.removeFromSuperview() })
        
        if rootFolder == nil {
            //Use Root folder
            rootFolder = fetchFolders(ROOT_FOLDER)[0]
            self.title = "Home 🏦"
        }
        if rootFolder?.name != ROOT_FOLDER {
            //if not a root folder
            let backButton:UIBarButtonItem = UIBarButtonItem(title: "🔙", style: .Plain, target: self, action: "popViewController:" )
            let settingsButton: UIBarButtonItem = UIBarButtonItem(image: UIImage(named: "settings")!, style: .Plain, target: self, action: "showFolderSettings:")
            self.navigationItem.leftBarButtonItems = [backButton, settingsButton]
            self.title = rootFolder?.name
        }else{
            //If it is a root folder
            self.folders = fetchFolders(nil)
        }
        
        self.words = rootFolder!.words!.allObjects as! [Word]
        self.wordViews = transformObjectsToViews(self.words) as! [WordView] //transformWordsToViews(self.words)
        self.folderViews = transformObjectsToViews(self.folders) as! [FolderView]
        
        self.folderViews.map({ self.view.addSubview($0) })
        self.wordViews.map({ self.view.addSubview($0) })
        
        self.wordViews.map({ (wView: WordView) -> Void in
            let tapGesture = UITapGestureRecognizer(target: self , action: "wordViewTapped:")
            wView.addGestureRecognizer(tapGesture)
        })
        self.folderViews.map({ (fView:FolderView) -> Void in
            let tapGesture = UITapGestureRecognizer(target: self, action: "folderViewTapped:")
            fView.addGestureRecognizer(tapGesture)
        })
    }
    
    @available(*,deprecated=1.0,message="Use fetchFolder instead") func fetchDataFromDB() -> [Word]{
        //Core Data
        let fetchRequest = NSFetchRequest( entityName: "Word" )
        //let sortDescriptor = NSSortDescriptor( key: "title", ascending: true )
        fetchRequest.sortDescriptors = []
        fetchResultsController = NSFetchedResultsController( fetchRequest: fetchRequest, managedObjectContext: managedObjCtx, sectionNameKeyPath: nil, cacheName: nil )
        fetchResultsController.delegate = self
        do{
            try fetchResultsController.performFetch()
            return fetchResultsController.fetchedObjects as! [Word]
        }catch{
            print( error )
            return []
        }
    }
    
    func fetchFolders( name:String? ) -> [Folder] {
        let fetchRequest = NSFetchRequest(entityName: "Folder")
        var predicate:NSPredicate
        if name != nil {
            predicate = NSPredicate(format: "name == %@", name!) //One F0ld3r to rule them all 😈
        }else{ predicate = NSPredicate(format: "name != %@", ROOT_FOLDER) }
        fetchRequest.predicate = predicate
        fetchRequest.sortDescriptors = []
        fetchResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: managedObjCtx, sectionNameKeyPath: nil, cacheName: nil)
        fetchResultsController.delegate = self
        do{
            try fetchResultsController.performFetch()
            return fetchResultsController.fetchedObjects as! [Folder]
        }catch{
            print("FETCH FOLDER ERROR: \(error)")
            return []
        }
    }
    
    func transformObjectsToViews( obj:[NSManagedObject] ) -> [MyView] {
        var result: [MyView]
        if let wordObj = obj as? [Word]{
            result = wordObj.map( createViewFromWord )
        }else if let folderObj = obj as? [Folder] {
            result = folderObj.map( createFolderViewFrom )
        }else{ return [] }
        
        var idx = 0
        for v in result { v.index = idx; idx++ }
        return result
    }
    
    func createViewFromWord( word:Word ) -> WordView {
        //Create the view
        let view = WordView.instanceFromNib()
        view.titleLabel.text = word.title
        if word.picture != nil { view.imageView.image = UIImage( data: word.picture! ) }
        if word.audio == nil { view.audioImageView.hidden = true }
        view.center = self.view.center
        view.imageView.layer.cornerRadius = 10
        view.frame.origin = CGPoint(x: CGFloat(word.x), y: CGFloat(word.y))
        return view
    }
    
    func createFolderViewFrom( folder:Folder ) -> FolderView {
        let view = FolderView.instanceFromNib()
        view.nameLabel.text = folder.name
        view.frame.origin = CGPoint(x: CGFloat(folder.x), y: CGFloat(folder.y))
        return view
    }
    
    func wordViewTapped( tapGesture:UITapGestureRecognizer ){
        let wordVC = self.storyboard?.instantiateViewControllerWithIdentifier("wordController") as! WordViewController
        let tappedWordView = tapGesture.view as! WordView
        wordVC.word = self.words[ tappedWordView.index ]
        UIView.animateWithDuration(0.1, delay: 0, options: .CurveEaseIn, animations: {
            tappedWordView.alpha = 0.1
            }, completion: { _ in tappedWordView.alpha = 1 })
        self.navigationController?.pushViewController(wordVC, animated: true)
    }
    
    func folderViewTapped( tapGesture:UITapGestureRecognizer ){
        let homeVC = self.storyboard?.instantiateViewControllerWithIdentifier("homeController") as! HomeViewController
        homeVC.rootFolder = self.folders[ (tapGesture.view as! FolderView).index ]
        self.navigationController?.pushViewController(homeVC, animated: true)
    }
    
    func popViewController( barButton:UIBarButtonItem ){
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    func showFolderSettings( barButton:UIBarButtonItem ){
        let alert = UIAlertController(title: "Yeah! 😷", message: "It does nothing for now 😁, but it ought to take care of all Folder related settings", preferredStyle: .Alert )
        let ok = UIAlertAction(title: "Ok", style: .Cancel , handler: nil )
        alert.addAction(ok)
        presentViewController(alert, animated: true, completion: nil)
    }
    
    func saveObjectPosition( objView:MyView, obj:NSManagedObject ){
        if let word = obj as? Word {
            let wordView = objView as! WordView
            word.x = Float(wordView.frame.origin.x)
            word.y = Float(wordView.frame.origin.y)
        }else if let folder = obj as? Folder {
            let folderView = objView as! FolderView
            folder.x = Float(folderView.frame.origin.x)
            folder.y = Float(folderView.frame.origin.y)
        }
        saveContext()
    }
    
}

extension HomeViewController: NSFetchedResultsControllerDelegate {
//    func controller(controller: NSFetchedResultsController, didChangeObject anObject: NSManagedObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
//        
//    }
}
