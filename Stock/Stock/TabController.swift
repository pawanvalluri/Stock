//
//  TabController.swift
//  Stock
//
//  Created by Pawan Valluri on 5/2/16.
//  Copyright © 2016 Pawan Valluri. All rights reserved.
//

import UIKit
import SwiftyJSON
import Alamofire
import CoreData
import Foundation

class TabController: UIViewController {
    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var currentButton: UIButton!
    @IBOutlet weak var historicalButton: UIButton!
    @IBOutlet weak var newsButton: UIButton!
    
    weak var currentViewController: UIViewController?
    var symbol = ""
    var favs = [NSManagedObject]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        self.title = symbol.uppercaseString
        self.currentViewController = self.storyboard?.instantiateViewControllerWithIdentifier("Current")
        self.currentViewController!.view.translatesAutoresizingMaskIntoConstraints = false
        self.addChildViewController(self.currentViewController!)
        self.addSubview(self.currentViewController!.view, toView: self.containerView!)
        
        if(!currentButton.selected && !historicalButton.selected && !newsButton.selected) {
            currentButton.selected = true
            showPage("Current")
        }
    }
    
    func addSubview(subView:UIView, toView parentView:UIView) {
        parentView.addSubview(subView)
        
        var viewBindingsDict = [String: AnyObject]()
        viewBindingsDict["subView"] = subView
        parentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[subView]|",
            options: [], metrics: nil, views: viewBindingsDict))
        parentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[subView]|",
            options: [], metrics: nil, views: viewBindingsDict))
    }
    
    func makeCall(parameters: [String: AnyObject], shouldCheck: Bool, completionHandler: (JSON, NSError?) -> ()) {
        let url = "https://inbound-rock-127222.appspot.com/stockDetails.php"
        Alamofire.request(.GET, url, parameters: parameters).validate().responseJSON { response in
            switch response.result {
            case .Success:
                if let json = response.result.value {
                    let val = JSON(json)
                    //print("JSON: \(val)")
                    let status = val["Status"].string
                    
                    if status == "SUCCESS" || !shouldCheck {
                        print(val)
                        completionHandler(val, nil)
                    }
                }
                break;
            case .Failure(let error):
                completionHandler(nil, error)
            }
        }
    }
    
    func showPage(identifier: String) {
        
        let newViewController = self.storyboard?.instantiateViewControllerWithIdentifier(identifier) as! DetailsController
        newViewController.symbol = self.symbol
        newViewController.pageName = identifier
        newViewController.favs = favs
        
        if identifier == "News" {
            let parameters = ["op": "newsfeed", "symbol": symbol]
            
            makeCall(parameters, shouldCheck: false, completionHandler: { responseObject, error in
                print ("loading")
                newViewController.data = responseObject
                newViewController.view.translatesAutoresizingMaskIntoConstraints = false
                self.cycleFromViewController(self.currentViewController!, toViewController: newViewController)
                self.currentViewController = newViewController
            })
        } else if identifier == "Current" {
            let parameters = ["op": "quote", "symbol": symbol]
            
            makeCall(parameters, shouldCheck: false, completionHandler: { responseObject, error in
                print ("loading current")
                print ("JSON: \(responseObject)")
                newViewController.data = responseObject
                newViewController.view.translatesAutoresizingMaskIntoConstraints = false
                self.cycleFromViewController(self.currentViewController!, toViewController: newViewController)
                self.currentViewController = newViewController
            })
        } else {
            newViewController.view.translatesAutoresizingMaskIntoConstraints = false
            self.cycleFromViewController(self.currentViewController!, toViewController: newViewController)
            self.currentViewController = newViewController
        }
    }
    @IBAction func changeDisplay(sender: UIButton) {
        currentButton.selected = false
        historicalButton.selected = false
        newsButton.selected = false
        
        if(sender.titleLabel?.text == "Current") {
            currentButton.selected = true
        } else if(sender.titleLabel?.text == "Historical") {
            historicalButton.selected = true
        } else if(sender.titleLabel?.text == "News") {
            newsButton.selected = true
        }
        
        showPage((sender.titleLabel?.text)!)
    }
    
    func cycleFromViewController(oldViewController: UIViewController, toViewController newViewController: UIViewController) {
        oldViewController.willMoveToParentViewController(nil)
        self.addChildViewController(newViewController)
        self.addSubview(newViewController.view, toView:self.containerView!)
        newViewController.view.alpha = 0
        newViewController.view.layoutIfNeeded()
        UIView.animateWithDuration(0.5, animations: {
            newViewController.view.alpha = 1
            oldViewController.view.alpha = 0
            }, completion: { finished in
                oldViewController.view.removeFromSuperview()
                oldViewController.removeFromParentViewController()
                newViewController.didMoveToParentViewController(self)
        })
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}


