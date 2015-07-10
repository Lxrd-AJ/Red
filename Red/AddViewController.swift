//
//  AddViewController.swift
//  Red
//
//  Created by AJ Ibraheem on 10/07/2015.
//  Copyright © 2015 The Leaf. All rights reserved.
//

import UIKit
import AVFoundation
import CoreData

class AddViewController: UITableViewController {
    
    let alert = UIAlertController( title: "Error", message: "Something Went Wrong", preferredStyle: .Alert )
    let cancelAction = UIAlertAction( title: "Ok", style: .Cancel , handler: nil )
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var titleField: UITextField!
    @IBOutlet weak var descriptionField: UITextView!
    @IBOutlet weak var audioLabel: UILabel!
    @IBOutlet weak var recordButton: UIButton!
    @IBOutlet weak var playButton: UIButton!
    var audioURL: NSURL!
    var audioSettings: [String:AnyObject]!
    var audioRecorder: AVAudioRecorder!
    var audioPlayer: AVAudioPlayer!
    var word: Word!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.tableFooterView = UIView()
        imageView.layer.cornerRadius = imageView.frame.size.width / 2
        alert.addAction( cancelAction )
        self.playButton.hidden = true
        
        //Audio Permissions
        do{
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(AVAudioSessionCategoryPlayAndRecord, withOptions: .DuckOthers)
            try session.setActive(true)
            session.requestRecordPermission{ [weak self](allowed: Bool) in
                if allowed {
                    //Show Recording UI
                    self!.recordButton.hidden = false
                }else{
                    //No Permission
                    self!.recordButton.hidden = true
                    self!.alert.message = "We do not have Permission to Record audio"
                    self!.presentViewController(self!.alert, animated: true, completion: nil)
                }
            }

        }catch{
            alert.message = "\((error as NSError).localizedDescription)"
            presentViewController(alert, animated: true, completion: nil)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func tableView(tableView: UITableView, didDeselectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.row == 0 { //Image Selected
            if UIImagePickerController.isSourceTypeAvailable( .PhotoLibrary ) {
                let imagePicker = UIImagePickerController()
                imagePicker.allowsEditing = true
                imagePicker.sourceType = .PhotoLibrary
                imagePicker.delegate = self
                self.presentViewController( imagePicker, animated: true, completion: nil )
            }else{
                //Error: Cannot access image Lib
                alert.message = "Cannot Access the image Library"
                presentViewController( alert, animated: true, completion: nil )
            }
        }
        tableView.deselectRowAtIndexPath( indexPath, animated: true )
    }
    
    @IBAction func save(){
        //Check for the important ones
        if( titleField.text == "" ){
            alert.message = "You Have to enter at least a title before saving a Word"
            presentViewController(alert, animated: true, completion: nil)
        }else{
            let managedObjContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
            self.word = NSEntityDescription.insertNewObjectForEntityForName("Word", inManagedObjectContext: managedObjContext) as! Word
            self.word.title = titleField.text
            self.word.wordDescription = descriptionField.text
            self.word.picture = UIImagePNGRepresentation( self.imageView.image! )
            if self.audioURL != nil {
                self.word.audio = NSData( contentsOfURL: self.audioURL )
            }
            //Save to DB
            do{ try managedObjContext.save() }
            catch{ print("Insertion Error:\((error as NSError).localizedDescription)") }
            //Close up
            defer{ self.navigationController?.dismissViewControllerAnimated(true , completion: nil) }
        }
    }
    
    @IBAction func record( sender:AnyObject ){
        //check if already recording
        if self.audioRecorder != nil && self.audioRecorder.recording {
            if self.audioRecorder.recording {
                stopRecording()
                self.recordButton.setTitle("Record", forState: .Normal )
                self.playButton.hidden = false
                self.audioLabel.text = titleField.text
            }
        }else{
            //Get a path for the audioURL
            do{
                alert.message = "Cannot access the File System"
                let fileURL = try NSFileManager().URLForDirectory(.DocumentDirectory, inDomain: .UserDomainMask, appropriateForURL: nil, create: false )
                if titleField.text != "" {
                    audioURL = fileURL.URLByAppendingPathComponent("\(titleField!.text).m4a")
                    print(audioURL)
                    //Audio Recording Settings
                    audioSettings = [ AVFormatIDKey: Int(kAudioFormatMPEG4AAC) ,
                        AVSampleRateKey: 16000.0 as NSNumber,
                        AVNumberOfChannelsKey: 1 as NSNumber,
                        AVEncoderAudioQualityKey: AVAudioQuality.Medium.rawValue as NSNumber
                    ]
                    do{
                        try self.startRecording( self.audioURL, settings: self.audioSettings)
                        self.recordButton.setTitle("Stop", forState: .Normal )
                    }catch{
                        alert.message = "Failed to Record"
                        self.presentViewController(alert, animated: true, completion: nil)
                    }

                }else{ alert.message = "Enter a Title First"; presentViewController(alert, animated: true, completion: nil) }
            }
            catch{
                presentViewController(alert, animated: true, completion: nil)
            }
        }
    }
    
    @IBAction func play( sender:AnyObject ){
        if self.audioRecorder.recording {
            alert.message = "Cannot Play Whilst Recording"
            presentViewController(alert, animated: true, completion: nil)
        }else if self.audioPlayer != nil && self.audioPlayer.playing {
            //Stop Playing 😂
            self.audioPlayer.stop()
            self.playButton.setTitle("Play", forState: .Normal )
        }else{
            do{
                let fileData = try NSData( contentsOfURL: self.audioURL, options: .MappedRead )
                self.audioPlayer = try AVAudioPlayer( data: fileData )
                self.audioPlayer.delegate = self
                self.audioPlayer.prepareToPlay()
                if self.audioPlayer.play() {
                    self.playButton.setTitle("Stop", forState: .Normal )
                }else{
                    alert.message = "Cannot Play Audio"
                    presentViewController(alert, animated: true, completion: nil)
                }
            }catch{
                alert.message = "Cannot access file on disk"
                presentViewController(alert, animated: true, completion: nil)
            }
        }
    }
    
    func startRecording( url:NSURL, settings:[String:AnyObject] ) throws {
        do{
            try self.audioRecorder = AVAudioRecorder(URL: url, settings: settings)
            audioRecorder.delegate = self
            //Prepare the recorder and start recording
            if audioRecorder.prepareToRecord() && audioRecorder.record() {
                print("Started Recording ......")
            }else{ throw NSError( domain: "com.TheLeaf.Red", code: 0, userInfo: nil ) }
        }catch{ throw error }
    }
    
    func stopRecording(){
        if self.audioRecorder.recording {
            self.audioRecorder.stop()
            print("Stopped Recording")
        }else{ print("Not Recording") }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "cancelAdd" {
            //Do all necessary cleanUp here
            print("Cleaning........")
            //Remove Audio File at location
            if self.audioURL != nil {
                do{ try NSFileManager.defaultManager().removeItemAtURL( self.audioURL ) }
                catch{ print(error) }
            }
        }
    }

}

extension AddViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
        imageView.image = image
        imageView.contentMode = .ScaleAspectFill
        imageView.clipsToBounds = true
        dismissViewControllerAnimated( true, completion: nil )
    }
}

extension AddViewController: AVAudioRecorderDelegate, AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(player: AVAudioPlayer, successfully flag: Bool) {
        if flag {
            self.playButton.setTitle("Play", forState: .Normal )
        }else{ print("Audio Player did not finish Properly") }
    }
}
