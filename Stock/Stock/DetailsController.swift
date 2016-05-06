//
//  DetailsController.swift
//  Stock
//
//  Created by Pawan Valluri on 5/2/16.
//  Copyright © 2016 Pawan Valluri. All rights reserved.
//

import Alamofire
import SwiftyJSON
import CoreData
import Foundation

class DetailsController: UIViewController {
    
    @IBOutlet weak var chartsWebView: UIWebView!
    weak var currentViewController: UIViewController?
    var symbol = ""
    var pageName = ""
    var data = JSON("")
    var favs = [NSManagedObject]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadComponentValues(self.pageName)
    }
    
    func loadComponentValues(identifier: String) {
        if identifier == "Current" {
            loadCurrent(self.symbol)
        } else if identifier == "Historical" {
            loadCharts(self.symbol)
        } else if identifier == "News" {
            loadNews(self.symbol)
        }
    }
    
    func loadCurrent(symbol: String) {
    }
    
    func loadCharts(symbol: String) {
        let url = NSURL(string: "http://inbound-rock-127222.appspot.com/stockMDetails.php?op=interactivechart&symbol=" + symbol)!
        print(url.absoluteString)
        let request = NSURLRequest(URL: url)
        chartsWebView.loadRequest(request)
    }
    
    func loadNews(symbol: String) {
    }
    
    func makeCall(parameters: [String: AnyObject], shouldCheck: Bool, completionHandler: (JSON, NSError?) -> ()) {
        let url = "https://inbound-rock-127222.appspot.com/stockDetails.php"
        Alamofire.request(.GET, url, parameters: parameters).validate().responseJSON { response in
            switch response.result {
            case .Success:
                if let json = response.result.value {
                    let val = JSON(json)
                    print("JSON: \(val)")
                    let status = val["Status"].string
                    
                    if status == "SUCCESS" || !shouldCheck {
                        completionHandler(val, nil)
                    }
                }
                break;
            case .Failure(let error):
                completionHandler(nil, error)
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}


