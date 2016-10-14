//
//  FullScreenPhotoViewController.swift
//  codepath-tumblrfeed
//
//  Created by Ernest on 10/14/16.
//  Copyright © 2016 Purpleblue Pty Ltd. All rights reserved.
//

import UIKit

class FullScreenPhotoViewController: UIViewController, UIScrollViewDelegate {
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var photoImageView: UIImageView!
    var photoImage: UIImage!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        scrollView.delegate = self
        
        photoImageView.image = photoImage
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return photoImageView
    }
    
    // Zooming in scroll view
    // Ref: https://courses.codepath.com/courses/ios_for_designers/pages/using_uiscrollview#heading-zooming-in-scroll-view
    @IBAction func closeModal(sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
}
