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


class HomeVC: UIViewController {
    
    
    var expenseArr = [ExpenseModel]()
    var filterIncomeArr = [ExpenseModel]()
    var filterExpenseArr = [ExpenseModel]()
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var balanceLabel: UILabel!
    @IBOutlet weak var expenseLabel: UILabel!
    @IBOutlet weak var incomeLabel: UILabel!
    
    @IBOutlet weak var homeView: UIView!
    
    @IBOutlet weak var allBtn: UIButton!
    @IBOutlet weak var incomeBtn: UIButton!
    @IBOutlet weak var expenseBtn: UIButton!
    
    var testIncome: Bool = false
    var testExp: Bool = false
    
    fileprivate let actionButton = JJFloatingActionButton()
    
    var balance: Int = 0
    var items:[NSManagedObject] = []
    
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
        
        
        readExpenseData()
        calculate()
        func updateData(expense: ExpenseModel, index: Int) {
            self.dismiss(animated: true) { [self] in
                self.expenseArr[index] = expense
                calculate()
                self.tableView.reloadData()
            }
        }
    }
    
    
    @IBAction func menuButton(_ sender: Any) {
        self.drawerController?.openSide(.left)
    }
    
    @IBAction func allTapped(_ sender: Any) {
        testIncome = false
        testExp = false
        
        if (allBtn.isTouchInside == true) {
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
        print("tap exp", filterExpenseArr)
        
        if (expenseBtn.isTouchInside == true) {
            expenseBtn.backgroundColor = getUIColor(hex: "#3D5A80")
            expenseBtn.tintColor = .white
            allBtn.backgroundColor = .systemGray
            incomeBtn.backgroundColor = .systemGray
        }
        tableView.reloadData()
    }
    
    func createTapped(_ sender: Any) {
        testExp = false
        testIncome = false
        
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "createExpense") as! CreateExpenseVC
        vc.modalPresentationStyle = .overFullScreen
        vc.delegate = self
        vc.myBalance = balance
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
        
        actionButton.addItem(title: "Import", image:UIImage(systemName: "square.and.arrow.down")) { [self] item in
            goToimport()
        }
        
        actionButton.addItem(title: "Export", image:UIImage(systemName: "square.and.arrow.up")) { [self] item in
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
    
    
    // calculate amout
    func calculate() {
        
        let curFormat = NumberFormatter()
        curFormat.usesGroupingSeparator = true
        curFormat.locale = Locale.current
        curFormat.maximumFractionDigits = 2
        curFormat.decimalSeparator = "."
        curFormat.numberStyle = .decimal
        
        let filterExpArr = expenseArr.filter{$0.type == true}
        let res1 = filterExpArr.map{Int($0.amount!)}
        let expRes = res1.reduce(0, +)
        expenseLabel.text = "-" + curFormat.string(from: expRes as NSNumber)! + "MMK"
        
        // For Salary
        let filterIncArr = expenseArr.filter{$0.type == false}.filter{$0.category == "Salary"}
        let sumfirstTax = filterIncArr.filter{$0.amount! >= 0}.filter{$0.amount! <= 2000000}.map{Int($0.amount!)}.reduce(0, +)
            
        let secTax = filterIncArr.filter{$0.amount! >= 2000001}.filter{$0.amount! <= 5000000}
        let secTaxArr = secTax.map{Int($0.amount!)}
        let sumSecTax = secTaxArr.reduce(0, +)
        let finalSumSecTax = calculateTax(percentageVal: Double(5 * secTaxArr.count), incomeAmount: Double(sumSecTax))
        
        let thirdTax = filterIncArr.filter{$0.amount! >= 5000001}.filter{$0.amount! <= 10000000}
        let thirdTaxArr = thirdTax.map{Int($0.amount!)}
        let sumThirdTax = thirdTaxArr.reduce(0, +)
        let finalSumThirdTax = calculateTax(percentageVal: Double(10 * thirdTaxArr.count), incomeAmount: Double(sumThirdTax))
        
        let fourthTax = filterIncArr.filter{$0.amount! >= 10000001}.filter{$0.amount! <= 20000000}
        let fourthTaxArr = fourthTax.map{Int($0.amount!)}
        let sumFourthTax = fourthTaxArr.reduce(0, +)
        let finalSumFourthTax = calculateTax(percentageVal: Double(15 * fourthTaxArr.count), incomeAmount: Double(sumFourthTax))
        
        
        let fithTax = filterIncArr.filter{$0.amount! >= 20000001}.filter{$0.amount! <= 30000000}
        let fifthTaxArr = fithTax.map{Int($0.amount!)}
        let sumFifthTax = fifthTaxArr.reduce(0, +)
        let finalSumFifthTax = calculateTax(percentageVal: Double(20 * fifthTaxArr.count), incomeAmount: Double(sumFifthTax))
        
        let sixthTax = filterIncArr.filter{$0.amount! >= 30000001}
        let sixthTaxArr = sixthTax.map{Int($0.amount!)}
        let sumSixthTax = sixthTaxArr.reduce(0, +)
        let finalSumSixthax = calculateTax(percentageVal: Double(25 * sixthTaxArr.count), incomeAmount: Double(sumSixthTax))
        
        
        //        for bonuse Tax
        let bonusArr = expenseArr.filter{$0.type == false}.filter{$0.category == "Bonus"}.filter{$0.date! >= "2023/01/01"}.filter{$0.date! <= "2023/12/31"}.map{$0.amount!}.reduce(0, +)
        print("bonus Arr", bonusArr)
        
        var bonusRes: Double = 0
        if (bonusArr >= 1000000) {
            bonusRes = calculateTax(percentageVal: Double(22), incomeAmount: Double(bonusArr))
        }
        print("bonusRes", bonusRes)
        
        //      last tax
        let lastIncome = expenseArr.filter{$0.type == false}.filter{$0.category != "Salary"}.filter{$0.category != "Bonus"}.map{$0.amount!}.reduce(0, +)
        print("lastIncome", lastIncome)
        
        
        //        final Total Income Result
        let totalIncome = Double(sumfirstTax) + finalSumSecTax + finalSumThirdTax + finalSumFourthTax + finalSumFifthTax + finalSumSixthax + bonusRes + Double(lastIncome)
        print("total Income", totalIncome, bonusRes)
        incomeLabel.text = "+" + curFormat.string(from: totalIncome as NSNumber)! + "MMK"
        
        
        let balanceRes = totalIncome - Double(expRes)
        balanceLabel.text = curFormat.string(from: balanceRes as NSNumber)! + "MMK"
        balance = Int(balanceRes)
            
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




extension HomeVC: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
            return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (testIncome == true) {
            print("income count", filterIncomeArr.count)
            return filterIncomeArr.count
        } else if (testExp == true) {
            print("expense count", filterExpenseArr.count)
            return filterExpenseArr.count
        } else {
            print("total count", expenseArr.count)
            return expenseArr.count
        }
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "ExpenseTableViewCell"
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier,for: indexPath) as! ExpenseTableViewCell
        print("tablecount",filterIncomeArr.count,filterExpenseArr.count,expenseArr.count)
        
        if testIncome == true {
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
            
//            for salary
            if (income.category == "Salary") {
                if (income.amount! >= 0 && income.amount! <= 2000000) {
                    cell.amount.text = curFormat.string(from: income.amount! as NSNumber)
                } else if (income.amount! >= 2000001 && income.amount! <= 5000000) {
                    print("tax5")
                    let res = calculateTax(percentageVal: 5, incomeAmount: Double(income.amount!))
                    cell.amount.text = curFormat.string(from: res as NSNumber)
                } else if (income.amount! >= 5000001 && income.amount! <= 10000000) {
                    let res = calculateTax(percentageVal: 10, incomeAmount: Double(income.amount!))
                    cell.amount.text = curFormat.string(from: res as NSNumber)
                } else if (income.amount! >= 10000001 && income.amount! <= 20000000) {
                    let res = calculateTax(percentageVal: 15, incomeAmount: Double(income.amount!))
                    cell.amount.text = curFormat.string(from: res as NSNumber)
                } else if (income.amount! >= 20000001 && income.amount! <= 30000000) {
                    print("tax20")
                    let res = calculateTax(percentageVal: 20, incomeAmount: Double(income.amount!))
                    cell.amount.text = curFormat.string(from: res as NSNumber)
                } else {
                    let res = calculateTax(percentageVal: 25, incomeAmount: Double(income.amount!))
                    cell.amount.text = curFormat.string(from: res as NSNumber)
                }
            } else if (income.category == "Bonus") {
                if (income.amount! >= 1000000) {
                    let res = calculateTax(percentageVal: 22, incomeAmount: Double(income.amount!))
                    cell.amount.text = curFormat.string(from: res as NSNumber)
                } else {
                    cell.amount.text = curFormat.string(from: income.amount! as NSNumber)
                }
            } else {
                cell.amount.text = curFormat.string(from: income.amount! as NSNumber)
            }
            
            
            cell.date.text = income.date
            cell.type.text = String(income.type!) == "true" ? "Expense" : "Income"

            if (cell.type.text == "Expense") {
                cell.itemView.backgroundColor = getUIColor(hex: "#ee6c4d")
            } else {
                cell.itemView.backgroundColor = getUIColor(hex: "#98c1d9")
            }
            
            return cell
        } else if (testExp == true) {
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
            let expense = expenseArr[indexPath.row]
            print("outer expense", expense)
            cell.title.text = expense.title
            cell.category.text = expense.category
            
            let curFormat = NumberFormatter()
            curFormat.usesGroupingSeparator = true
            curFormat.locale = Locale.current
            curFormat.maximumFractionDigits = 2
            curFormat.decimalSeparator = "."
            curFormat.numberStyle = .decimal
            
//            For Salary
            if (expense.category == "Salary") {
                if (expense.amount! >= 0 && expense.amount! <= 2000000) {
                    cell.amount.text = curFormat.string(from: expense.amount! as NSNumber)
                } else if (expense.amount! >= 2000001 && expense.amount! <= 5000000) {
                    print("tax5")
                    let res = calculateTax(percentageVal: 5, incomeAmount: Double(expense.amount!))
                    cell.amount.text = curFormat.string(from: res as NSNumber)
                } else if (expense.amount! >= 5000001 && expense.amount! <= 10000000) {
                     let res = calculateTax(percentageVal: 10, incomeAmount: Double(expense.amount!))
                     cell.amount.text = curFormat.string(from: res as NSNumber)
                } else if (expense.amount! >= 10000001 && expense.amount! <= 20000000) {
                     let res = calculateTax(percentageVal: 15, incomeAmount: Double(expense.amount!))
                     cell.amount.text = curFormat.string(from: res as NSNumber)
                } else if (expense.amount! >= 20000001 && expense.amount! <= 30000000) {
                     print("tax20")
                     let res = calculateTax(percentageVal: 20, incomeAmount: Double(expense.amount!))
                     cell.amount.text = curFormat.string(from: res as NSNumber)
                } else {
                     let res = calculateTax(percentageVal: 25, incomeAmount: Double(expense.amount!))
                     cell.amount.text = curFormat.string(from: res as NSNumber)
                }
             } else if (expense.category == "Bonus") {
                 if (expense.amount! >= 1000000) {
                     let res = calculateTax(percentageVal: 22, incomeAmount: Double(expense.amount!))
                     cell.amount.text = curFormat.string(from: res as NSNumber)
                 } else {
                     cell.amount.text = curFormat.string(from: expense.amount! as NSNumber)
                 }
             } else {
                 cell.amount.text = curFormat.string(from: expense.amount! as NSNumber)
             }
            
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
                                        
                    do {
                        guard let result = try managedContext.fetch(fetchRequest) as? [NSManagedObject] else {
                            return
                        }
                        let objc = result[indexPath.row]
                        print("objc", objc)
                        managedContext.delete(objc)
                        do {
                            try managedContext.save()
                            expenseArr.remove(at: indexPath.row)
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
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier,for: indexPath) as! ExpenseTableViewCell
        
        if (testIncome == true) {
            let income = filterIncomeArr[indexPath.row]
            cell.title.text = income.title
            cell.category.text = income.category
            
            if (income.category == "Salary") {
                if (income.amount! >= 0 && income.amount! <= 2000000) {
                    cell.amount.text = String(income.amount!)
                } else if (income.amount! >= 2000001 && income.amount! <= 5000000) {
                    print("tax5")
                     let res = calculateTax(percentageVal: 5, incomeAmount: Double(income.amount!))
                     cell.amount.text = String(res)
                } else if (income.amount! >= 5000001 && income.amount! <= 10000000) {
                    let res = calculateTax(percentageVal: 10, incomeAmount: Double(income.amount!))
                    cell.amount.text = String(res)
                } else if (income.amount! >= 10000001 && income.amount! <= 20000000) {
                    let res = calculateTax(percentageVal: 15, incomeAmount: Double(income.amount!))
                    cell.amount.text = String(res)
                } else if (income.amount! >= 20000001 && income.amount! <= 30000000) {
                    print("tax20")
                    let res = calculateTax(percentageVal: 20, incomeAmount: Double(income.amount!))
                    cell.amount.text = String(res)
                } else {
                    let res = calculateTax(percentageVal: 25, incomeAmount: Double(income.amount!))
                    cell.amount.text = String(res)
                }
            } else if (income.category == "Bonus") {
                if (income.amount! >= 1000000) {
                    let res = calculateTax(percentageVal: 22, incomeAmount: Double(income.amount!))
                    cell.amount.text = String(res)
                } else {
                    cell.amount.text = String(income.amount!)
                }
            } else {
                cell.amount.text = String(income.amount!)
            }
           
            
            cell.date.text = income.date
            cell.type.text = String(income.type!) == "true" ? "Expense" : "Income"
            
            tableView.deselectRow(at: indexPath, animated: true)
            let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "updateExpense") as! UpdateExpenseVC
            vc.modalPresentationStyle = .overFullScreen
            vc.index = indexPath.row
            vc.title1 = cell.title.text!
            vc.amount = cell.amount.text!
            vc.category = cell.category.text!
            vc.dateRes = cell.date.text!
            vc.type = cell.type.text!
            vc.check = "income"
            vc.delegate = self

            present(vc, animated: true)
        } else if (testExp == true) {
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
            vc.title1 = cell.title.text!
            vc.amount = cell.amount.text!
            vc.category = cell.category.text!
            vc.dateRes = cell.date.text!
            vc.type = cell.type.text!
            vc.check = "expense"
            vc.delegate = self

            present(vc, animated: true)
        } else {
            let expense = expenseArr[indexPath.row]
            print("expenseDetail", expense)
            cell.title.text = expense.title
            cell.category.text = expense.category
            
            // for salary
            if (expense.category == "Salary") {
                if (expense.amount! >= 0 && expense.amount! <= 2000000) {
                    cell.amount.text = String(expense.amount!)
                } else if (expense.amount! >= 2000001 && expense.amount! <= 5000000) {
                    print("tax5")
                     let res = calculateTax(percentageVal: 5, incomeAmount: Double(expense.amount!))
                     cell.amount.text = String(res)
                } else if (expense.amount! >= 5000001 && expense.amount! <= 10000000) {
                    let res = calculateTax(percentageVal: 10, incomeAmount: Double(expense.amount!))
                    cell.amount.text = String(res)
                } else if (expense.amount! >= 10000001 && expense.amount! <= 20000000) {
                    let res = calculateTax(percentageVal: 15, incomeAmount: Double(expense.amount!))
                    cell.amount.text = String(res)
                } else if (expense.amount! >= 20000001 && expense.amount! <= 30000000) {
                    print("tax20")
                    let res = calculateTax(percentageVal: 20, incomeAmount: Double(expense.amount!))
                    cell.amount.text = String(res)
                } else {
                    let res = calculateTax(percentageVal: 25, incomeAmount: Double(expense.amount!))
                    cell.amount.text = String(res)
                }
            } else if (expense.category == "Bonus") {
                if (expense.amount! >= 1000000) {
                    let res = calculateTax(percentageVal: 22, incomeAmount: Double(expense.amount!))
                    cell.amount.text = String(res)
                } else {
                    cell.amount.text = String(expense.amount!)
                }
            } else {
                cell.amount.text = String(expense.amount!)
            }

            
    
            cell.date.text = expense.date
            cell.type.text = String(expense.type!) == "true" ? "Expense" : "Income"
            
            tableView.deselectRow(at: indexPath, animated: true)
            let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "updateExpense") as! UpdateExpenseVC
            vc.modalPresentationStyle = .overFullScreen
            vc.index = indexPath.row
            vc.title1 = cell.title.text!
            vc.amount = cell.amount.text!
            vc.category = cell.category.text!
            vc.dateRes = cell.date.text!
            vc.type = cell.type.text!
            vc.check = "all"
            vc.delegate = self

            present(vc, animated: true)
        }
        
    }
}


