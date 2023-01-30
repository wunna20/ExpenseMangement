//
//  HomeVC.swift
//  Expense Mangement
//
//  Created by Wunna on 12/12/22.
//

import UIKit
import CoreData
import KWDrawerController
import JJFloatingActionButton
import UniformTypeIdentifiers
import MobileCoreServices
import DropDown

class HomeVC: UIViewController, sendCSVData {
    func csvData(expense: ExpenseModel) {
        print("inner csv", expense)
        self.dismiss(animated: true) { [self] in
            self.expenseArr.append(expense)
            calculate()
            self.tableView.reloadData()
        }
    }
    
    var expenseArr = [ExpenseModel]()
    var filterIncomeArr = [ExpenseModel]()
    var filterExpenseArr = [ExpenseModel]()
    var filterMonth = [ExpenseModel]()
    var filterMonthIncome = [ExpenseModel]()
    var filterMonthExpense = [ExpenseModel]()
    var selectedItems: [String: Bool] = [:]
    
    var filterIncomeUpdateArr = [ExpenseModel]()
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var balanceLabel: UILabel!
    @IBOutlet weak var expenseLabel: UILabel!
    @IBOutlet weak var incomeLabel: UILabel!
    @IBOutlet weak var allLabel: UILabel!
    
    @IBOutlet weak var homeView: UIView!
    
    @IBOutlet weak var allBtn: UIView!

    @IBOutlet weak var allAndMonthBtn: UIButton!
    
    @IBOutlet weak var incomeBtn: UIButton!
    @IBOutlet weak var expenseBtn: UIButton!
    
    var testIncome: Bool = false
    var testExp: Bool = false
    var testAll: Bool = false
    
    fileprivate let actionButton = JJFloatingActionButton()
    
    var balance: Int = 0
    var items:[NSManagedObject] = []
    let dropDown = DropDown()
    let monthsArr = PersonalIncomeTaxListVC().monthsArr
    var selected: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpFloadingButton()
        
        homeView.layer.cornerRadius = 20
        homeView.resignFirstResponder()
        tableView.delegate = self
        tableView.dataSource = self
        let textFieldCell = UINib(nibName: "ExpenseTableViewCell",
                                  bundle: nil)
        self.tableView.register(textFieldCell, forCellReuseIdentifier:  "ExpenseTableViewCell")
        
        homeView.layer.shadowColor = UIColor.darkGray.cgColor
        homeView.layer.shadowOpacity = 1
        homeView.layer.shadowOffset = .zero
        homeView.layer.shadowRadius = 10
        homeView.layer.shouldRasterize = true
        
        allBtn.layer.cornerRadius = 10
        incomeBtn.layer.cornerRadius = 10
        expenseBtn.layer.cornerRadius = 10
        
        
        readExpenseData()
        print("testExp", expenseArr)
        calculate()
//        func updateData(expense: ExpenseModel, index: Int) {
//            self.dismiss(animated: true) { [self] in
//                self.expenseArr[index] = expense
//                calculate()
//                self.tableView.reloadData()
//            }
//        }
        
        let localInc = fetchData.shared.filterIncomeFetch()
        print("localInc", localInc)
        
        let localExp = fetchData.shared.filterExpFetch()
        print("localExp", localExp)
        
        for item in expenseArr {
            print("wunna", item.id)
        }
        
        dropDown.anchorView = allBtn
        dropDown.dataSource = monthsArr as Any as! [String]
        dropDown.bottomOffset = CGPoint(x: 0, y:(dropDown.anchorView?.plainView.bounds.height)!)
        dropDown.topOffset = CGPoint(x: 0, y:-(dropDown.anchorView?.plainView.bounds.height)!)
        dropDown.direction = .bottom
        
