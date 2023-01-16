//
//  TaxTableViewCell.swift
//  Expense Mangement
//
//  Created by Wunna on 1/5/23.
//

import UIKit

class TaxTableViewCell: UITableViewCell {
    
    
    @IBOutlet weak var amount: UILabel!
    
    @IBOutlet weak var tax: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}
