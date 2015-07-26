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
    var folder: Folder?
    var animationColor: UIColor?
    var fetchResultsController: NSFetchedResultsController!
    let managedObjCtx = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
    let saveContext = (UIApplication.sharedApplication().delegate as! AppDelegate).saveContext

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        if folder == nil {
            //Use Root folder
            folder = fetchFolders(ROOT_FOLDER)![0]
        }
        self.words = folder!.words!.allObjects as! [Word]
        self.wordViews = transformWordsToViews(self.words)
        self.wordViews.map({ self.view.addSubview($0) })
        self.wordViews.map({ (wView: WordView) -> Void in
            let tapGesture = UITapGestureRecognizer(target: self , action: "wordViewTapped:")
            wView.addGestureRecognizer(tapGesture)
        })
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        self.wordViews.map({ $0.removeFromSuperview() })
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "addWord" {
            let nav = segue.destinationViewController as! UINavigationController
            let addTVC = nav.viewControllers[0] as! AddTableViewController
            addTVC.folder = self.folder
        }
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        let touch = touches.first!
        let touchedView = touch.view
        if let wordView = touchedView as? WordView{
            UIView.animateWithDuration(0.5, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 1, options: UIViewAnimationOptions.CurveEaseInOut, animations: {
                    self.view.bringSubviewToFront(wordView)
                    wordView.alpha = 0.9
            }, completion: nil)
        }
    }
    
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        let touch = touches.first!
        let touchedView = touch.view
        if let wordView = touchedView as? WordView{
            UIView.animateWithDuration(0.25, animations: {
                wordView.center = touch.locationInView(self.view)
            })
        }
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        let touchedView = touches.first!.view
        if let wordView = touchedView as? WordView{
            UIView.animateWithDuration(0.5, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 1, options: UIViewAnimationOptions.CurveEaseInOut, animations: {
                self.view.bringSubviewToFront(wordView)
                wordView.alpha = 1
            }, completion: nil)
            savePosition(wordView, word: self.words[ wordView.index ])
        }
    }
    
    @IBAction func unwindToHome( segue:UIStoryboardSegue ){}
    
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
    
    func fetchFolders( name:String? ) -> [Folder]? {
        let fetchRequest = NSFetchRequest(entityName: "Folder")
        if name != nil {
            let predicate = NSPredicate(format: "name == %@", name!) //One F0ld3r to rule them all 😈
            fetchRequest.predicate = predicate
        }
        fetchRequest.sortDescriptors = []
        fetchResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: managedObjCtx, sectionNameKeyPath: nil, cacheName: nil)
        fetchResultsController.delegate = self
        do{
            try fetchResultsController.performFetch()
            return fetchResultsController.fetchedObjects as? [Folder]
        }catch{
            print("FETCH FOLDER ERROR: \(error)")
            return nil
        }
    }
    
    func transformWordsToViews( words:[Word] ) -> [WordView] {
        let result = words.map( createViewFromWord )
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
    
    func wordViewTapped( tapGesture:UITapGestureRecognizer ){
        let wordVC = self.storyboard?.instantiateViewControllerWithIdentifier("wordController") as! WordViewController
        let tappedWordView = tapGesture.view as! WordView
        wordVC.word = self.words[ tappedWordView.index ]
        UIView.animateWithDuration(0.1, delay: 0, options: .CurveEaseIn, animations: {
            tappedWordView.alpha = 0.1
            }, completion: { _ in tappedWordView.alpha = 1 })
        self.navigationController?.pushViewController(wordVC, animated: true)
    }
    
    func savePosition( wordView:WordView, word:Word ){
        word.x = Float(wordView.frame.origin.x)
        word.y = Float(wordView.frame.origin.y)
        saveContext()
    }
}

extension HomeViewController: NSFetchedResultsControllerDelegate {
    func controller(controller: NSFetchedResultsController, didChangeObject anObject: NSManagedObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        
    }
}