        dropDown.selectionAction = { [unowned self] (index: Int, item: String) in
            print("Selected item: \(item) at index: \(index + 1)")
            allLabel.text = monthsArr[index]
            selected = index
            print("Selected", selected)
            
            testIncome = false
            testExp = false
            testAll = true
            calculate()
            
            tableView.reloadData()

        }
        
    }
    
    @IBAction func menuButton(_ sender: Any) {
        self.drawerController?.openSide(.left)
    }
    
    @IBAction func allTapped(_ sender: Any) {
    
        dropDown.show()
        if (allAndMonthBtn.isTouchInside == true) {
            allBtn.backgroundColor = getUIColor(hex: "#3D5A80")
            allBtn.tintColor = .white
            incomeBtn.backgroundColor = .systemGray
            expenseBtn.backgroundColor = .systemGray
        }
        tableView.reloadData()
    }
    
    @IBAction func incomeTapped(_ sender: Any) {
        
        testExp = false
        testIncome = true
        filterIncomeArr = expenseArr.filter{$0.type == false}
        filterExpenseArr = expenseArr.filter{$0.type == true}
        
        filterMonthIncome = expenseArr.filter{$0.type == false}.filter{$0.date! >= "2023/0\(selected)/01"}.filter{$0.date! <= "2023/0\(selected)/31"}
        filterMonthExpense = expenseArr.filter{$0.type == true}.filter{$0.date! >= "2023/0\(selected)/01"}.filter{$0.date! <= "2023/0\(selected)/31"}
        
        print("incomeTapped", filterIncomeArr)
        
        if (incomeBtn.isTouchInside == true) {
            incomeBtn.backgroundColor = getUIColor(hex: "#3D5A80")
            incomeBtn.tintColor = .white
            allBtn.backgroundColor = .systemGray
            expenseBtn.backgroundColor = .systemGray
        }
        tableView.reloadData()
    }
    
    @IBAction func expenseTapped(_ sender: Any) {
        testExp = true
        testIncome = false
        filterExpenseArr = expenseArr.filter{$0.type == true}
        filterIncomeArr = expenseArr.filter{$0.type == false}
        
        filterMonthIncome = expenseArr.filter{$0.type == false}.filter{$0.date! >= "2023/0\(selected)/01"}.filter{$0.date! <= "2023/0\(selected)/31"}
        filterMonthExpense = expenseArr.filter{$0.type == true}.filter{$0.date! >= "2023/0\(selected)/01"}.filter{$0.date! <= "2023/0\(selected)/31"}
        
        print("tap exp", filterExpenseArr)
        
        if (expenseBtn.isTouchInside == true) {
            expenseBtn.backgroundColor = getUIColor(hex: "#3D5A80")
            expenseBtn.tintColor = .white
            allBtn.backgroundColor = .systemGray
            incomeBtn.backgroundColor = .systemGray
        }
        tableView.reloadData()
    }
    
    
    @IBAction func monthTapped(_ sender: Any) {
        testExp = false
        testIncome = false
        dropDown.show()
        
        
    }
    
    func createTapped(_ sender: Any) {
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "createExpense") as! CreateExpenseVC
        vc.modalPresentationStyle = .overFullScreen
        vc.delegate = self
        vc.myBalance = balance
        if (testIncome == true) {
            vc.check = "Income"
        } else if (testExp == true) {
            vc.check = "Expense"
        } else if (testAll == true) {
            vc.check = "all"
        }
        
        
        present(vc, animated: true)
    }
    
    func goToSetting(_ sender: Any) {
        let ItemList = self.storyboard?.instantiateViewController(withIdentifier: "SettingVC") as! SettingVC
        ItemList.delegate = self
        self.present(ItemList, animated: true, completion: nil)
        
    }
    
    func goToimport() {
        let sFileName = "testUpdate.csv"
        
        let documentDirectoryPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as String
        
        let documentURL = URL(fileURLWithPath: documentDirectoryPath).appendingPathComponent(sFileName)
        
        let output = OutputStream.toMemory()
        
        let csvWriter = CHCSVWriter(outputStream: output, encoding: String.Encoding.utf8.rawValue, delimiter: ",".utf16.first!)
        
        //        Header of the CSV file
        csvWriter?.writeField("Title")
        csvWriter?.writeField("Category")
        csvWriter?.writeField("Amount")
        csvWriter?.writeField("Type")
        csvWriter?.writeField("Date")
        csvWriter?.writeField("CreatedAt")
        csvWriter?.writeField("UpdatedAt")
        csvWriter?.finishLine()
        
        for item in expenseArr.enumerated() {
            print("inner title", item.element.title as Any)
            csvWriter?.writeField(item.element.title as Any)
            csvWriter?.writeField(item.element.category as Any)
            csvWriter?.writeField(item.element.amount as Any)
            csvWriter?.writeField(item.element.type as Any)
            csvWriter?.writeField(item.element.date as Any)
            csvWriter?.writeField(item.element.createdAt as Any)
            csvWriter?.writeField(item.element.updatedAt as Any)
            
            csvWriter?.finishLine()
        }
        csvWriter?.closeStream()
        
        let buffer = (output.property(forKey: .dataWrittenToMemoryStreamKey) as? Data)!
        
        do {
            try buffer.write(to: documentURL)
            print("uploaded")
            //        Toast Message
            CustomToast.show(message: "Successfully import", bgColor: .black, textColor: .white, labelFont: .boldSystemFont(ofSize: 14), showIn: .top, controller: self)
        } catch {
            print("error")
        }
        
    }
    
    //    floating button
    func setUpFloadingButton() {
        let myColor = getUIColor(hex: "#293241")
        actionButton.buttonColor = myColor!
        let configuration = JJItemAnimationConfiguration()
        configuration.itemLayout = JJItemLayout { items, actionButton in
            var previousItem: JJActionItem?
            for item in items {
                let previousView = previousItem ?? actionButton
                item.bottomAnchor.constraint(equalTo: previousView.topAnchor, constant: -10).isActive = true
                item.circleView.centerXAnchor.constraint(equalTo: actionButton.centerXAnchor).isActive = true
                previousItem = item
            }
        }
        actionButton.itemAnimationConfiguration = configuration
        
        actionButton.addItem(title: "Create", image:UIImage(systemName: "plus.circle")) { [self] item in
            createTapped((Any).self)
        }
        
        actionButton.addItem(title: "Export", image:UIImage(systemName: "square.and.arrow.down")) { [self] item in
            goToimport()
        }
        
        actionButton.addItem(title: "Import", image:UIImage(systemName: "square.and.arrow.up")) { [self] item in
            goToSetting((Any).self)
        }
        
        view.addSubview(actionButton)
        
        actionButton.translatesAutoresizingMaskIntoConstraints = false
        if #available(iOS 11.0, *) {
            actionButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20).isActive = true
            actionButton.bottomAnchor.constraint(equalTo: self.view.layoutMarginsGuide.bottomAnchor, constant: -10).isActive = true
        } else {
            actionButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20).isActive = true
            actionButton.bottomAnchor.constraint(equalTo: self.view.layoutMarginsGuide.bottomAnchor, constant: -10).isActive = true
        }
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
            for data in result {
                let obj = ExpenseModel(
                    id: (data.value(forKey: "id")) as? UUID,
                    title: (data.value(forKey: "title") as! String),
                    category: (data.value(forKey: "category") as! String),
                    amount: (data.value(forKey: "amount") as? Int),
                    date: (data.value(forKey: "date") as? String),
                    type: (data.value(forKey: "type") as! Bool),
                    createdAt: (data.value(forKey: "createdAt") as? String),
                    updatedAt: (data.value(forKey: "updatedAt") as? String)
                )
                self.expenseArr.append(obj)
                print("id expense", expenseArr)
            }
        } catch let error as NSError {
            debugPrint(error)
        }
    }
    
    
    // calculate amout
    func calculate() {
        
        let curFormat = NumberFormatter()
        curFormat.usesGroupingSeparator = true
        curFormat.locale = Locale.current
        curFormat.maximumFractionDigits = 2
        curFormat.decimalSeparator = "."
        curFormat.numberStyle = .decimal
        
        var salAmt: Double = 0
        var bonusAmt: Double = 0
        
        if (selected == 0) {
            print("selectall")
            //        Expense Amount
            let filterExpArr = expenseArr.filter{$0.type == true}
            let res1 = filterExpArr.map{Int($0.amount!)}
            let expRes = res1.reduce(0, +)
            expenseLabel.text = "-" + curFormat.string(from: expRes as NSNumber)! + "MMK"
            
            //        Income Amount
            let filterIncomeArr = expenseArr.filter{$0.type == false}.filter{$0.date! >= "2023/01/01"}.filter{$0.date! <= "2023/12/31"}
            //        for salary tax
            let sal = filterIncomeArr.filter{$0.category == "Salary"}.map{$0.amount!}.reduce(0, +)
            if (sal >= 0 && sal <= 2000000) {
                salAmt = Double(0)
            } else if (sal >= 2000001 && sal <= 5000000) {
                salAmt = calculateTaxRate(percentageVal: 5, incomeAmount: Double(sal))
            } else if (sal >= 5000001 && sal <= 10000000) {
                salAmt = calculateTaxRate(percentageVal: 10, incomeAmount: Double(sal))
            } else if (sal >= 10000001 && sal <= 20000000) {
                salAmt = calculateTaxRate(percentageVal: 15, incomeAmount: Double(sal))
            } else if (sal >= 20000001 && sal <= 30000000) {
                salAmt = calculateTaxRate(percentageVal: 20, incomeAmount: Double(sal))
            } else {
                salAmt = calculateTaxRate(percentageVal: 25, incomeAmount: Double(sal))
            }
            print("home sal", salAmt)
            
//        for bonuse Tax
            let bonusArr = expenseArr.filter{$0.type == false}.filter{$0.category == "Bonus"}.filter{$0.date! >= "2023/01/01"}.filter{$0.date! <= "2023/12/31"}.map{$0.amount!}.reduce(0, +)
            print("bonus Arr", bonusArr)
            bonusAmt = calculateTaxRate(percentageVal: 22, incomeAmount: Double(bonusArr))
            print("home bonus", bonusAmt)
        
            
            let totalTax = salAmt + bonusAmt
            print("totalTax", totalTax)
                
//        final Total Income Result
            let totalIncome = expenseArr.filter{$0.type == false}.filter{$0.date! >= "2023/01/01"}.filter{$0.date! <= "2023/12/31"}.map{$0.amount!}.reduce(0, +)
            print("totalIncome", totalIncome)
            let finalTotalIncome = Double(totalIncome) - totalTax
            print("tax", finalTotalIncome)
            incomeLabel.text = "+" + curFormat.string(from: finalTotalIncome as NSNumber)! + "MMK"
            
//        Balance
            let balance = finalTotalIncome - Double(expRes)
            print("balance", balance)
            balanceLabel.text = curFormat.string(from: balance as NSNumber)! + "MMK"
        } else {
            let result = expenseArr.filter{$0.date! >= "2023/0\(selected)/01"}.filter{$0.date! <= "2023/0\(selected)/31"}
            print("result", result.count)
            
            let filterExpArr = result.filter{$0.type == true}
            let res1 = filterExpArr.map{Int($0.amount!)}
            let expRes = res1.reduce(0, +)
            expenseLabel.text = "-" + curFormat.string(from: expRes as NSNumber)! + "MMK"
           
            let fitlerIncArr = result.filter{$0.type == false}
            let sal = fitlerIncArr.filter{$0.category == "Salary"}.map{$0.amount!}.reduce(0, +)
            let bonus = fitlerIncArr.filter{$0.category == "Bonus"}.map{$0.amount!}.reduce(0, +)
            let lastIncome = fitlerIncArr.filter{$0.category != "Bonus" && $0.category != "Salary"
            }.map{$0.amount!}.reduce(0, +)
            
            let totalIncome = sal + bonus + lastIncome
            print("totalInc", totalIncome)
            incomeLabel.text = "+" + curFormat.string(from: totalIncome as NSNumber)! + "MMK"
            
            let balance = totalIncome - expRes
            balanceLabel.text = curFormat.string(from: balance as NSNumber)! + "MMK"
            }
        }
    }
    
    // calculate salary tax
    func calculateTax(percentageVal:Double, incomeAmount:Double)->Double {
        let per = percentageVal / 100.0
        let taxRate = incomeAmount * per
        let finalRes = incomeAmount - taxRate
        print("inner final Res", finalRes)
        return finalRes
    }

