//
//  TabController.swift
//  Stock
//
//  Created by Pawan Valluri on 5/2/16.
//  Copyright © 2016 Pawan Valluri. All rights reserved.
//

import Alamofire
import SwiftyJSON
import CoreData
import Foundation


extension Double {
    /// Rounds the double to decimal places value
    func roundToPlaces(places:Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return round(self * divisor) / divisor
    }
}

class CurrentStockController: DetailsController, UITableViewDataSource, UITableViewDelegate, FBSDKLoginButtonDelegate {
    @IBOutlet weak var favBUtton: UIButton!
    
    var red: UIImage!
    var green: UIImage!
    var stockPrest:Bool=false
    var key:NSManagedObject!
    var fullName: String! = ""
    var stockPrice: String! = ""
    var stockImagePic:UIImage!
    
    @IBOutlet weak var tableView1: UITableView!
    
    func getDataFromUrl(url:NSURL, completion: ((data: NSData?, response: NSURLResponse?, error: NSError? ) -> Void)) {
        NSURLSession.sharedSession().dataTaskWithURL(url) { (data, response, error) in
            completion(data: data, response: response, error: error)
            }.resume()
    }
    override func viewDidLoad() {
        tableView1.estimatedRowHeight=200.0
        tableView1.rowHeight=UITableViewAutomaticDimension
        super.viewDidLoad()
        red=UIImage(named: "Down-52.pmg")
        green=UIImage(named: "Up-52.pmg")
        
        if(data["LastPrice"]) {
            fullName = String(data["Name"])
            let temp = Double(String(data["LastPrice"]))?.roundToPlaces(2)
            stockPrice = String(temp!)
        }
        
        for elem in favs {
            let symbol1 = elem.valueForKey("name") as! String
            //print("SYMBOL TRYING TOOO MATCH...")
            if symbol1 == symbol{
                //print("MATCH FOUND...!")
                key=elem
                stockPrest=true
                favBUtton.setImage(UIImage(named: "Star Filled-50"), forState: UIControlState.Normal)
                
            }
            else{
                stockPrest=false
            }
        }
        
        fbMyButton.addTarget(self, action: #selector(self.postFacebook(_:)), forControlEvents: .TouchUpInside)
        
        
        if (FBSDKAccessToken.currentAccessToken() != nil)
        {
            let loginView : FBSDKLoginButton = FBSDKLoginButton()
            //self.view.addSubview(loginView)
            loginView.center = self.view.center
            loginView.readPermissions = ["public_profile", "email", "user_friends"]
            loginView.delegate = self
            self.returnUserData()
            self.showShareButtons()
        }
        else
        {
            let loginView : FBSDKLoginButton = FBSDKLoginButton()
            //self.view.addSubview(loginView)
            loginView.center = self.view.center
            loginView.readPermissions = ["public_profile", "email", "user_friends"]
            loginView.delegate = self
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 12
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        //cell.userInteractionEnabled = false
        let cell = tableView.dequeueReusableCellWithIdentifier("currentStockCell") as! CurrentStockTableViewCell
        let fromdateFormatter = NSDateFormatter()
        let todateFormatter = NSDateFormatter()
        
        fromdateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'"
        todateFormatter.dateFormat = "MM-dd-yyyy HH:mm"
        
        cell.imag.image = nil
        
        if(indexPath.row == 0) {
            cell.labelInsideCell.text = "Name"
            cell.labelRightInsideCell.text = data["Name"].string
        }
        else if(indexPath.row == 1){
            cell.labelInsideCell.text = "Symbol"
            cell.labelRightInsideCell.text = data["Symbol"].string
        }
        else if(indexPath.row == 2 && data["LastPrice"]){
            let price = Double(String(data["LastPrice"]))?.roundToPlaces(2)
            cell.labelInsideCell.text = "Last Price"
            cell.labelRightInsideCell.text = "$ " + String(price!)
        } else if(indexPath.row == 3 && data["Change"]){
            cell.labelInsideCell.text = "Change"
            let change = Double(String(data["Change"]))?.roundToPlaces(2)
            let changePer = Double(String(data["ChangePercent"]))?.roundToPlaces(2)
            
            cell.labelRightInsideCell.text=String(change!)+"("+String(changePer!)+"%)"
            
            if changePer > 0 {
                cell.imag.image=UIImage(named: "Up-52.png")}
            else if changePer < 0 {
                cell.imag.image=UIImage(named: "Down-52.png")
            }
        }
        else if(indexPath.row == 4 && data["High"]){
            cell.labelInsideCell.text = "Time And Date"
            let dateFormatter = NSDateFormatter()
            //dateFormatter.locale = NSLocale.currentLocale()
            dateFormatter.dateStyle = NSDateFormatterStyle.MediumStyle
            //dateFormatter.timeStyle = .ShortStyle
            dateFormatter.dateFormat = "EEE MMM d kk:mm:ss ZZZZ yyyy"
            
            let dateAsString = String(data["Timestamp"])
            print(dateAsString)
            let newDate = dateFormatter.dateFromString(dateAsString)!
            
            dateFormatter.dateFormat = "MMM d yyyy kk:mm"///this is you want to convert format
            dateFormatter.timeZone = NSTimeZone(name: "PDT")
            let timeStamp = dateFormatter.stringFromDate(newDate)
            cell.labelRightInsideCell.text = String(timeStamp)//self.data[0]//["Status"]
        }
        else if(indexPath.row == 5 && data["MarketCap"]){
            cell.labelInsideCell.text = "Market cap"
            let market=Double(String(data["MarketCap"]))
            print("market = \(market)")
            var cap=1.00
            var marketCap=""
            print(market)
            if market > 1000000000 {
                cap = market! / 1000000000
                marketCap = "Billion"
            } else if (market > 1000000){
                cap = market! / 1000000;
                marketCap = "Million";
            } else {
                cap=market!
                marketCap=""
            }
            let r=String(format: "%.2f", cap)
            //cell.labelRightInsideCell.text="Market Cap: "+r+" "+marketCap
            
            cell.labelRightInsideCell.text = "$ " + r+" "+marketCap// as? String //self.data[0]//["Status"]
        } else if(indexPath.row == 6){
            cell.labelInsideCell.text = "Volume"
            cell.labelRightInsideCell.text = String(data["Volume"])// as? String //self.data[0]//["Status"]
        } else if(indexPath.row == 7 && data["ChangeYTD"]){
            cell.labelInsideCell.text = "Change YTD"
            
            let change=Double(String(data["ChangeYTD"]))
            let changePer=Double(String(data["ChangePercentYTD"]))
            
            if changePer > 0 {
                cell.imag.image=UIImage(named: "Up-52.png")}
            else if changePer < 0 {
                cell.imag.image=UIImage(named: "Down-52.png")
            }
            
            cell.labelRightInsideCell.text=String(format:"%.2f",change!)+"("+String(format:"%.2f",changePer!)+"%)"
        } else if(indexPath.row == 8 && data["High"]){
            cell.labelInsideCell.text = "High Price"
            cell.labelRightInsideCell.text = "$ " + String(Double(String(data["High"]))!.roundToPlaces(2))// as? String //self.data[0]//["Status"]
        } else if(indexPath.row == 9 && data["Low"]){
            cell.labelInsideCell.text = "Low Price"
            cell.labelRightInsideCell.text = "$ " + String(Double(String(data["Low"]))!.roundToPlaces(2))// as? String //self.data[0]//["Status"]
        } else if(indexPath.row == 10 && data["Open"]){
            cell.labelInsideCell.text = "Opening Price"
            cell.labelRightInsideCell.text = "$ " + String(data["Open"])// as? String //self.data[0]//["Status"]
        } else if(indexPath.row == 11){
            let url=NSURL(string: "http://chart.finance.yahoo.com/t?s="+symbol+"&lang=en-US&width=300&height=300")
            let data=NSData(contentsOfURL: url!)
            
            let cell2:stockImage = tableView.dequeueReusableCellWithIdentifier("Cell2", forIndexPath: indexPath) as! stockImage
            cell2.stockImage.image = UIImage(data: data!)
            cell2.stockImage.contentMode = .ScaleAspectFill
            
            return cell2
        } else {
            cell.labelInsideCell.text = "Undefined"
            cell.labelRightInsideCell.text = "Undefined"
        }
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
    }
    
    
    @IBAction func changeFav(sender: UIButton) {
        if stockPrest == false{
            print("adding....")
            saveName(symbol.uppercaseString)
            favBUtton.setImage(UIImage(named: "Star Filled-50"), forState: UIControlState.Normal)
            stockPrest=true
        }
        else{
            print("deleteing")
            favBUtton.setImage(UIImage(named: "Star-50"), forState: UIControlState.Normal)
            print(symbol.uppercaseString)
            deleteName(symbol.uppercaseString)
            stockPrest=false
        }
    }
    func deleteName(name:String){
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let moc = appDelegate.managedObjectContext
        
        moc.deleteObject(key)
        appDelegate.saveContext()
        
        if((favs.indexOf(key)) != nil) {
            favs.removeAtIndex(favs.indexOf(key)!)
            //people.removeAtIndex(indexPath.row)
            //tableVIew.reloadData()
        }
    }
    func saveName(name: String) {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        
        let managedContext = appDelegate.managedObjectContext
        
        let entity =  NSEntityDescription.entityForName("Person",
                                                        inManagedObjectContext:managedContext)
        
        let fav = NSManagedObject(entity: entity!,
                                  insertIntoManagedObjectContext: managedContext)
        
        fav.setValue(name, forKey: "name")
        
        do {
            try managedContext.save()
            favs.append(fav)
            print("Saved: " + name)
            
            for elem in favs {
                let symbol1 = elem.valueForKey("name") as! String
                print("SYMBOL TRYING TOOO MATCH...")
                if symbol1 == symbol{
                    print("MATCH FOUND...!")
                    key=elem
                    stockPrest=true
                    favBUtton.setImage(UIImage(named: "Star Filled-50"), forState: UIControlState.Normal)
                    
                }
                else{
                    stockPrest=false
                }
            }
        } catch let error as NSError  {
            print("Could not save \(error), \(error.userInfo)")
        }
    }
    
    @IBOutlet weak var fbMyButton: UIButton!
    
    let shareButton = FBSDKShareButton()
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        let content = FBSDKShareLinkContent()
        
        let contentURL = "http://finance.yahoo.com/q?s=" + self.symbol
        let contentURLImage = "http://chart.finance.yahoo.com/t?s=" + self.symbol + "&lang=en-US&width=150&height=150"
        let contentTitle = "Current Stock Price of " + self.fullName + " is $ " + self.stockPrice
        let contentDescription = "Stock Information of " + self.fullName + "(" + self.symbol + ")"
        
        content.contentURL = NSURL(string: contentURL)
        content.contentTitle = contentTitle
        content.contentDescription = contentDescription
        content.imageURL = NSURL(string: contentURLImage)
        
        
        shareButton.shareContent = content
        shareButton.frame = CGRectMake((UIScreen.mainScreen().bounds.width - 100) * 0.5, 50, 100, 25)
        //self.view.addSubview(shareButton)
    }
    
    @IBAction func postFacebook(sender: UIButton) {
        shareButton.sendActionsForControlEvents(.TouchUpInside)
        
    }
    
    // Facebook Delegate Methods
    
    func loginButton(loginButton: FBSDKLoginButton!, didCompleteWithResult result: FBSDKLoginManagerLoginResult!, error: NSError!) {
        print("User Logged In")
        
        if ((error) != nil) {
            // Process error
        } else if result.isCancelled {
            // Handle cancellations
        } else {
            // If you ask for multiple permissions at once, you
            // should check if specific permissions missing
            if result.grantedPermissions.contains("email") {
                // Do work
            }
            
            self.returnUserData()
            self.showShareButtons()
        }
    }
    
    func loginButtonDidLogOut(loginButton: FBSDKLoginButton!) {
        print("User Logged Out")
    }
    
    func returnUserData() {
        let graphRequest : FBSDKGraphRequest = FBSDKGraphRequest(graphPath: "me", parameters: nil)
        graphRequest.startWithCompletionHandler({ (connection, result, error) -> Void in
            
            if ((error) != nil) {
                // Process error
                print("Error: \(error)")
            } else {
                print("fetched user: \(result)")
                let userName : NSString = result.valueForKey("name") as! NSString
                print("User Name is: \(userName)")
                //let userEmail : NSString = result.valueForKey("email") as! NSString
                //print("User Email is: \(userEmail)")
            }
        })
    }
    
    
    func showShareButtons() {
        self.showLinkButton()
    }
    
    // Link Methods
    
    func showLinkButton() {
        
        let contentURL = "http://finance.yahoo.com/q?s=" + self.symbol
        let contentURLImage = "http://chart.finance.yahoo.com/t?s=" + self.symbol + "&lang=en-US&width=150&height=150"
        let contentTitle = "Current Stock Price of " + self.fullName + " is $ " + self.stockPrice
        let contentDescription = "Stock Information of " + self.fullName + "(" + self.symbol + ")"
        
        let content : FBSDKShareLinkContent = FBSDKShareLinkContent()
        content.contentURL = NSURL(string: contentURL)
        content.contentTitle = contentTitle
        content.contentDescription = contentDescription
        content.imageURL = NSURL(string: contentURLImage)
        
        // let button1 : fbMyButton = FBSDKLoginButton()
        let button = FBSDKShareButton()
        button.shareContent = content
        button.frame = CGRectMake((UIScreen.mainScreen().bounds.width - 100) * 0.5, 50, 100, 25)
        //self.view.addSubview(button)
        
        let label : UILabel = UILabel()
        label.frame = CGRectMake((UIScreen.mainScreen().bounds.width - 200) * 0.5, 25, 200, 25)
        label.text = "Link Example"
        label.textAlignment = .Center
        //self.view.addSubview(label)
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}


