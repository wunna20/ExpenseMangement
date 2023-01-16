//
//  PersonalIncomeTaxTableViewCell.swift
//  Expense Mangement
//
//  Created by Wunna on 1/12/23.
//

import UIKit

class PersonalIncomeTaxTableViewCell: UITableViewCell {
    
    
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var category: UILabel!
    @IBOutlet weak var date: UILabel!
    @IBOutlet weak var incomeAmount: UILabel!
    @IBOutlet weak var taxAmount: UILabel!
    @IBOutlet weak var totalAmount: UILabel!
    
    @IBOutlet weak var itemView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        itemView.layer.cornerRadius = 15
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