//  calculate tax rate
    func calculateTaxRate (percentageVal:Double, incomeAmount:Double)->Double {
        let per = percentageVal / 100.0
        let taxRate = incomeAmount * per
        return taxRate
    }
    
    //    get color
    func getUIColor(hex: String, alpha: Double = 1.0) -> UIColor? {
        var cleanString = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        
        if (cleanString.hasPrefix("#")) {
            cleanString.remove(at: cleanString.startIndex)
        }
        
        if ((cleanString.count) != 6) {
            return nil
        }
        
        var rgbValue: UInt32 = 0
        Scanner(string: cleanString).scanHexInt32(&rgbValue)
        
        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)

        )
    }




@available(iOS 14.0, *)
extension HomeVC: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (testIncome == true) {
            if (selected == 0) {
                print("income count", filterIncomeArr.count)
                return filterIncomeArr.count
            } else {
                filterMonthIncome = filterIncomeArr.filter{$0.date! >= "2023/0\(selected)/01"}.filter{$0.date! <= "2023/0\(selected)/31"}
                print("filterMonthIncome", filterMonthIncome)
                return filterMonthIncome.count
            }
            
        } else if (testExp == true) {
            if (selected == 0) {
                print("expense count", filterExpenseArr.count)
                return filterExpenseArr.count
            } else {
                filterMonthExpense = filterExpenseArr.filter{$0.date! >= "2023/0\(selected)/01"}.filter{$0.date! <= "2023/0\(selected)/31"}
                print("filterMonthExpense",filterMonthExpense)
                return filterMonthExpense.count
            }
            
        } else {
            if (selected == 0) {
                print("total count", expenseArr)
                return expenseArr.count
            } else {
                filterMonth = expenseArr.filter{$0.date! >= "2023/0\(selected)/01"}.filter{$0.date! <= "2023/0\(selected)/31"}
                    return filterMonth.count
            }
            
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "ExpenseTableViewCell"
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier,for: indexPath) as! ExpenseTableViewCell
        print("tablecount",filterIncomeArr.count,filterExpenseArr.count,expenseArr.count, filterMonth.count)
        
        if (testIncome == true){
            if (selected == 0) {
                let income = filterIncomeArr[indexPath.row]
                print("index income", income)
                cell.title.text = income.title
                cell.category.text = income.category
                
                let curFormat = NumberFormatter()
                curFormat.usesGroupingSeparator = true
                curFormat.locale = Locale.current
                curFormat.maximumFractionDigits = 2
                curFormat.decimalSeparator = "."
                curFormat.numberStyle = .decimal
                
                cell.amount.text = curFormat.string(from: income.amount! as NSNumber)
                cell.date.text = income.date
                cell.type.text = String(income.type!) == "true" ? "Expense" : "Income"
                if (cell.type.text == "Expense") {
                    cell.itemView.backgroundColor = getUIColor(hex: "#ee6c4d")
                } else {
                    cell.itemView.backgroundColor = getUIColor(hex: "#98c1d9")
                }
                return cell
            } else {
                let income = filterMonthIncome[indexPath.row]
                print("index income", income)
                cell.title.text = income.title
                cell.category.text = income.category
                
                let curFormat = NumberFormatter()
                curFormat.usesGroupingSeparator = true
                curFormat.locale = Locale.current
                curFormat.maximumFractionDigits = 2
                curFormat.decimalSeparator = "."
                curFormat.numberStyle = .decimal
                
                cell.amount.text = curFormat.string(from: income.amount! as NSNumber)
                cell.date.text = income.date
                cell.type.text = String(income.type!) == "true" ? "Expense" : "Income"
                if (cell.type.text == "Expense") {
                    cell.itemView.backgroundColor = getUIColor(hex: "#ee6c4d")
                } else {
                    cell.itemView.backgroundColor = getUIColor(hex: "#98c1d9")
                }
                return cell
            }
                
            
        } else if (testExp == true) {
            
            if (selected == 0) {
                print("inner Exp", filterExpenseArr, indexPath)
                let expense = filterExpenseArr[indexPath.row]
                print("index expense", expense)
                
                let curFormat = NumberFormatter()
                curFormat.usesGroupingSeparator = true
                curFormat.locale = Locale.current
                curFormat.maximumFractionDigits = 2
                curFormat.decimalSeparator = "."
                curFormat.numberStyle = .decimal
                
                cell.title.text = expense.title
                cell.category.text = expense.category
                cell.amount.text = curFormat.string(from: expense.amount! as NSNumber)
                cell.date.text = expense.date
                cell.type.text = String(expense.type!) == "true" ? "Expense" : "Income"
                
                if (cell.type.text == "Expense") {
                    cell.itemView.backgroundColor = getUIColor(hex: "#ee6c4d")
                } else {
                    cell.itemView.backgroundColor = getUIColor(hex: "#98c1d9")
                }
                
                return cell
            } else {
                let expense = filterMonthExpense[indexPath.row]
                print("index expense", expense)
                
                let curFormat = NumberFormatter()
                curFormat.usesGroupingSeparator = true
                curFormat.locale = Locale.current
                curFormat.maximumFractionDigits = 2
                curFormat.decimalSeparator = "."
                curFormat.numberStyle = .decimal
                
                cell.title.text = expense.title
                cell.category.text = expense.category
                cell.amount.text = curFormat.string(from: expense.amount! as NSNumber)
                cell.date.text = expense.date
                cell.type.text = String(expense.type!) == "true" ? "Expense" : "Income"
                
                if (cell.type.text == "Expense") {
                    cell.itemView.backgroundColor = getUIColor(hex: "#ee6c4d")
                } else {
                    cell.itemView.backgroundColor = getUIColor(hex: "#98c1d9")
                }
                
                return cell
            }
        } else {
            let selectMonth = expenseArr.filter{$0.date! >= "2023/0\(selected)/01"}.filter{$0.date! <= "2023/0\(selected)/31"}
            let expense = selected == 0 ? expenseArr[indexPath.row] : selectMonth[indexPath.row]
            print("outer expense", expense)
            cell.title.text = expense.title
            cell.category.text = expense.category
            
            let curFormat = NumberFormatter()
            curFormat.usesGroupingSeparator = true
            curFormat.locale = Locale.current
            curFormat.maximumFractionDigits = 2
            curFormat.decimalSeparator = "."
            curFormat.numberStyle = .decimal
            
            cell.amount.text = curFormat.string(from: expense.amount! as NSNumber)
            cell.date.text = expense.date
            cell.type.text = String(expense.type!) == "true" ? "Expense" : "Income"
            if (cell.type.text == "Expense") {
                cell.itemView.backgroundColor = getUIColor(hex: "#ee6c4d")
            } else {
                cell.itemView.backgroundColor = getUIColor(hex: "#98c1d9")
            }
            return cell
        }
    }
    
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath)
                -> UISwipeActionsConfiguration? {
                    let deleteAction = UIContextualAction(style: .destructive, title: nil) { [self] (_, _, completionHandler) in
                    // delete the item here
                    guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {return}
                    let managedContext = appDelegate.persistentContainer.viewContext
                    let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Expenses")
                        
                    let predicate = NSPredicate(format: "type = %@", false as NSNumber)
                    let expPredicate = NSPredicate(format: "type = %@", true as NSNumber)
                    let incomeFetch = fetchRequest.predicate
                        print("incomeFetch", incomeFetch)
                                        
                    do {
                        guard let result = try managedContext.fetch(fetchRequest) as? [NSManagedObject] else {
                            return
                        }
                        if (testIncome == true) {
                            let localInc = fetchData.shared.filterIncomeFetch()
                            let objc = localInc[indexPath.row]
                            managedContext.delete(objc)
                        } else if (testExp == true) {
                            let localExp = fetchData.shared.filterExpFetch()
                            let objc = localExp[indexPath.row]
                            managedContext.delete(objc)
                        } else {
                            let objc = result[indexPath.row]
                            managedContext.delete(objc)
                        }
                            
                        do {
                            try managedContext.save()
                            if (testIncome == true) {
                                let index = filterIncomeArr[indexPath.row].id
                                let indexExp = expenseArr.firstIndex(where: {$0.id == index})
                                expenseArr.remove(at: indexExp!)
                                filterIncomeArr.remove(at: indexPath.row)
                            } else if (testExp == true) {
                                let index = filterExpenseArr[indexPath.row].id
                                let indexExp = expenseArr.firstIndex(where: {$0.id == index})
                                expenseArr.remove(at: indexExp!)
                                filterExpenseArr.remove(at: indexPath.row)

                            } else {
                                expenseArr.remove(at: indexPath.row)
                            }

                            calculate()
                            print("exp Arr", expenseArr)
                            debugPrint("Record deleted")
                        } catch let error as NSError {
                            debugPrint(error)
                        }
                    } catch let error as NSError {
                        debugPrint(error)
                    }
                    
                    tableView.reloadData()
                    
                    completionHandler(true)
                }
                deleteAction.image = UIImage(systemName: "trash")
                deleteAction.backgroundColor = .systemRed
                let configuration = UISwipeActionsConfiguration(actions: [deleteAction])
                return configuration
        }


    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let cellIdentifier = "ExpenseTableViewCell"
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier,for: indexPath as IndexPath) as! ExpenseTableViewCell
        
        
        if (testIncome == true) {
            
            if (selected == 0) {
                let income = filterIncomeArr[indexPath.row]
                cell.title.text = income.title
                cell.category.text = income.category
                cell.amount.text = String(income.amount!)
                cell.date.text = income.date
                cell.type.text = String(income.type!) == "true" ? "Expense" : "Income"
                
                tableView.deselectRow(at: indexPath, animated: true)
                let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "updateExpense") as! UpdateExpenseVC
                vc.modalPresentationStyle = .overFullScreen
                vc.index = indexPath.row
                vc.id = income.id ?? UUID()
                vc.title1 = cell.title.text!
                vc.amount = cell.amount.text!
                vc.category = cell.category.text!
                vc.dateRes = cell.date.text!
                vc.type = cell.type.text!
                vc.check = "income"
                vc.delegate = self

                present(vc, animated: true)
            } else {
                let income = filterMonthIncome[indexPath.row]
                cell.title.text = income.title
                cell.category.text = income.category
                cell.amount.text = String(income.amount!)
                cell.date.text = income.date
                cell.type.text = String(income.type!) == "true" ? "Expense" : "Income"
                
                tableView.deselectRow(at: indexPath, animated: true)
                let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "updateExpense") as! UpdateExpenseVC
                vc.modalPresentationStyle = .overFullScreen
                vc.index = indexPath.row
                vc.id = income.id ?? UUID()
                vc.title1 = cell.title.text!
                vc.amount = cell.amount.text!
                vc.category = cell.category.text!
                vc.dateRes = cell.date.text!
                vc.type = cell.type.text!
                vc.check = "income selectMonth"
                vc.select = selected
                vc.delegate = self

                present(vc, animated: true)
            }
            
        } else if (testExp == true) {
            
            if (selected == 0) {
                let expense = filterExpenseArr[indexPath.row]
                print("expenseDetail", expense)
                print("hello", indexPath)
                cell.title.text = expense.title
                cell.category.text = expense.category
                cell.amount.text = String(expense.amount!)
                cell.date.text = expense.date
                cell.type.text = String(expense.type!) == "true" ? "Expense" : "Income"
                
                tableView.deselectRow(at: indexPath, animated: true)
                let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "updateExpense") as! UpdateExpenseVC
                vc.modalPresentationStyle = .overFullScreen
                vc.index = indexPath.row
                vc.id = expense.id ?? UUID()
                vc.title1 = cell.title.text!
                vc.amount = cell.amount.text!
                vc.category = cell.category.text!
                vc.dateRes = cell.date.text!
                vc.type = cell.type.text!
                vc.check = "expense"
                vc.delegate = self

                present(vc, animated: true)
            } else {
                let expense = filterMonthExpense[indexPath.row]
                print("expenseDetail", expense)
                print("hello", indexPath)
                cell.title.text = expense.title
                cell.category.text = expense.category
                cell.amount.text = String(expense.amount!)
                cell.date.text = expense.date
                cell.type.text = String(expense.type!) == "true" ? "Expense" : "Income"
                
                tableView.deselectRow(at: indexPath, animated: true)
                let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "updateExpense") as! UpdateExpenseVC
                vc.modalPresentationStyle = .overFullScreen
                vc.index = indexPath.row
                vc.id = expense.id ?? UUID()
                vc.title1 = cell.title.text!
                vc.amount = cell.amount.text!
                vc.category = cell.category.text!
                vc.dateRes = cell.date.text!
                vc.type = cell.type.text!
                vc.check = "expense selectMonth"
                vc.select = selected
                vc.delegate = self

                present(vc, animated: true)
            }
            
        } else {
            let selectMonth = expenseArr.filter{$0.date! >= "2023/0\(selected)/01"}.filter{$0.date! <= "2023/0\(selected)/31"}
            let expense = selected == 0 ? expenseArr[indexPath.row] : selectMonth[indexPath.row]
            print("expenseDetail", expense)
            cell.title.text = expense.title
            cell.category.text = expense.category
            cell.amount.text = String(expense.amount!)
            cell.date.text = expense.date
            cell.type.text = String(expense.type!) == "true" ? "Expense" : "Income"

            tableView.deselectRow(at: indexPath, animated: true)
            let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "updateExpense") as! UpdateExpenseVC
            vc.modalPresentationStyle = .overFullScreen
            vc.index = indexPath.row
            vc.id = expense.id ?? UUID()
            vc.title1 = cell.title.text!
            vc.amount = cell.amount.text!
            vc.category = cell.category.text!
            vc.dateRes = cell.date.text!
            vc.type = cell.type.text!
            vc.check = selected == 0 ? "all" : "notAll"
            vc.selectMonth = selected
            vc.delegate = self

            tableView.reloadData()
            present(vc, animated: true)
        }
        
    }
}

