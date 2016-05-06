//
//  FavTableValueCell.swift
//  Stock
//
//  Created by Pawan Valluri on 5/4/16.
//  Copyright © 2016 Pawan Valluri. All rights reserved.
//

import UIKit

class FavTableValueCell: UITableViewCell {
    @IBOutlet weak var StockName: UILabel!
    
    @IBOutlet weak var stockPrice: UILabel!
    
    @IBOutlet weak var changePer: UILabel!
    
    @IBOutlet weak var companyName: UILabel!
    
    @IBOutlet weak var MarketCap: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        // super.setSelected(selected:Bool, animated:Bool)
    }
}
