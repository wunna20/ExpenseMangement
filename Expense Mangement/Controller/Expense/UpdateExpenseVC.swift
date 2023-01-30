//
//  UpdateExpenseVC.swift
//  Expense Mangement
//
//  Created by Wunna on 12/15/22.
//

import UIKit
import CoreData
import DropDown

protocol Send{
    // index => call expense id
    func updateData(expense: ExpenseModel, index: Int, checkValue: String, check: Bool)
}

class UpdateExpenseVC: UIViewController, UITextFieldDelegate {

    var delegate: Send?

    @IBOutlet weak var titleTF: UITextField!
    @IBOutlet weak var amountTF: UITextField!
    @IBOutlet weak var vwDropDown: UIView!
    @IBOutlet weak var catTF: UILabel!
    
    @IBOutlet weak var mySwitch: UISwitch!
    @IBOutlet weak var expenseLabel: UILabel!
    @IBOutlet weak var incomeLabel: UILabel!
    @IBOutlet weak var dateTF: UITextField!
    @IBOutlet weak var datePicker: UIDatePicker!

    // validation
    
    @IBOutlet weak var titleErr: UILabel!
    @IBOutlet weak var amountErr: UILabel!
    @IBOutlet weak var typeErr: UILabel!
    @IBOutlet weak var dateErr: UILabel!
    @IBOutlet weak var catErr: UILabel!
    
    var expenseArr = [ExpenseModel]()
    var testArr = [ExpenseModel]()
    var items:[NSManagedObject] = []
    var filterIncItems: [NSManagedObject] = []
    var filterExpItems: [NSManagedObject] = []
    var filterMonthItems: [NSManagedObject] = []
    var filterSelectMonth: [NSManagedObject] = []
    var index:Int = 0
    var id : UUID = UUID()
    var title1 : String = ""
    var amount : String = ""
    var dateRes : String = ""
    var category : String = ""
    var type: String = ""
    var check: String = ""
    var select: Int = 0
    var selectMonth: Int = 0
    
    
    let catExpenseArr = CreateExpenseVC().catExpenseArr
    let catIncomeArr = CreateExpenseVC().catIncomeArr

    let dateFormatter = DateFormatter()
    let dropDown = DropDown()
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        datePicker.semanticContentAttribute = .forceRightToLeft
        datePicker.subviews.first?.semanticContentAttribute = .forceRightToLeft
        
        items = fetch()
        
        let item = items[self.index]
        print("outer item", item)
        
        filterIncItems = filterIncomeFetch()
        print("filter income", filterIncItems)
        
        filterExpItems = filterExpFetch()
        print("filter exp", filterExpItems)
        
        print("check month", selectMonth)
        fetchData.shared.selectMonth = selectMonth
//        filterSelectMonth = filterMonthItemFetch()
//        print("filter res", filterSelectMonth)
        
        
        titleTF.text = title1
        amountTF.text = amount
        catTF.text = category
        dateTF.text = dateRes
        
        print("item id", id)
        print("selectMonth", select)
        print("check", check)
        
        
        dropDown.anchorView = vwDropDown
        dropDown.dataSource = mySwitch.isOn == true ? catIncomeArr : catExpenseArr
        dropDown.bottomOffset = CGPoint(x: 0, y:(dropDown.anchorView?.plainView.bounds.height)!)
        dropDown.topOffset = CGPoint(x: 0, y:-(dropDown.anchorView?.plainView.bounds.height)!)
        dropDown.direction = .bottom
        
        dropDown.selectionAction = { [unowned self] (index: Int, item: String) in
            print("Selected item: \(item) at index: \(index)")
            catTF.text = mySwitch.isOn == true ? catIncomeArr[index] : catExpenseArr[index]
            
        }
        
        dateFormatter.dateFormat = "yyyy/MM/dd"
        dateTF.inputView = datePicker
        datePicker.datePickerMode = .date
        datePicker.date = dateFormatter.date(from: dateRes)!

        
        dateTF.isHidden = true
        if (type == "Income") {
            mySwitch.isOn = true
        } else {
            mySwitch.isOn = false
        }
        
        if (mySwitch.isOn == false) {
            dropDown.dataSource = catExpenseArr
        }
        
        hideKeyboardWhenTappedAround()
        
        
       
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
    
    // validataion
    
