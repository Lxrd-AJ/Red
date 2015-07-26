//
//  HomeViewController.swift
//  My Word Bank
//
//  Created by AJ Ibraheem on 25/07/2015.
//  Copyright © 2015 The Leaf. All rights reserved.
//

import UIKit
import CoreData

class HomeViewController: UIViewController {
    
    var words: [Word] = []
    var wordViews: [WordView] = []
    var fetchResultsController: NSFetchedResultsController!
    let managedObjCtx = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
    let saveContext = (UIApplication.sharedApplication().delegate as! AppDelegate).saveContext

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.words = fetchDataFromDB()
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
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        let touch = touches.first!
        let touchedView = touch.view
        if let wordView = touchedView as? WordView{
            let size = wordView.frame.size
            let color = wordView.backgroundColor
            let animColor = UIColor( red: 245/255, green: 245/255, blue: 245/255, alpha: 0.85 )
            UIView.animateWithDuration(0.5, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 1, options: UIViewAnimationOptions.CurveEaseInOut, animations: {
                    self.view.bringSubviewToFront(wordView)
                    wordView.frame.size = CGSizeMake(size.width + 5, size.height + 5)
                    wordView.backgroundColor = animColor
            }, completion: { _ in
                UIView.animateWithDuration(0.2, animations: {
                    wordView.frame.size = CGSizeMake(size.width, size.height)
                    wordView.backgroundColor = color
                })
            })
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
            savePosition(wordView, word: self.words[ wordView.index ])
        }
    }
    
    @IBAction func unwindToHome( segue:UIStoryboardSegue ){}
    
    func fetchDataFromDB() -> [Word]{
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
    
    func transformWordsToViews( words:[Word] ) -> [WordView] {
        let result = words.map( createViewFromWord )
        var idx = 0
        for v in result { v.index = idx; idx++ }
        return result
//        var result: [WordView] = []
//        var idx = 0
//        for w in words {
//            let v = createViewFromWord(w)
//            v.index = idx; idx++;
//            result.append(v)
//        }
//        return result
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
        let tappedWord = tapGesture.view as! WordView
        wordVC.word = self.words[ tappedWord.index ]
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
