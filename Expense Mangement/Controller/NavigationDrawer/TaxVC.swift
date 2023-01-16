//
//  TaxVC.swift
//  Expense Mangement
//
//  Created by Wunna on 1/5/23.
//

import UIKit
import CoreData



class TaxVC: UIViewController {
    
    
    struct Tax {
        var amount: String
        var tax: String
        var type: String
    }
    
    let incomeTaxArr = [
        Tax(amount: "1 to 2,000,000", tax: "0%", type: "Salary"),
        Tax(amount: "2,000,001 to 5,000,000", tax: "5%", type: "Salary"),
        Tax(amount: "5,000,001 to 10,000,000", tax: "10%", type: "Salary"),
        Tax(amount: "10,000,001 to 20,000,000", tax: "15%", type: "Salary"),
        Tax(amount: "20,000,001 to 30,000,000", tax: "20%", type: "Salary"),
        Tax(amount: "30,000,001 and above", tax: "25%", type: "Salary"),
    ]
    
    
    @IBOutlet weak var tableView: UITableView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        let textFieldCell = UINib(nibName: "TaxTableViewCell",
                                  bundle: nil)
        self.tableView.register(textFieldCell, forCellReuseIdentifier: "TaxTableViewCell")
        
        
    }
    
    
    @IBAction func backTapped(_ sender: Any) {
        if let nav = self.navigationController {
            nav.popViewController(animated: true)
        } else {
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    
    
}

extension TaxVC: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
            return 1
        }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return incomeTaxArr.count
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cellIdentifier = "TaxTableViewCell"
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier,for: indexPath) as! TaxTableViewCell
        
        let item = incomeTaxArr[indexPath.row]
        cell.amount.text = item.amount
        cell.tax.text = item.tax
        
        return cell
    }
        
       
    
    
}



