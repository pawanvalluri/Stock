//
//  ViewController.swift
//  Stock
//
//  Created by Pawan Valluri on 4/13/16.
//  Copyright © 2016 Pawan Valluri. All rights reserved.
//
import UIKit
import Alamofire
import SwiftyJSON
import CoreData
import Foundation
import MapKit

class ViewController: UIViewController, UITextFieldDelegate, UITableViewDataSource, UITableViewDelegate {
    
    private var responseData:NSMutableData?
    private var selectedPointAnnotation:MKPointAnnotation?
    private var dataTask:NSURLSessionDataTask?
    var symbolUsed = ""
    var locationCount = 1
    
    @IBOutlet weak var inputField: AutoCompleteTextField!
    var people=[NSManagedObject]()
    
    @IBOutlet weak var tableVIew: UITableView!
    
    @IBOutlet weak var toggle: UISwitch!
    var timer1: NSTimer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.inputField.delegate = self
        
        tableVIew.registerClass(UITableViewCell.self,
                                forCellReuseIdentifier: "cell")
        self.tableVIew.estimatedRowHeight = 50
        self.tableVIew.rowHeight = UITableViewAutomaticDimension;
        configureTextField()
        handleTextFieldInterfaces()
        self.tableVIew.setNeedsLayout()
        self.tableVIew.layoutIfNeeded()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        
        let appDelegate =
            UIApplication.sharedApplication().delegate as! AppDelegate
        
        let managedContext = appDelegate.managedObjectContext
        
        let fetchRequest = NSFetchRequest(entityName: "Person")
        