    @IBAction func titleChanged(_ sender: Any) {
//        titleTF.layer.borderColor = UIColor.systemGray3.cgColor
        titleTF.layer.borderWidth = 1.0
        titleErr.text = ""
    }
    
    
    @IBAction func amountChanged(_ sender: Any) {
//        amountTF.layer.borderColor = UIColor.systemGray3.cgColor
        amountTF.layer.borderWidth = 1.0
        amountErr.text = ""
    }
    
    // choose expense or income
    @IBAction func switchChange(_ sender: UISwitch) {
        if(mySwitch.isOn) {
            incomeLabel.text = "Income"
            dropDown.dataSource = catIncomeArr
        } else {
            expenseLabel.text = "Expense"
            dropDown.dataSource = catExpenseArr
        }
    }
    
    @IBAction func datePickerValueChanged(_ sender: UIDatePicker) {
        dateTF.text = dateFormatter.string(from: (sender as AnyObject).date)
        view.endEditing(true)
    }
    
    @IBAction func catTapped(_ sender: Any) {
        dropDown.show()
    }

    
    @IBAction func updateTapped(_ sender: Any) {
        
//              get current date
            let date = Date()
            dateFormatter.dateFormat = "MM/dd/yyyy"
            let currentDate = dateFormatter.string(from: date)
            
            guard let appDelegate =
                    UIApplication.shared.delegate as? AppDelegate else {
                return
            }
        let managedContext = appDelegate.persistentContainer.viewContext
        
            if (check == "income") {
                print("false")
                
                let item = filterIncItems[self.index]
//                let item = select == 0 ? filterIncItems[self.index] : 
                item.setValue(titleTF.text, forKeyPath: "title")
                item.setValue(Int((amountTF.text! as NSString).integerValue), forKeyPath: "amount")
                item.setValue(mySwitch.isOn ? false : true, forKey: "type")
                item.setValue(catTF.text, forKeyPath: "category")
                item.setValue(dateTF.text, forKeyPath: "date")
            } else if (check == "expense") {
                print("true")
                let item = filterExpItems[self.index]
                item.setValue(titleTF.text, forKeyPath: "title")
                item.setValue(Int((amountTF.text! as NSString).integerValue), forKeyPath: "amount")
                item.setValue(mySwitch.isOn ? false : true, forKey: "type")
                item.setValue(catTF.text, forKeyPath: "category")
                item.setValue(dateTF.text, forKeyPath: "date")
            } else {
                if (check == "all") {
                    let item = items[self.index]
                    print("update item", item)
                    item.setValue(titleTF.text, forKeyPath: "title")
                    item.setValue(Int((amountTF.text! as NSString).integerValue), forKeyPath: "amount")
                    item.setValue(mySwitch.isOn ? false : true, forKey: "type")
                    item.setValue(catTF.text, forKeyPath: "category")
                    item.setValue(dateTF.text, forKeyPath: "date")
                } else if (check == "income selectMonth") {
                    print("hello income", select)
                    var filterMonthItems:[NSManagedObject] = []
                    let appDelegate = UIApplication.shared.delegate as? AppDelegate
                    let managedContext = appDelegate!.persistentContainer.viewContext
                    print("outer select", select)
                    let predicate = NSPredicate(format: "date >= %@ AND date <= %@ AND type = %@", "2023/0\(select)/01", "2023/0\(select)/31", false as NSNumber)
                    let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Expenses")
                    fetchRequest.predicate = predicate

                    do {
                        filterMonthItems = try managedContext.fetch(fetchRequest)
                        print("hello fetch", filterMonthItems)
                        
                    } catch let error as NSError {
                        print("Could not fetch. \(error), \(error.userInfo)")
                    }
                
                print("updateFilter", filterMonthItems)
                let item = filterMonthItems[self.index]
                    print("update item", item)
                    item.setValue(titleTF.text, forKeyPath: "title")
                    item.setValue(Int((amountTF.text! as NSString).integerValue), forKeyPath: "amount")
                    item.setValue(mySwitch.isOn ? false : true, forKey: "type")
                    item.setValue(catTF.text, forKeyPath: "category")
                    item.setValue(dateTF.text, forKeyPath: "date")
                } else if (check == "expense selectMonth") {
                    print("hello expense")
                    var filterMonthItems:[NSManagedObject] = []
                    let appDelegate = UIApplication.shared.delegate as? AppDelegate
                    let managedContext = appDelegate!.persistentContainer.viewContext
                    let predicate = NSPredicate(format: "date >= %@ AND date <= %@ AND type = %@", "2023/0\(select)/01", "2023/0\(select)/31", true as NSNumber)
                    let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Expenses")
                    fetchRequest.predicate = predicate
                    do {
                        filterMonthItems = try managedContext.fetch(fetchRequest)
                        print("hello fetch", filterMonthItems)
                    } catch let error as NSError {
                        print("Could not fetch. \(error), \(error.userInfo)")
                    }
                    
                    let item = filterMonthItems[self.index]
                    print("update item", item)
                    item.setValue(titleTF.text, forKeyPath: "title")
                    item.setValue(Int((amountTF.text! as NSString).integerValue), forKeyPath: "amount")
                    item.setValue(mySwitch.isOn ? false : true, forKey: "type")
                    item.setValue(catTF.text, forKeyPath: "category")
                    item.setValue(dateTF.text, forKeyPath: "date")
                }
            }
            do {
                if (mySwitch.isOn == true && !catIncomeArr.contains(catTF.text!)) ||  (mySwitch.isOn == false && !catExpenseArr.contains(catTF.text!)) {
                    let alertController = UIAlertController(title: "Alert title", message: "Category name and type must be same", preferredStyle: .alert)
                    let cancelAction = UIAlertAction(title: "Please Try Again", style: .cancel) {
                        (action: UIAlertAction!) in print("Cancel button tapped");
                    }
                    alertController.addAction(cancelAction)
                    self.present(alertController, animated: true, completion: nil)
                } else {
                    try managedContext.save()
                    print("updated and saved")
                    
                    let generateId = UUID()
                    let result = ExpenseModel(id: id, title: titleTF.text, category: catTF.text, amount: Int((amountTF.text! as NSString).integerValue), date: dateTF.text, type: mySwitch.isOn ? false : true, createdAt: dateTF.text, updatedAt: dateTF.text)
                    print("Result", result)
                    
                    self.dismiss(animated: true, completion: { [self] in
                        self.delegate?.updateData(expense: result, index: self.index, checkValue: self.check, check: mySwitch.isOn ? false : true)
                    })
                }
            } catch let error as NSError {
                print("Could not save after updated. \(error), \(error.userInfo)")
            }
                
    }
    
