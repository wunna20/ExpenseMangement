//
//  ExpenseTableViewCell.swift
//  Expense Mangement
//
//  Created by Wunna on 12/15/22.
//

import UIKit

class ExpenseTableViewCell: UITableViewCell {
    
    
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var date: UILabel!
    @IBOutlet weak var amount: UILabel!
    @IBOutlet weak var type: UILabel!
    @IBOutlet weak var category: UILabel!
    @IBOutlet weak var itemView: UIView!
    @IBOutlet weak var itemImg: UIImageView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        itemView.layer.cornerRadius = 15
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
        
    
}

