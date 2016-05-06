//
//  NewsFeedController.swift
//  Stock
//
//  Created by Pawan Valluri on 5/2/16.
//  Copyright © 2016 Pawan Valluri. All rights reserved.
//

import Alamofire
import SwiftyJSON

class NewsFeedController: DetailsController, UITableViewDataSource, UITableViewDelegate {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data["d"]["results"].count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("newsFeedCell") as! NewsFeedTableViewCell
        let fromdateFormatter = NSDateFormatter()
        let todateFormatter = NSDateFormatter()
        
        fromdateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'"
        todateFormatter.dateFormat = "MM-dd-yyyy HH:mm"
        
         
         if let tempVar = self.data["d"]["results"][indexPath.row]["Title"].string {
            cell.HeadingBold.text = tempVar
         }
         
         if let tempVar = self.data["d"]["results"][indexPath.row]["Description"].string {
            cell.contentNews.text = tempVar
         }
         if let tempVar = self.data["d"]["results"][indexPath.row]["Source"].string {
            cell.siteName.text = tempVar
         }
         if let tempVar = self.data["d"]["results"][indexPath.row]["Date"].string {
            cell.timeStamp.text = todateFormatter.stringFromDate(fromdateFormatter.dateFromString(tempVar)!)
         }
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if let url = NSURL(string: self.data["d"]["results"][indexPath.row]["Url"].string!) {
            UIApplication.sharedApplication().openURL(url)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}