    @IBAction func backTapped(_ sender: Any) {
        if let nav = self.navigationController {
            nav.popViewController(animated: true)
            } else {
                self.dismiss(animated: true, completion: nil)
            }
    }

}
@available(iOS 13.0, *)


// using update item
public func fetch ()->[NSManagedObject] {
    var items:[NSManagedObject] = []
    //1
    guard let appDelegate =
            UIApplication.shared.delegate as? AppDelegate else {
        return items
    }

    let managedContext =
        appDelegate.persistentContainer.viewContext

    //2
    let fetchRequest =
        NSFetchRequest<NSManagedObject>(entityName: "Expenses")

    //3
    do {
        items = try managedContext.fetch(fetchRequest)
    } catch let error as NSError {
        print("Could not fetch. \(error), \(error.userInfo)")
    }
    return items
}

@available(iOS 13.0, *)
public func filterIncomeFetch ()->[NSManagedObject] {
    var filterIncItems:[NSManagedObject] = []
    //1
    guard let appDelegate =
            UIApplication.shared.delegate as? AppDelegate else {
        return filterIncItems
    }

    let managedContext =
        appDelegate.persistentContainer.viewContext
    
    let predicate = NSPredicate(format: "type = %@", false as NSNumber)

    //2
    let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Expenses")
    fetchRequest.predicate = predicate

    //3
    do {
        filterIncItems = try managedContext.fetch(fetchRequest)
    } catch let error as NSError {
        print("Could not fetch. \(error), \(error.userInfo)")
    }
    return filterIncItems
}

@available(iOS 13.0, *)
public func filterExpFetch ()->[NSManagedObject] {
    var filterExpItems:[NSManagedObject] = []
    guard let appDelegate =
            UIApplication.shared.delegate as? AppDelegate else {
        return filterExpItems
    }

    let managedContext = appDelegate.persistentContainer.viewContext
    
    let predicate = NSPredicate(format: "type = %@", true as NSNumber)

    let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Expenses")
    fetchRequest.predicate = predicate

    do {
        filterExpItems = try managedContext.fetch(fetchRequest)
    } catch let error as NSError {
        print("Could not fetch. \(error), \(error.userInfo)")
    }
    return filterExpItems
}