@available(iOS 14.0, *)

extension HomeVC: Send {
    func updateData(expense: ExpenseModel, index: Int, checkValue: String, check: Bool) {
        print("inner Expense", expense, index, checkValue)
        self.dismiss(animated: true) { [self] in
            if (checkValue == "income") {
                print("check income")
                if (check == true) {
//                    self.filterExpenseArr[index] = expense
                    let indexExp = expenseArr.firstIndex(where: {$0.id == expense.id})
                    print("indexExp", indexExp)
                    self.expenseArr[(indexExp)!] = expense
                } else {
                    self.filterIncomeArr[index] = expense
                }
//                self.filterIncomeArr[index] = expense
//                print("index", index, filterIncomeArr)
//                let indexExp = expenseArr.firstIndex(where: {$0.id == expense.id})
//                print("indexExp", indexExp)
//                self.expenseArr[(indexExp)!] = expense
                calculate()
                testIncome = true
                self.tableView.reloadData()
            } else if (checkValue == "expense") {
                if (check == false) {
                    let indexExp = expenseArr.firstIndex(where: {$0.id == expense.id})
                    print("indexExp", indexExp)
                    self.expenseArr[(indexExp)!] = expense
                } else {
                    self.filterExpenseArr[index] = expense
                }
                self.filterExpenseArr[index] = expense
//                let indexExp = expenseArr.firstIndex(where: {$0.id == expense.id})
//                print("indexExp", indexExp)
//                self.expenseArr[(indexExp)!] = expense
                calculate()
                testExp = true
                self.tableView.reloadData()
            } else if (checkValue == "notAll") {
                self.filterMonth[index] = expense
                let indexExp = expenseArr.firstIndex(where: {$0.id == expense.id})
                self.expenseArr[(indexExp)!] = expense
                calculate()
                testIncome = false
                testExp = false
                self.tableView.reloadData()
            } else if (checkValue == "income selectMonth") {
                print("check select income")
                self.filterMonthIncome[index] = expense
                print("self Month", filterMonthIncome)
                let indexExp = expenseArr.firstIndex(where: {$0.id == expense.id})
                self.expenseArr[(indexExp)!] = expense
                calculate()
                testIncome = true
                self.tableView.reloadData()
                
            } else if (checkValue == "expense selectMonth") {
                self.filterMonthExpense[index] = expense
                let indexExp = expenseArr.firstIndex(where: {$0.id == expense.id})
                self.expenseArr[(indexExp)!] = expense
                calculate()
                testExp = true
                self.tableView.reloadData()
        }else {
                self.expenseArr[index] = expense
                calculate()
                testIncome = false
                testExp = false
                self.tableView.reloadData()
            }
        }
    }
}
@available(iOS 14.0, *)

extension HomeVC: SendCreateData {
    
    func createData(expense: ExpenseModel, checkValue: String, check: Bool) {
        print("inner create Expense", expense)
        self.dismiss(animated: true) { [self] in
            if (checkValue == "Income") {
                    print("income success")
                check == true ? self.filterExpenseArr.append(expense) : self.filterIncomeArr.append(expense)
//                    self.filterIncomeArr.append(expense)
                    self.expenseArr.append(expense)
                    self.tableView.reloadData()
                    print("Total Income", filterIncomeArr.count)
                    calculate()
            } else if (checkValue == "Expense") {
                    print("expense success")
                check == false ? self.filterIncomeArr.append(expense) : self.filterExpenseArr.append(expense)
                    self.expenseArr.append(expense)
                    self.tableView.reloadData()
                    print("Total Expense", filterExpenseArr.count)
                    calculate()
            } else if (checkValue == "All") {
                self.expenseArr.append(expense)
                self.tableView.reloadData()
                calculate()
            }
        }
    }
}





