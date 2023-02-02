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

class HomeVC: UIViewController, sendCSVData, Send, SendCreateData {
    
    
    func createData(expense: Expenses, check: String) {
        print("hellocreate", expense)
        if (testIncome == true) {
            if (check == "Expense" || check == "Income") {
                dataItem?.append(expense)
                selectIncome == true ? fetchMonthIncomeData() : fetchIncomeData()
                self.tableView.reloadData()
                calculate()
            }
        } else if (testExp == true) {
            if (check == "Income" || check == "Expense") {
                dataItem?.append(expense)
                selectExpense == true ? fetchMonthExpenseData() : fetchExpenseData()
                self.tableView.reloadData()
                calculate()
            }
        } else {
            dataItem?.append(expense)
            self.tableView.reloadData()
            calculate()
        }
    }
    
    
    func updateData(expense: Expenses, check: String) {
        if (testIncome == true) {
            if (selected == 0) {
                fetchIncomeData()
            } else if (selected != 0) {
                fetchMonthIncomeData()
            }
            
        } else if (testExp == true) {
            if (selected == 0) {
                fetchExpenseData()
            } else if (selected != 0) {
                fetchMonthExpenseData()
            }
        }
        print("helloUpdate", expense)
        calculate()
        tableView.reloadData()
    }
    
    func csvData(expense: ExpenseModel) {
        print("inner csv", expense)
        self.dismiss(animated: true) { [self] in
            self.expenseArr.append(expense)
            calculate()
            self.tableView.reloadData()
        }
    }
    
    var expenseArr = [ExpenseModel]()
    
    var dataItem:[Expenses]?
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
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
    var selectIncome: Bool = false
    var selectExpense: Bool = false
    
    fileprivate let actionButton = JJFloatingActionButton()
    
    var balance: Int = 0
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
            
