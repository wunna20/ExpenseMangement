//
//  PersonalIncomeTaxListVC.swift
//  Expense Mangement
//
//  Created by Wunna on 1/12/23.
//

import UIKit
import CoreData
import DropDown


class PersonalIncomeTaxListVC: UIViewController {
    
    var expenseArr = [ExpenseModel]()
    var IncomeArr = [ExpenseModel]()
    var filterMonthArr = [ExpenseModel]()
    var monthsArr = [
        "All",
        "January",
        "February",
        "March",
        "April",
        "May",
        "June",
        "July",
        "August",
        "September",
        "October",
        "November",
        "December",
      ];
    let dropDown = DropDown()
    var selected: Int = 0

    
    @IBOutlet weak var vwDropDown: UIView!
    @IBOutlet weak var monthTitle: UILabel!
    
    @IBOutlet weak var monthBtn: UIButton!
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dropDown.anchorView = vwDropDown
        dropDown.dataSource = monthsArr as Any as! [String]
        dropDown.bottomOffset = CGPoint(x: 0, y:(dropDown.anchorView?.plainView.bounds.height)!)
        dropDown.topOffset = CGPoint(x: 0, y:-(dropDown.anchorView?.plainView.bounds.height)!)
        dropDown.direction = .bottom
        
        dropDown.selectionAction = { [unowned self] (index: Int, item: String) in
            print("Selected item: \(item) at index: \(index + 1)")
            monthTitle.text = monthsArr[index]
            selected = index
            print("Selected", selected)
            
            tableView.reloadData()

        }
        
        // register Tableview
        tableView.delegate = self
        tableView.dataSource = self
        let textFieldCell = UINib(nibName: "PersonalIncomeTaxTableViewCell",
                                  bundle: nil)
        self.tableView.register(textFieldCell, forCellReuseIdentifier:  "PersonalIncomeTaxTableViewCell")
                

