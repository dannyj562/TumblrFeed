//
//  PhotosViewController.swift
//  TumblrFeed
//
//  Created by Danny on 9/14/18.
//  Copyright © 2018 Danny Rivera. All rights reserved.
//

import UIKit
import AlamofireImage

class PhotosViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    
    let tumblrURL: String = "https://api.tumblr.com/v2/blog/humansofnewyork.tumblr.com/posts/photo?api_key=Q6vHoaVm5L1u2ZAW1fqv3Jw48gFzYVg9P0vH0VHl3GVy6quoGV"
    var posts: [[String: Any]] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        fetchNetworkRequest()
    }
    
    func fetchNetworkRequest() {
        // Network request snippet
        let url = URL(string: tumblrURL)!
        let session = URLSession(configuration: .default, delegate: nil, delegateQueue: OperationQueue.main)
        session.configuration.requestCachePolicy = .reloadIgnoringLocalCacheData
        let task = session.dataTask(with: url) { (data, response, error) in
            if let error = error {
                print(error.localizedDescription)
            } else if let data = data,
                let dataDictionary = try! JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                print(dataDictionary)
                // Get the dictionary from the response key
                let responseDictionary = dataDictionary["response"] as! [String: Any]
                // Store the returned array of dictionaries in our posts property
                self.posts = responseDictionary["posts"] as! [[String: Any]]
                self.tableView.reloadData()
                //self.tableView.estimatedRowHeight = 100
                //self.tableView.rowHeight = UITableViewAutomaticDimension
            }
        }
        task.resume()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PhotoCell", for: indexPath) as! PhotoCell
        let post = posts[indexPath.row]
        if let photos = post["photos"] as? [[String: Any]] {
            // photo is not nil so we can use it
            let photo = photos[0]
            let originalSize = photo["original_size"] as! [String: Any]
            let urlString = originalSize["url"] as! String
            let url = URL(string: urlString)
            cell.photoImageView.af_setImage(withURL: url!)
            cell.photoImageView.layoutSubviews()
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return tableView.frame.size.height
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Navigation
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ToFullScreenImage" {
            let cell = sender as! UITableViewCell
            if let indexPath = tableView.indexPath(for: cell) {
                let post = posts[indexPath.row]
                if let photos = post["photos"] as? [[String: Any]] {
                    // photo is not nil so we can use it
                    let photo = photos[0]
                    let originalSize = photo["original_size"] as! [String: Any]
                    let urlString = originalSize["url"] as! String
                    let url = URL(string: urlString)
                    tableView.deselectRow(at: indexPath, animated: true)
                    let photoDetailViewController = segue.destination as! PhotoDetailsViewController
                    photoDetailViewController.chosenImageURL = url
                }
 
            }
        }
        
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
}
