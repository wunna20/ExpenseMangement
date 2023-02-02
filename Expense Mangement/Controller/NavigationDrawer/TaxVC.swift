//
//  TaxVC.swift
//  Expense Mangement
//
//  Created by Wunna on 1/5/23.
//

import UIKit
import CoreData
import DropDown


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
    @IBOutlet weak var vwDropDown: UIView!
    @IBOutlet weak var yearTitle: UILabel!
    @IBOutlet weak var incomeTxt: UILabel!
    @IBOutlet weak var rateTxt: UILabel!
    @IBOutlet weak var taxTxt: UILabel!
    
    let dropDown = DropDown()
    var selected: Int = 0
    var year: Int = 0
    var dataItem:[Expenses]?
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        
        tableView.delegate = self
        tableView.dataSource = self
        let textFieldCell = UINib(nibName: "TaxTableViewCell",
                                  bundle: nil)
        self.tableView.register(textFieldCell, forCellReuseIdentifier: "TaxTableViewCell")
        
        var yearArr = [Int]()
        yearArr += 1990...2050
        
        var stringYearArr = yearArr.map{Optional(String($0))}
        print("stringYear", stringYearArr)
       
        dropDown.anchorView = vwDropDown
        dropDown.dataSource = stringYearArr as Any as! [String]
        dropDown.bottomOffset = CGPoint(x: 0, y:(dropDown.anchorView?.plainView.bounds.height)!)
        dropDown.topOffset = CGPoint(x: 0, y:-(dropDown.anchorView?.plainView.bounds.height)!)
        dropDown.direction = .bottom
        
        dropDown.selectionAction = { [unowned self] (index: Int, item: String) in
            print("Selected item: \(item) at index: \(index + 1)")
            yearTitle.text = String(yearArr[index])
            selected = index
            print("Selected", selected)
            year = yearArr[index]
            
            print("year", year)
            
            calculate()
        }
        
        fetchExpense()
        
    }
    
    
    @IBAction func yearTapped(_ sender: Any) {
        dropDown.show()
    }
    
    
    @IBAction func backTapped(_ sender: Any) {
        if let nav = self.navigationController {
            nav.popViewController(animated: true)
        } else {
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    func fetchExpense() {
        do {
            let request = Expenses.fetchRequest() as NSFetchRequest<Expenses>
            let sort = NSSortDescriptor(key: #keyPath(Expenses.date), ascending: false)
            request.sortDescriptors = [sort]
            self.dataItem = try context.fetch(request)
            
        } catch {
            print("error")
        }
    }
    
    func calculate() {
        let curFormat = NumberFormatter()
        curFormat.usesGroupingSeparator = true
        curFormat.locale = Locale.current
        curFormat.maximumFractionDigits = 2
        curFormat.decimalSeparator = "."
        curFormat.numberStyle = .decimal
        
        
        print("inner year", year)
        let income = dataItem?.filter{$0.type == false}.filter{$0.date ?? "Hello" >= "\(year)/01/01"}.filter{$0.date ?? "Hello" <= "\(year)/12/31"}.filter{$0.category == "Salary"}.map({$0.amount}).reduce(0, +)
        
        print("income", income as Any)
        
        if (income! >= 1 && income! <= 2000000) {
            rateTxt.text = String(0) + "%"
        } else if (income! >= 2000001 && income! <= 5000000) {
            rateTxt.text = String(5) + "%"
            let tax = CalculateAmt.calculateTaxRate(percentageVal: 5, incomeAmount: Double(income!))
            taxTxt.text = curFormat.string(from: tax as NSNumber)! + "MMK"
        } else if (income! >= 5000001 && income! <= 10000000) {
            rateTxt.text = String(10) + "%"
            let tax = CalculateAmt.calculateTaxRate(percentageVal: 10, incomeAmount: Double(income!))
            taxTxt.text = curFormat.string(from: tax as NSNumber)! + "MMK"
        } else if (income! >= 10000001 && income! <= 20000000) {
            rateTxt.text = String(15) + "%"
            let tax = CalculateAmt.calculateTaxRate(percentageVal: 15, incomeAmount: Double(income!))
            taxTxt.text = curFormat.string(from: tax as NSNumber)! + "MMK"
        } else if (income! >= 20000000 && income! <= 30000000) {
            rateTxt.text = String(20) + "%"
            let tax = CalculateAmt.calculateTaxRate(percentageVal: 20, incomeAmount: Double(income!))
            taxTxt.text = curFormat.string(from: tax as NSNumber)! + "MMK"
        } else if (income! >= 30000001){
            rateTxt.text = String(25) + "%"
            let tax = CalculateAmt.calculateTaxRate(percentageVal: 25, incomeAmount: Double(income!))
            taxTxt.text = curFormat.string(from: tax as NSNumber)! + "MMK"
        }
        
        
        let incomeBonus = dataItem?.filter{$0.type == false}.filter{$0.date ?? "Hello" >= "\(year)/01/01"}.filter{$0.date ?? "Hello" <= "\(year)/12/31"}.filter{$0.category == "Bonus"}.map({$0.amount}).reduce(0, +)
        let bonus = CalculateAmt.calculateTaxRate(percentageVal: 22, incomeAmount: Double(incomeBonus!))
        
        let lastIncome = dataItem?.filter{$0.type == false}.filter{$0.date ?? "Hello" >= "\(year)/01/01"}.filter{$0.date ?? "Hello" <= "\(year)/12/31"}.filter{$0.category != "Bonus" && $0.category != "Salary"}.map({$0.amount}).reduce(0, +)
        
        let totalIncome = income! &+ incomeBonus! &+ lastIncome!
        incomeTxt.text = curFormat.string(from: Int64(Int(totalIncome)) as NSNumber)! + "MMK"
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