extension HomeVC: Send {
    func updateData(expense: ExpenseModel, index: Int, checkValue: String) {
        print("inner Expense", expense, index, checkValue)
        self.dismiss(animated: true) { [self] in
            if (checkValue == "income") {
                self.filterIncomeArr[index] = expense
                calculate()
                self.tableView.reloadData()
            } else if (checkValue == "expense") {
                self.filterExpenseArr[index] = expense
                calculate()
                self.tableView.reloadData()
            } else {
                self.expenseArr[index] = expense
                calculate()
                testIncome = false
                testExp = false
                self.tableView.reloadData()
            }
        }
    }
}

extension HomeVC: SendCreateData {
    func createData(expense: ExpenseModel) {
        print("inner create Expense", expense)
        self.dismiss(animated: true) { [self] in
            if (testExp == true) {
                self.filterExpenseArr.append(expense)
                calculate()
                self.tableView.reloadData()
            } else if (testIncome == true) {
                self.filterIncomeArr.append(expense)
                calculate()
                self.tableView.reloadData()
            } else {
                self.expenseArr.append(expense)
                calculate()
                self.tableView.reloadData()
            }
            
        }
    }
}

extension HomeVC: sendCSVData {
    func csvData(expense: ExpenseModel) {
        print("inner csv", expense)
        self.dismiss(animated: true) { [self] in
            self.expenseArr.append(expense)
            calculate()
            self.tableView.reloadData()
        }
    }
}