        do {
            let results =
                try managedContext.executeFetchRequest(fetchRequest)
            people = results as! [NSManagedObject]
            //print("viewWillAppear.people.count=" + String(people.count))
            
            self.tableVIew.layoutSubviews()
            self.tableVIew.reloadData()
            
        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
        }
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return false
    }
    
    @IBAction func getQuote(sender: UIButton) {
        print("in")
        if self.locationCount <= 0 {
            displayAlert("No Stock Symbol Found.")
        } else if let symbol: String = self.inputField.text where !symbol.isEmpty  {
            symbolUsed = self.inputField.text!
            performSegueWithIdentifier("showDetails", sender: self)
            
        } else {
            displayAlert("Please Enter a Stock Name or Symbol.")
        }
        print("out")
        self.inputField.resignFirstResponder()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let tabController = segue.destinationViewController as! TabController
        tabController.symbol = self.symbolUsed.characters.split{$0 == "-"}.map(String.init)[0]
        tabController.favs = people
    }
    
    func displayAlert(title: String) {
        let alert: UIAlertController = UIAlertController(title: title, message: "", preferredStyle: UIAlertControllerStyle.Alert)
        let action: UIAlertAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default) { (UIAlertAction) in
            print("Alert: " + title)
        }
        alert.addAction(action)
        self.presentViewController(alert, animated: true) {
        }
    }
    
    //
    @IBAction func toggleFunc(sender: UISwitch) {
        if toggle.on{
            refresh()
            print("switch on")
        }
        else{
            if timer1 != nil{
                stopTimer(timer1!)
            }
            print("switch off")
            
        }
    }
    
    @IBAction func refreshOnce(sender: AnyObject) {
        refreshOnlyOnce()
    }
    
    func refresh(){
        timer1=NSTimer.scheduledTimerWithTimeInterval(10.0, target: self, selector: #selector(ViewController.refreshOnlyOnce), userInfo: nil, repeats: true)
        
        print("refreshing...")
    }
    
    func refreshOnlyOnce(){
        print("refreshing once")
        tableVIew.reloadData()
    }
    
    func stopTimer(timer: NSTimer){
        timer1?.invalidate()
        timer1 = nil
        print("stoping...")
    }
    
    func makeCall(parameters: [String: AnyObject], completionHandler: (JSON, NSError?) -> ()) {
        let url = "https://inbound-rock-127222.appspot.com/stockDetails.php"
        Alamofire.request(.GET, url, parameters: parameters).validate().responseJSON { response in
            switch response.result {
            case .Success:
                if let json = response.result.value {
                    let val = JSON(json)
                    //print("JSON: \(val)")
                    
                    if let status = val["Status"].string where status == "SUCCESS" {
                        completionHandler(val, nil)
                    }
                }
                break;
            case .Failure(let error):
                completionHandler(nil, error)
            }
        }
    }
    
    func tableView(tableView: UITableView,
                   numberOfRowsInSection section: Int) -> Int {
        return people.count
    }
    
    func tableView(tableView: UITableView,
                   cellForRowAtIndexPath
        indexPath: NSIndexPath) -> UITableViewCell {
        
        /*
         print("I in tableView here....")
         for elem in people{
         print("ELE="+String(elem))
         }
         */
        let cell:FavTableValueCell = tableView.dequeueReusableCellWithIdentifier("favCell", forIndexPath: indexPath) as! FavTableValueCell
        let person=people[indexPath.row]
        
        let symbol = person.valueForKey("name") as! String
        cell.StockName.text = person.valueForKey("name") as? String
        
        let parameters = ["op": "quote", "symbol": symbol]
        print("Making JSON CALL")
        makeCall(parameters) { responseObject, error in
            let result = responseObject
            print(String(result["Name"]))
            
            cell.companyName.text=String(result["Name"])
            let price=String(format:"%.2f", Double(String(result["LastPrice"]))!)
            print(price)
            cell.stockPrice.text="$ "+price
            
            let market=Double(String(result["MarketCap"]))!
            var cap=1.00
            var marketCap=""
            print(market)
            if market > 1000000000 {
                cap = market / 1000000000
                marketCap = "Billion"
            } else if (market > 1000000){
                cap = market / 1000000;
                marketCap = "Million";
            } else {
                cap=market
                marketCap=""
            }
            let r = String(format: "%.2f", cap)
            cell.MarketCap.text="Market Cap: "+r+" "+marketCap
            
            let change=Double(String(result["Change"]))!
            let changePer=Double(String(result["ChangePercent"]))!
            let red=UIColor(red: 100,
                            green: 0,
                            blue: 0,
                            alpha: 1)
            
            if change<0 {
                cell.changePer.backgroundColor=red
            } else{
                cell.changePer.backgroundColor=UIColor(red: 0, green: 100, blue: 0, alpha: 1)
            }
            
            cell.changePer.text=String(format:"%.2f",change)+"("+String(format:"%.2f",changePer)+"%)"
        }
        
        return cell
    }
    
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let person=people[indexPath.row]
        let symbol = person.valueForKey("name") as! String
        print("Selected:" + String(indexPath.row) + ":" + symbol)
        symbolUsed = symbol
        performSegueWithIdentifier("showDetails", sender: self)
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath)
    {
        if editingStyle == .Delete
        {
            let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
            let moc = appDelegate.managedObjectContext
            
            // 3
            moc.deleteObject(people[indexPath.row])
            appDelegate.saveContext()
            
            // 4
            people.removeAtIndex(indexPath.row)
            tableVIew.reloadData()
        }
    }
    
    //Autocomplete
    private func configureTextField(){
        inputField.autoCompleteTextFont = UIFont(name: "HelveticaNeue-Light", size: 15.0)!
        inputField.autoCompleteCellHeight = 25.0
        inputField.maximumAutoCompleteCount = 20
        inputField.hidesWhenSelected = true
        inputField.hidesWhenEmpty = true
        inputField.enableAttributedText = false
    }
    
    private func handleTextFieldInterfaces(){
        inputField.onTextChange = {[weak self] text in
            if !text.isEmpty && text.characters.count >= 3{
                if let dataTask = self?.dataTask {
                    dataTask.cancel()
                }
                self?.fetchAutocompletePlaces(text)
                if self!.locationCount == 0 {
                    self!.displayAlert("No Stock Symbol Found")
                }
            }
        }
        
        
    }
    
    private func fetchAutocompletePlaces(keyword:String) {
        let postEndpoint: String = "https://inbound-rock-127222.appspot.com/stockDetails.php?op=lookup&input=\(keyword)"
        
        if let url = NSURL(string: postEndpoint) {
            let request = NSURLRequest(URL: url)
            dataTask = NSURLSession.sharedSession().dataTaskWithRequest(request, completionHandler: { (data, response, error) -> Void in
                if let data = data {
                    
                    do {
                        let result = try NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments)
                        print(result)
                        
                        var locations = [String]() //A string array
                        for dict in result as! [NSDictionary]{
                            locations.append(String(dict["Symbol"]!)+"-"+String(dict["Name"]!)+"-"+String(dict["Exchange"]!))
                        }
                        
                        dispatch_async(dispatch_get_main_queue(), { () -> Void in
                            self.inputField.autoCompleteStrings = locations
                        })
                        
                        self.locationCount = locations.count
                    }
                    catch let error as NSError{
                        print("Error: \(error.localizedDescription)")
                    }
                }
            })
            dataTask?.resume()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