            if (selected == 0) {
                fetchExpense()
            } else {
                fetchMonthData()
            }
            calculate()
            tableView.reloadData()
            
        }
        
        fetchExpense()
        print("dataitem", dataItem as Any)
    }
    
    
    func fetchExpense() {
        do {
            let request = Expenses.fetchRequest() as NSFetchRequest<Expenses>
            let sort = NSSortDescriptor(key: #keyPath(Expenses.date), ascending: false)
            request.sortDescriptors = [sort]
            self.dataItem = try context.fetch(request)
            
            DispatchQueue.main.async {
                self.calculate()
                self.tableView.reloadData()
            }
        } catch {
            print("error")
        }
    }
    
    func fetchIncomeData() {
        do {
            let requeset = Expenses.fetchRequest() as NSFetchRequest<Expenses>
            let pred = NSPredicate(format: "type = %@", false as NSNumber)
            requeset.predicate = pred
            self.dataItem = try context.fetch(requeset)
            self.calculate()
        } catch {
            print("error")
        }
    }
    
    func fetchExpenseData() {
        do {
            let requeset = Expenses.fetchRequest() as NSFetchRequest<Expenses>
            let pred = NSPredicate(format: "type = %@", true as NSNumber)
            requeset.predicate = pred
            self.dataItem = try context.fetch(requeset)
            self.calculate()
        } catch {
            print("error")
        }
    }
    
    func fetchMonthData() {
        do {
            let requeset = Expenses.fetchRequest() as NSFetchRequest<Expenses>
            
            print("selMonth", selected)
            let pred = NSPredicate(format: "date >= %@ AND date <= %@", "2023/0\(selected)/01", "2023/0\(selected)/31")
            requeset.predicate = pred
            self.dataItem = try context.fetch(requeset)
            
            DispatchQueue.main.async {
                self.calculate()
                self.tableView.reloadData()
            }
        } catch {
            print("error")
        }
    }
    
    func fetchMonthIncomeData() {
        do {
            let requeset = Expenses.fetchRequest() as NSFetchRequest<Expenses>
            
            print("selMonth", selected)
            let pred = NSPredicate(format: "date >= %@ AND date <= %@ AND type = %@", "2023/0\(selected)/01", "2023/0\(selected)/31", false as NSNumber)
            requeset.predicate = pred
            self.dataItem = try context.fetch(requeset)
            
            DispatchQueue.main.async {
                self.calculate()
                self.tableView.reloadData()
            }
        } catch {
            print("error")
        }
    }
    
    func fetchMonthExpenseData() {
        do {
            let requeset = Expenses.fetchRequest() as NSFetchRequest<Expenses>
            
            print("selMonth", selected)
            let pred = NSPredicate(format: "date >= %@ AND date <= %@ AND type = %@", "2023/0\(selected)/01", "2023/0\(selected)/31", true as NSNumber)
            requeset.predicate = pred
            self.dataItem = try context.fetch(requeset)
            
            DispatchQueue.main.async {
                self.calculate()
                self.tableView.reloadData()
            }
        } catch {
            print("error")
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
        
        if (selected == 0) {
            fetchIncomeData()
        } else {
            selectIncome = true
            fetchMonthIncomeData()
        }
        
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
        
        if (selected == 0) {
            fetchExpenseData()
        } else {
            selectExpense = true
            fetchMonthExpenseData()
        }
        
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
        if (testIncome == true) {
            vc.check = "income"
        } else if (testExp == true) {
            vc.check = "expense"
        }
        vc.delegate = self
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
            let filterExp = dataItem?.filter{$0.type == true}.map({$0.amount}).reduce(0, +)
            print("filterExp", type(of: filterExp))
            expenseLabel.text = "-" + curFormat.string(from: Int64(Int(filterExp ?? 0)) as NSNumber)! + "MMK"
            
//            Income
            let filterInc = dataItem?.filter{$0.type == false}.filter{$0.date ?? "Hello" >= "2023/01/01"}.filter{$0.date ?? "hello" <= "2023/12/31"}
            let sal = filterInc?.filter({$0.category == "Salary"}).map({$0.amount}).reduce(0, +)
           
            if (sal ?? 0 >= 0 && sal ?? 0 <= 2000000) {
                salAmt = Double(0)
            }  else if (sal ?? 0 >= 2000001 && sal ?? 0 <= 5000000) {
                salAmt = calculateTaxRate(percentageVal: 5, incomeAmount: Double(sal!))
            } else if (sal ?? 0 >= 5000001 && sal ?? 0 <= 10000000) {
                salAmt = calculateTaxRate(percentageVal: 10, incomeAmount: Double(sal!))
            } else if (sal ?? 0 >= 10000001 && sal ?? 0 <= 20000000) {
                salAmt = calculateTaxRate(percentageVal: 15, incomeAmount: Double(sal!))
            } else if (sal ?? 0 >= 20000001 && sal ?? 0 <= 30000000) {
                salAmt = calculateTaxRate(percentageVal: 20, incomeAmount: Double(sal!))
            } else {
                salAmt = calculateTaxRate(percentageVal: 25, incomeAmount: Double(sal!))
            }
            print("home sal", salAmt)
            
            let bonus = filterInc?.filter({$0.category == "Bonus"}).map({$0.amount}).reduce(0, +)
            bonusAmt = calculateTaxRate(percentageVal: 22, incomeAmount: Double(bonus ?? 0))
            print("home bonus", bonusAmt)
            
            let totalTax = salAmt + bonusAmt
            
            let totalIncome = dataItem?.filter{$0.type == false}.filter{$0.date ?? "Hello" >= "2023/01/01"}.filter{$0.date ?? "hello" <= "2023/12/31"}.map({$0.amount}).reduce(0, +)
            print("total Income", totalIncome as Any)
            let finalTotalIncome = Double(totalIncome ?? 0) - totalTax
            print("finalInc", finalTotalIncome)
            incomeLabel.text = "+" + curFormat.string(from: Int64(Int(finalTotalIncome)) as NSNumber)! + "MMK"
            
//            Balance
            let balance = finalTotalIncome - Double(Int64(Int(filterExp ?? 0)))
            print("balance", balance)
            balanceLabel.text = curFormat.string(from: Int64(Int(balance)) as NSNumber)! + "MMK"

        } else {
            print("filter select", selected)
            let filterExp = dataItem?.filter{$0.type == true}.filter{$0.date ?? "Hello" >= "2023/0\(selected)/01"}.filter{$0.date ?? "hello" <= "2023/0\(selected)/31"}.map({$0.amount}).reduce(0, +)
            
            expenseLabel.text = String(Int64(Int((filterExp ?? 0)))) + "MMK"
            
            let filterInc = dataItem?.filter{$0.type == false}.filter{$0.date ?? "Hello" >= "2023/0\(selected)/01"}.filter{$0.date ?? "hello" <= "2023/0\(selected)/31"}.map({$0.amount}).reduce(0, +)
            
            incomeLabel.text = String(Int64(Int((filterInc ?? 0)))) + "MMK"
            
            let balance = filterInc! &- filterExp!
            print("balance", balance)
            balanceLabel.text = String(Int64(Int(balance))) + "MMK"
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
}
    



@available(iOS 14.0, *)
extension HomeVC: UITableViewDataSource, UITableViewDelegate {
        
        func numberOfSections(in tableView: UITableView) -> Int {
            return 1
        }
        
        
        func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return self.dataItem?.count ?? 0
        }
        
        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            let cellIdentifier = "ExpenseTableViewCell"
            let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier,for: indexPath) as! ExpenseTableViewCell
            
            let item = self.dataItem![indexPath.row]
            cell.title?.text = item.title
            cell.category?.text = item.category
            cell.amount?.text = String(item.amount)
            cell.date?.text = item.date
            cell.type?.text = String(item.type) == "true" ? "Expense" : "Income"
            if (cell.type.text == "Expense") {
                cell.itemView.backgroundColor = getUIColor(hex: "#ee6c4d")
            } else {
                cell.itemView.backgroundColor = getUIColor(hex: "#98c1d9")
            }
            return cell
        }
        
        func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
            return true
        }
        
        func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
            let cellIdentifier = "ExpenseTableViewCell"
            let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier,for: indexPath as IndexPath) as! ExpenseTableViewCell
            
            let item = self.dataItem![indexPath.row]
            cell.title?.text = item.title
            cell.category?.text = item.category
            cell.amount?.text = String(item.amount)
            cell.date?.text = item.date
            cell.type?.text = String(item.type) == "true" ? "Expense" : "Income"
            if (cell.type.text == "Expense") {
                cell.itemView.backgroundColor = getUIColor(hex: "#ee6c4d")
            } else {
                cell.itemView.backgroundColor = getUIColor(hex: "#98c1d9")
            }
            
            tableView.deselectRow(at: indexPath, animated: true)
            let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "updateExpense") as! UpdateExpenseVC
            vc.modalPresentationStyle = .overFullScreen
            vc.updateItem = item
            if (testIncome == true) {
                vc.check = "Income"
            } else if (testExp == true) {
                vc.check = "Expense"
            }
            vc.delegate = self
            tableView.reloadData()
            present(vc, animated: true)
        }
        
        func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath)
        -> UISwipeActionsConfiguration? {
            let action = UIContextualAction(style: .destructive, title: "Delete") { [self] (action, view, completionHandler) in
                let itemDel = self.dataItem![indexPath.row]
                self.context.delete(itemDel)
                
                do {
                    try self.context.save()
                    calculate()
                } catch {
                    
                }
                if (testIncome == true) {
                    self.fetchIncomeData()
                } else if (testExp == true) {
                    self.fetchExpenseData()
                } else {
                    self.fetchExpense()
                }
                
                tableView.reloadData()
            }
            return UISwipeActionsConfiguration(actions: [action])
        }
        
    }








