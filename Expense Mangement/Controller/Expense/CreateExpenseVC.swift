//
//  CreateExpenseVC.swift
//  Expense Mangement
//
//  Created by Wunna on 12/13/22.
//

import UIKit
import DropDown
import CoreData


protocol SendCreateData{
    func createData(expense: ExpenseModel)
}


class CreateExpenseVC: UIViewController, UINavigationControllerDelegate {
    
    var expenseArr = [ExpenseModel]()
   
    var delegate: SendCreateData?
    var myBalance: Int = 0
    
    @IBOutlet weak var vwDropDown: UIView!
    @IBOutlet weak var catTitle: UILabel!
    @IBOutlet weak var titleTF: UITextField!
    @IBOutlet weak var amountTF: UITextField!
    @IBOutlet weak var catTF: UIView!
    
    
    @IBOutlet weak var mySwitch: UISwitch!
    @IBOutlet weak var expenseLabel: UILabel!
    @IBOutlet weak var incomeLabel: UILabel!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var dateTF: UITextField!
    
    // validation
    
    @IBOutlet weak var titleErr: UILabel!
    @IBOutlet weak var amountErr: UILabel!
    @IBOutlet weak var typeErr: UILabel!
    @IBOutlet weak var dateErr: UILabel!
    @IBOutlet weak var catErr: UILabel!
    
    let dropDown = DropDown()
    let catExpenseArr = ["Food", "Utilities", "Insurance", "Medical & HealthCare", "Entertainment", "Personal Spending"]
    let catIncomeArr = ["Salary", "Gift", "Bonus", "Award"]
    let dateFormatter = DateFormatter()

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let container = NSPersistentContainer(name: "ExpenseMangement")
        print(container.persistentStoreDescriptions.first?.url as Any)
        
        datePicker.semanticContentAttribute = .forceRightToLeft
        datePicker.subviews.first?.semanticContentAttribute = .forceRightToLeft
        
        dropDown.anchorView = vwDropDown
        dropDown.dataSource = mySwitch.isOn == true ? catIncomeArr : catExpenseArr
        dropDown.bottomOffset = CGPoint(x: 0, y:(dropDown.anchorView?.plainView.bounds.height)!)
        dropDown.topOffset = CGPoint(x: 0, y:-(dropDown.anchorView?.plainView.bounds.height)!)
        dropDown.direction = .bottom
        
        
        dropDown.selectionAction = { [unowned self] (index: Int, item: String) in
            print("Selected item: \(item) at index: \(index)")
            catTitle.text = mySwitch.isOn == true ? catIncomeArr[index] : catExpenseArr[index]
            print("Income cartTitle", catTitle.text)
    //            validation()
            if (catTitle.text == "Select Category") {
                vwDropDown.layer.borderColor = UIColor.red.cgColor
                vwDropDown.layer.borderWidth = 1.0
                catErr.text = "Category is required"
            } else if (catTitle.text!.count >= 1) {
                vwDropDown.layer.borderColor = UIColor.systemGray3.cgColor
                vwDropDown.layer.borderWidth = 1.0
                catErr.text = ""
            }
        
        }
        
        
        dateFormatter.dateFormat = "yyyy/MM/dd"
        dateTF.inputView = datePicker
        datePicker.datePickerMode = .date
        dateTF.text = dateFormatter.string(from: datePicker.date)
        
        dateTF.isHidden = true
        readExpenseData()
        hideKeyboardWhenTappedAround()
        