        readExpenseData()
        print("Personal", expenseArr)
        filterIncomeList()
        
    }
    
    
    @IBAction func backTapped(_ sender: Any) {
        if let nav = self.navigationController {
            nav.popViewController(animated: true)
        } else {
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    
    @IBAction func monthTapped(_ sender: Any) {
        dropDown.show()
    }
    
    
// filter income list
    func filterIncomeList() {
        IncomeArr = expenseArr.filter{$0.type == false}
        print("filterIncome", IncomeArr.count)
    }
    
    
//    read expense data
    func readExpenseData() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {return}
        let managedContext = appDelegate.persistentContainer.viewContext
        let  fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Expenses")
        let sort = NSSortDescriptor(key: #keyPath(Expenses.date), ascending: false)
        fetchRequest.sortDescriptors = [sort]
        
        do {
            guard let result = try managedContext.fetch(fetchRequest) as? [NSManagedObject] else {
                return
            }
            print("Saved values",result)
            for data in result {
                print("AMOUNT", data.value(forKey: "amount") as? Int ?? "")
                
                let obj = ExpenseModel(
                    title: (data.value(forKey: "title") as! String),
                    category: (data.value(forKey: "category") as! String),
                    amount: (data.value(forKey: "amount") as? Int),
                    date: (data.value(forKey: "date") as? String),
                    type: (data.value(forKey: "type") as! Bool),
                    createdAt: (data.value(forKey: "createdAt") as? String),
                    updatedAt: (data.value(forKey: "updatedAt") as? String)
                )
                
                self.expenseArr.append(obj)
            }
            
            
        } catch let error as NSError {
            debugPrint(error)
        }
    }
    
    // calculate tax rate
    func calculateTaxRate (percentageVal:Double, incomeAmount:Double)->Double {
        let per = percentageVal / 100.0
        let taxRate = incomeAmount * per
        return taxRate
    }
    
    // calculate total tax amoumt
    func calTotalAmt(tax: Double, incomeAmount: Double)->Double {
        let total = incomeAmount - tax
        return total
    }

}




extension PersonalIncomeTaxListVC: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
            return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (selected == 0) {
            return IncomeArr.count
        } else {
            let selectMonth = IncomeArr.filter{$0.date! >= "2023/0\(selected)/01"}.filter{$0.date! <= "2023/0\(selected)/31"}
            return selectMonth.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let curFormat = NumberFormatter()
        curFormat.usesGroupingSeparator = true
        curFormat.locale = Locale.current
        curFormat.maximumFractionDigits = 2
        curFormat.decimalSeparator = "."
        curFormat.numberStyle = .decimal
        
        let cellIdentifier = "PersonalIncomeTaxTableViewCell"
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier,for: indexPath) as! PersonalIncomeTaxTableViewCell
        
        let selectMonth = IncomeArr.filter{$0.date! >= "2023/0\(selected)/01"}.filter{$0.date! <= "2023/0\(selected)/31"}
        let income = selected == 0 ? IncomeArr[indexPath.row] : selectMonth[indexPath.row]
        cell.title.text = income.title
        cell.category.text = income.category
        cell.date.text = income.date
        cell.incomeAmount.text = curFormat.string(from: income.amount! as NSNumber)
        
        
        
        if (income.category == "Salary") {
            if (income.amount! >= 0 && income.amount! <= 2000000) {
                cell.taxAmount.text = "0"
                cell.totalAmount.text = curFormat.string(from: income.amount! as NSNumber)
            } else if (income.amount! >= 2000001 && income.amount! <= 5000000) {
                let res = calculateTaxRate(percentageVal: 5, incomeAmount: Double(income.amount!))
                cell.taxAmount.text = curFormat.string(from: res as NSNumber)
                let totaRes = calTotalAmt(tax: res, incomeAmount: Double(income.amount!))
                cell.totalAmount.text = curFormat.string(from: totaRes as NSNumber)
            } else if (income.amount! >= 5000001 && income.amount! <= 10000000) {
                let res = calculateTaxRate(percentageVal: 10, incomeAmount: Double(income.amount!))
                cell.taxAmount.text = curFormat.string(from: res as NSNumber)
                let totaRes = calTotalAmt(tax: res, incomeAmount: Double(income.amount!))
                cell.totalAmount.text = curFormat.string(from: totaRes as NSNumber)
            } else if (income.amount! >= 10000001 && income.amount! <= 20000000) {
                let res = calculateTaxRate(percentageVal: 15, incomeAmount: Double(income.amount!))
                cell.taxAmount.text = curFormat.string(from: res as NSNumber)
                let totaRes = calTotalAmt(tax: res, incomeAmount: Double(income.amount!))
                cell.totalAmount.text = curFormat.string(from: totaRes as NSNumber)
            } else if (income.amount! >= 20000001 && income.amount! <= 30000000) {
                let res = calculateTaxRate(percentageVal: 20, incomeAmount: Double(income.amount!))
                cell.taxAmount.text = curFormat.string(from: res as NSNumber)
                let totaRes = calTotalAmt(tax: res, incomeAmount: Double(income.amount!))
                cell.totalAmount.text = curFormat.string(from: totaRes as NSNumber)
            } else {
                let res = calculateTaxRate(percentageVal: 30, incomeAmount: Double(income.amount!))
                cell.taxAmount.text = curFormat.string(from: res as NSNumber)
                let totaRes = calTotalAmt(tax: res, incomeAmount: Double(income.amount!))
                cell.totalAmount.text = curFormat.string(from: totaRes as NSNumber)
            }
        } else if (income.category == "Bonus") {
            if (income.date! >= "2023/01/01" && income.date! <= "2023/12/31") {
                if (income.amount! >= 1000000) {
                    let res = calculateTaxRate(percentageVal: 22, incomeAmount: Double(income.amount!))
                    cell.taxAmount.text = curFormat.string(from: res as NSNumber)
                    let totaRes = calTotalAmt(tax: res, incomeAmount: Double(income.amount!))
                    cell.totalAmount.text = curFormat.string(from: totaRes as NSNumber)
                } else {
                    cell.taxAmount.text = "0"
                    cell.totalAmount.text = curFormat.string(from: income.amount! as NSNumber)
                }
            }
        } else {
            cell.taxAmount.text = "0"
            cell.totalAmount.text = curFormat.string(from: income.amount! as NSNumber)
        }
        
        return cell
        
    }
    
    
}

