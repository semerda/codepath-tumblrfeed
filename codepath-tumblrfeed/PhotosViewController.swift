//
//  PhotosViewController.swift
//  codepath-tumblrfeed
//
//  Created by Ernest on 10/12/16.
//  Copyright © 2016 Purpleblue Pty Ltd. All rights reserved.
//

import UIKit
import AFNetworking

class PhotosViewController : UIViewController, UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    
    var isMoreDataLoading = false
    var loadingMoreView:InfiniteScrollActivityView?
    
    var posts : [NSDictionary]?
    
    // Initialize a UIRefreshControl
    let refreshControl = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        tableView.dataSource = self
        tableView.delegate = self
        
        // Adding Pull-to-Refresh
        // Ref: https://guides.codepath.com/ios/Table-View-Guide#adding-pull-to-refresh
        refreshControl.addTarget(self, action: #selector(refreshControlAction(refreshControl:)), for: UIControlEvents.valueChanged)
        // add refresh control to table view
        tableView.insertSubview(refreshControl, at: 0)
        
        // Set up Infinite Scroll loading indicator
        // Ref: https://guides.codepath.com/ios/Table-View-Guide#adding-infinite-scroll
        let frame = CGRect(x: 0, y: tableView.contentSize.height, width: tableView.bounds.size.width, height: InfiniteScrollActivityView.defaultHeight)
        loadingMoreView = InfiniteScrollActivityView(frame: frame)
        loadingMoreView!.isHidden = true
        tableView.addSubview(loadingMoreView!)
        
        var insets = tableView.contentInset;
        insets.bottom += InfiniteScrollActivityView.defaultHeight;
        tableView.contentInset = insets
        
        // Automatically resize row heights
        // http://guides.codepath.com/ios/Table-View-Quickstart#automatically-resize-row-heights
        //tableView.estimatedRowHeight = 100
        //tableView.rowHeight = UITableViewAutomaticDimension
        
        // Load data from API
        loadData()
        
        // Remove the separator inset
        // Ref: https://guides.codepath.com/ios/Table-View-Guide#how-do-you-remove-the-separator-inset
        self.tableView.separatorInset = UIEdgeInsets.zero
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func loadData() {
        // Source: https://api.tumblr.com/v2/blog/humansofnewyork.tumblr.com/posts/photo?page=2&api_key=Q6vHoaVm5L1u2ZAW1fqv3Jw48gFzYVg9P0vH0VHl3GVy6quoGV
        
        let apiKey = "Q6vHoaVm5L1u2ZAW1fqv3Jw48gFzYVg9P0vH0VHl3GVy6quoGV"
        let url = URL(string:"https://api.tumblr.com/v2/blog/humansofnewyork.tumblr.com/posts/photo?api_key=\(apiKey)")
        let request = URLRequest(url: url!)
        
        // Configure session so that completion handler is executed on main UI thread
        let session = URLSession(
            configuration: URLSessionConfiguration.default,
            delegate:nil,
            delegateQueue:OperationQueue.main
        )
        
        let task : URLSessionDataTask = session.dataTask(with: request,completionHandler: { (dataOrNil, response, error) in
            if let data = dataOrNil {
                if let responseDictionary = try! JSONSerialization.jsonObject(with: data, options:[]) as? NSDictionary {
                    NSLog("response: \(responseDictionary)")
                    
                    self.posts = responseDictionary.value(forKeyPath: "response.posts") as? [NSDictionary]
                    
                    // Update flag
                    self.isMoreDataLoading = false
                    
                    // Stop the loading indicator
                    self.loadingMoreView!.stopAnimating()
                    
                    // Reload the tableView now that there is new data
                    self.tableView.reloadData()
                    
                    // Tell the refreshControl to stop spinning
                    self.refreshControl.endRefreshing()
                }
            }
        });
        task.resume()
    }
    
    // Makes a network request to get updated data
    // Updates the tableView with the new data
    // Hides the RefreshControl
    func refreshControlAction(refreshControl: UIRefreshControl) {
        // Load data from API
        loadData()
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get a reference to the PhotoDetailsViewController
        let destinationViewController = segue.destination as! PhotoDetailsViewController
        
        // Get the indexPath of the selected photo
        let indexPath = tableView.indexPath(for: sender as! UITableViewCell)
        //print(indexPath)
        
        // Grab the image directly from cell otherwise we'd have to load it again using URL
        let cell = tableView.cellForRow(at: indexPath!) as! PhotoTableViewCell
        //print(cell)
        
        // Pass the image through
        destinationViewController.photoImage = cell.photoImageView.image
    }

    // MARK: - Table view data source & delegates
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "com.purpleblue.PhotoTableViewCell", for: indexPath) as! PhotoTableViewCell
        let post = self.posts?[indexPath.row]
        
        // Note the use of key path inc @firstObject since .url is a list when consumed
        let originalSizeUrl = post?.value(forKeyPath: "photos.original_size.url.@firstObject")
        print(originalSizeUrl!) // ! to unwrap the variable
        
        cell.photoImageView.setImageWith(URL(string: originalSizeUrl! as! String)!)
        
        return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return posts?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts?.count ?? 0 // old school: (posts ? posts.count : 0)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Get rid of the gray selection effect by deselecting the cell with animation
        tableView.deselectRow(at: indexPath as IndexPath, animated: true)
    }
    
    // Section header views
    // Ref: http://guides.codepath.com/ios/Table-View-Guide#section-header-views
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: 320, height: 50))
        headerView.backgroundColor = UIColor(white: 1, alpha: 0.9)
        
        let profileView = UIImageView(frame: CGRect(x: 10, y: 10, width: 30, height: 30))
        profileView.clipsToBounds = true
        profileView.layer.cornerRadius = 15;
        profileView.layer.borderColor = UIColor(white: 0.7, alpha: 0.8).cgColor
        profileView.layer.borderWidth = 1;
        
        // set the avatar
        profileView.setImageWith(NSURL(string:"https://api.tumblr.com/v2/blog/humansofnewyork.tumblr.com/avatar")! as URL)
        headerView.addSubview(profileView)
        
        // Add a UILabel for the date here
        // Use the section number to get the right URL
        let createdLabel = UILabel(frame: CGRect(x: 50, y: 10, width: 100, height: 30))
        createdLabel.text = self.posts?[section].value(forKeyPath: "date") as! String?
        headerView.addSubview(createdLabel)
        
        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 50;
    }
    
    // MARK: - Scroll view delegates
    
    // Add a loading view to your view controller
    // https://guides.codepath.com/ios/Table-View-Guide#add-a-loading-view-to-your-view-controller
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        // Handle scroll behavior here
        
        if (!isMoreDataLoading) {
            // Calculate the position of one screen length before the bottom of the results
            let scrollViewContentHeight = tableView.contentSize.height
            let scrollOffsetThreshold = scrollViewContentHeight - tableView.bounds.size.height
            
            // When the user has scrolled past the threshold, start requesting
            if(scrollView.contentOffset.y > scrollOffsetThreshold && tableView.isDragging) {
                isMoreDataLoading = true
                
                // Update position of loadingMoreView, and start loading indicator
                let frame = CGRect(x: 0, y: tableView.contentSize.height, width: tableView.bounds.size.width, height: InfiniteScrollActivityView.defaultHeight)
                loadingMoreView?.frame = frame
                loadingMoreView!.startAnimating()
                
                // ... Code to load more results ...
                loadData()
            }
        }
    }
}

