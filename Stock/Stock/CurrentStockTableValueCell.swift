//
//  CurrentStockTableViewCell.swift
//  Stock
//
//  Created by Pawan Valluri on 5/2/16.
//  Copyright © 2016 Pawan Valluri. All rights reserved.
//

import UIKit

class CurrentStockTableViewCell: UITableViewCell {
    
    @IBOutlet weak var labelInsideCell: UILabel!
    @IBOutlet weak var labelRightInsideCell: UILabel!
    @IBOutlet weak var imag: UIImageView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}
