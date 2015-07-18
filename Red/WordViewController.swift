//
//  WordViewController.swift
//  Red
//
//  Created by AJ Ibraheem on 18/07/2015.
//  Copyright © 2015 The Leaf. All rights reserved.
//

import UIKit

class WordViewController: UIViewController {
    
    var word: Word!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var descriptionView: UITextView!
    @IBOutlet weak var playButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        //Set up View
        titleLabel.text = word.title
        descriptionView.text = word.wordDescription
        if let imgData = word.picture {
            imageView.image = UIImage( data: imgData )
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
