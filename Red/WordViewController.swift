//
//  WordViewController.swift
//  Red
//
//  Created by AJ Ibraheem on 18/07/2015.
//  Copyright © 2015 The Leaf. All rights reserved.
//

import UIKit
import AVFoundation

class WordViewController: UIViewController {
    
    var word: Word!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var descriptionView: UITextView!
    @IBOutlet weak var playButton: UIButton!
    var audioPlayer: AVAudioPlayer!

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        //Set up View
        titleLabel.text = word.title
        descriptionView.text = word.wordDescription
        if let imgData = word.picture {
            imageView.image = UIImage( data: imgData )
        }
        if word.audio == nil { playButton.hidden = true }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func unwindToWordSegue( segue:UIStoryboardSegue ){
        print("Here ========>")
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "editWord" {
            let addVC = segue.destinationViewController as! AddViewController
            addVC.loadView()
            addVC.lastCell.hidden = false
            addVC.word = self.word
            addVC.folder = self.word.folder
        }
    }
    
    @IBAction func play( sender:UIButton ){
        let alert = UIAlertController(title: "Error", message: "Cannot Play Audio", preferredStyle: .Alert )
        let cancelAction = UIAlertAction(title: "Ok", style: .Cancel , handler: nil )
        alert.addAction( cancelAction )
        if self.audioPlayer != nil && self.audioPlayer.playing {
            //Stop Playing 😂
            self.audioPlayer.stop()
            playButton.setImage( UIImage(named: "play"), forState: .Normal )
        }else{
            do{
                if let fileData = word.audio {
                    self.audioPlayer = try AVAudioPlayer( data: fileData )
                    self.audioPlayer.delegate = self
                    self.audioPlayer.prepareToPlay()
                    if self.audioPlayer.play() {
                        playButton.setImage(UIImage(named: "stop"), forState: .Normal)
                    }else{
                        presentViewController(alert, animated: true, completion: nil)
                    }
                }
            }catch{
                alert.message = "Cannot access file on disk"
                presentViewController(alert, animated: true, completion: nil)
            }
        }
    }

}

extension WordViewController: AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(player: AVAudioPlayer, successfully flag: Bool) {
        if flag { playButton.setImage(UIImage(named: "play"), forState: .Normal) }
    }
}