        print("my balance", myBalance)
        
            
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
//    hide keyboard
    func hideKeyboardWhenTappedAround() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(CreateExpenseVC.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    // Validation

    @IBAction func titleChanged(_ sender: Any) {
        titleTF.layer.borderColor = UIColor.systemGray3.cgColor
        titleTF.layer.borderWidth = 1.0
        titleErr.text = ""
    }
    
    @IBAction func amountChanged(_ sender: Any) {
        amountTF.layer.borderColor = UIColor.systemGray3.cgColor
        amountTF.layer.borderWidth = 1.0
        amountErr.text = ""
    }
    
    // Choose expense or income
   
    @IBAction func switchChange(_ sender: Any) {
        if(mySwitch.isOn) {
            incomeLabel.text = "Income"
            dropDown.dataSource = catIncomeArr
        } else {
            expenseLabel.text = "Expense"
            dropDown.dataSource = catExpenseArr 
        }
    }
    
    
    @IBAction func datePickerValueChanged(_ sender: UIDatePicker) {
        dateTF.text = dateFormatter.string(from: sender.date)
        view.endEditing(true)
    }
    
    @IBAction func catTapped(_ sender: Any) {
        dropDown.show()
    }
    
    @IBAction func backTapped(_ sender: Any) {
        if let nav = self.navigationController {
            nav.popViewController(animated: true)
            nav.delegate = self
            } else {
                self.dismiss(animated: true, completion: nil)
            }
    }
    
    @IBAction func createTapped(_ sender: Any) {
        
        if (titleTF.text?.isEmpty == true || ((amountTF.text?.isEmpty) == true) || catTitle.text == "Select Category") {
            validation()
        } else {
            print("create")
//       get current date
            let date = Date()
            dateFormatter.dateFormat = "yyyy/MM/dd"
            let currentDate = dateFormatter.string(from: date)
            
            guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {return}
            let managedContext = appDelegate.persistentContainer.viewContext
            guard let personEntity = NSEntityDescription.entity(forEntityName: "Expenses", in: managedContext) else { return }
            let expense = NSManagedObject(entity: personEntity, insertInto: managedContext)

            expense.setValue(titleTF.text, forKey: "title")
            expense.setValue(catTitle.text, forKey: "category")
            expense.setValue(Int(amountTF.text!), forKey: "amount")
            expense.setValue(mySwitch.isOn ? false : true, forKey: "type")
            expense.setValue(dateTF.text, forKey: "date")
            expense.setValue(currentDate, forKey: "createdAt")
            expense.setValue(currentDate, forKey: "updatedAt")
                        
            do {
                try managedContext.save()
                debugPrint("Data Saved")
            
                
                let createResult = ExpenseModel(title: titleTF.text, category: catTitle.text, amount: Int((amountTF.text! as NSString).integerValue), date: dateTF.text, type: mySwitch.isOn ? false : true, createdAt: dateTF.text, updatedAt: dateTF.text)
                print("Result", createResult)

                self.dismiss(animated: true, completion: {
                    self.delegate?.createData(expense: createResult)
                })
            } catch let error as NSError {
                debugPrint("error", error)
            }
        }
    }
    
    
    func validation() {
        if ((titleTF.text?.isEmpty) != nil) {
            titleTF.layer.borderColor = UIColor.red.cgColor
            titleTF.layer.borderWidth = 1.0
            titleErr.text = "Title is required"
        } else if (titleTF.text!.count >= 1) {
            titleChanged(titleTF!)
        }
        
        if ((amountTF.text?.isEmpty) != nil) {
            amountTF.layer.borderColor = UIColor.red.cgColor
            amountTF.layer.borderWidth = 1.0
            amountErr.text = "Amount is required"
        } else if (amountTF.text!.count >= 1) {
            amountChanged(amountTF!)
        }
        
//        if Int(amountTF.text!)! > myBalance {
//            amountTF.layer.borderColor = UIColor.red.cgColor
//            amountTF.layer.borderWidth = 1.0
//            amountErr.text = "Amount is greater than my balance"
//        }
        
        if (catTitle.text == "Select Category") {
            vwDropDown.layer.borderColor = UIColor.red.cgColor
            vwDropDown.layer.borderWidth = 1.0
            catErr.text = "Category is required"
        } else if (catTitle.text!.count >= 1) {
            vwDropDown.layer.borderColor = UIColor.systemGray3.cgColor
            vwDropDown.layer.borderWidth = 1.0
            catErr.text = ""
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
}


