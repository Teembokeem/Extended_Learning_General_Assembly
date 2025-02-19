//
//  ViewController.swift
//  REST
//
//  Created by Rudd Taylor on 2/25/15.
//  Copyright (c) 2015 ga. All rights reserved.
//

import UIKit

class ViewController: UITableViewController {
    var json: NSDictionary?
    var children: [NSDictionary]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func viewDidAppear(animated: Bool) {
        
        if let url = NSURL(string: "http://www.reddit.com/.json") {
            
            let task = NSURLSession.sharedSession().dataTaskWithURL(url, completionHandler: { (data, response, error) -> Void in
                
                if let data = data,
                    jsonDict = try? NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions()) as? NSDictionary {
                    self.json = jsonDict
                        
                        if let json = self.json {
                            if let data = json["data"] as? NSDictionary {
                                if let children = data["children"] as? NSArray {
                                    self.children = children as! [NSDictionary]
                                }
                            }
                        }
                    // Required! We must update the UI only on the main queue, but this completion handler gets run in the background queue!
                    dispatch_async(dispatch_get_main_queue(), {
                        self.tableView.reloadData()
                    })
                }                
            })
            
            
            // Required to start the network task
            task.resume()
        }
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let json = self.json {
            if let data = json["data"] as? NSDictionary {
                if let children = data["children"] as? NSArray {
                    return children.count
                }
            }
        }
        return 0
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier("cell") as UITableViewCell!
        if cell == nil  {
            cell = UITableViewCell(style: .Default, reuseIdentifier: "cell")
        }
        
        if let json = self.json {
            if let data = json["data"] as? NSDictionary {
                if let children = data["children"] as? NSArray {
                    if let child = children[indexPath.row] as? NSDictionary {
                        if let data = child["data"] as? NSDictionary {
                            if let title = data["title"] as? String {
                                cell.textLabel?.text = title
                            }
                        }
                    }
                }
            }
        }
        
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if let json = self.json {
            if let data = json["data"] as? NSDictionary {
                if let children = data["children"] as? NSArray {
                    if let child = children[indexPath.row] as? NSDictionary {
                        if let data = child["data"] as? NSDictionary {
                            if let permalink = data["permalink"] as? String {
                                if let url = NSURL(string: "http://reddit.com" + permalink) {
                                    performSegueWithIdentifier("web", sender: NSURLRequest(URL: url))
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let request = sender as? NSURLRequest {
            if let destinationViewController = segue.destinationViewController as? WebViewController {
                destinationViewController.request = request
            }
        }
    }
}

