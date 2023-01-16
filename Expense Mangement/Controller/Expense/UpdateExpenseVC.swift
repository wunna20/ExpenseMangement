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
    func updateData(expense: ExpenseModel, index: Int)
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
    var items:[NSManagedObject] = []
    var index:Int = 0
    var title1 : String = ""
    var amount : String = ""
    var dateRes : String = ""
    var category : String = ""
    var type: String = ""
    
    
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
        
        titleTF.text = title1
        amountTF.text = amount
        catTF.text = category
        dateTF.text = dateRes
        
        
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
        titleTF.layer.borderColor = UIColor.systemGray3.cgColor
        titleTF.layer.borderWidth = 1.0
        titleErr.text = ""
    }
    
    
    @IBAction func amountChanged(_ sender: Any) {
        amountTF.layer.borderColor = UIColor.systemGray3.cgColor
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
            let item = items[self.index]
            print("update item", item)
            item.setValue(titleTF.text, forKeyPath: "title")
            item.setValue(Int((amountTF.text! as NSString).integerValue), forKeyPath: "amount")
            item.setValue(mySwitch.isOn ? false : true, forKey: "type")
            item.setValue(catTF.text, forKeyPath: "category")
            item.setValue(dateTF.text, forKeyPath: "date")
            do {
                try managedContext.save()
                print("updated and saved")
                
                let result = ExpenseModel(title: titleTF.text, category: catTF.text, amount: Int((amountTF.text! as NSString).integerValue), date: dateTF.text, type: mySwitch.isOn ? false : true, createdAt: dateTF.text, updatedAt: dateTF.text)
                print("Result", result)
                
                self.dismiss(animated: true, completion: {
                    self.delegate?.updateData(expense: result, index: self.index)
                })
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





