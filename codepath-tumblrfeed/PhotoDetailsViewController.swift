//
//  PhotoDetailsViewController.swift
//  codepath-tumblrfeed
//
//  Created by Ernest on 10/13/16.
//  Copyright © 2016 Purpleblue Pty Ltd. All rights reserved.
//

import UIKit

class PhotoDetailsViewController: UIViewController {
    
    @IBOutlet weak var photoImageView: UIImageView!
    var photoImage: UIImage!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        photoImageView.image = photoImage
        
        // Ref: http://guides.codepath.com/ios/Using-Gesture-Recognizers
        // The didTap: method will be defined in Step 3 below.
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(didTap(sender:)))
        
        // Optionally set the number of required taps, e.g., 2 for a double click
        tapGestureRecognizer.numberOfTapsRequired = 2;
        
        // Attach it to a view of your choice. If it's a UIImageView, remember to enable user interaction
        photoImageView.isUserInteractionEnabled = true
        photoImageView.addGestureRecognizer(tapGestureRecognizer)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func didTap(sender: UITapGestureRecognizer) {
        let location = sender.location(in: view)
        print(location)
        // User tapped at the point above. Do something with that if you want.
        
        // Ref: http://guides.codepath.com/ios/Using-Modal-Transitions#triggering-the-transition-manually
        performSegue(withIdentifier: "fullScreenSegue", sender: nil)
    }

    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get a reference to the PhotoDetailsViewController
        let destinationViewController = segue.destination as! FullScreenPhotoViewController
                
        // Pass the image through
        destinationViewController.photoImage = photoImageView.image
    }

}
