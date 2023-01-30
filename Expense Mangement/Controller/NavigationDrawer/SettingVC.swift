//
//  SettingVC.swift
//  Expense Mangement
//
//  Created by Wunna on 12/27/22.
//

import UIKit
import CoreData
import UniformTypeIdentifiers
import MobileCoreServices

protocol sendCSVData{
    func csvData(expense: ExpenseModel)
}

@available(iOS 14.0, *)
@available(iOS 13.0, *)
@available(iOS 14.0, *)
class SettingVC: UIViewController, UIDocumentPickerDelegate {
    
    var delegate: sendCSVData?
    
    var expenseArr = [ExpenseModel]()
    var uploadFileURL = ""
    var fileURL : URL? = URL(string: "www.apple.com")
    var uploadFileName = ""
    var myURL: URL = URL(string: "www.google.com")!
    var res: String = ""
    
    @IBOutlet weak var urlTF: UITextField!
    @IBOutlet weak var errorLabel: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        readExpenseData()
        
    }
    
    
    @IBAction func backBtnTapped(_ sender: Any) {
        if let nav = self.navigationController {
            nav.popViewController(animated: true)
        } else {
            self.dismiss(animated: true, completion: nil)
        }
    }
        
    @IBAction func textFieldDidChanged(_ sender: Any) {
        urlTF.layer.borderColor = UIColor.systemGray3.cgColor
        urlTF.layer.borderWidth = 1.0
        errorLabel.text = ""
    }
    
    @IBAction func selectFileTapped(_ sender: Any) {
        let supportedFiles : [UTType] = [UTType.data]
        let controller = UIDocumentPickerViewController(forOpeningContentTypes: supportedFiles, asCopy: true)
        controller.delegate = self
        controller.allowsMultipleSelection = false

        present(controller, animated: true, completion: nil)

    }

    
    
    public func documentMenu(_ documentMenu:UIDocumentPickerViewController, didPickDocumentPicker documentPicker: UIDocumentPickerViewController) {
        documentPicker.delegate = self
        present(documentPicker, animated: true, completion: nil)
    }
    
    
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        guard let myURL = urls.first else {
           return
        }
        print("myUrl", myURL)
        self.urlTF.text = myURL.lastPathComponent
        self.uploadFileURL = String("\(myURL)")
        self.fileURL = myURL
        self.uploadFileName = "attachFile.\(myURL.pathExtension)"
        //        self.uploadFileMimeType = mimeType(for: self.uploadFileURL)

        let rows = NSArray(contentsOfCSVURL: urls.first, options: CHCSVParserOptions.sanitizesFields)!
        res = rows.csvString()
        print("outer res", res)

   }
    
    
    
    @IBAction func importTapped(_ sender: Any) {
        if (urlTF.text?.isEmpty == true) {
            if ((urlTF.text?.isEmpty) != nil) {
                urlTF.layer.borderColor = UIColor.red.cgColor
                urlTF.layer.borderWidth = 1.0
                errorLabel.text = "Import file is required"
            } else if (urlTF.text!.count >= 1) {
                textFieldDidChanged(urlTF as Any)
            }
        } else {
            print("hello")
            print("inner res", res)
            var arr = res.split(separator: "\n")
            print("arr", arr)
            arr.remove(at: 0)

            for item in arr {
                print("item", item)

                var stringToArr = item.split(separator: ",")
                print("StringToArr", stringToArr)

                guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {return}
                let managedContext = appDelegate.persistentContainer.viewContext
                guard let personEntity = NSEntityDescription.entity(forEntityName: "Expenses", in: managedContext) else { return }
                let expense = NSManagedObject(entity: personEntity, insertInto: managedContext)

                expense.setValue(stringToArr[0], forKey: "title")
                expense.setValue(stringToArr[1], forKey: "category")
                expense.setValue(Int(stringToArr[2]), forKey: "amount")
                expense.setValue(Int(stringToArr[3]) == 1 ? true : false, forKey: "type")
                expense.setValue(stringToArr[4], forKey: "date")
                expense.setValue(stringToArr[5], forKey: "createdAt")
                expense.setValue(stringToArr[6], forKey: "updatedAt")

                do {
                    try managedContext.save()
                    debugPrint("Data Saved")
                    let generateId = UUID()
                    
                    let createResultCsv = ExpenseModel(id: generateId, title:String(stringToArr[0]), category: String(stringToArr[1]), amount: Int(String(stringToArr[2])), date: String(stringToArr[4]), type: Int(String(stringToArr[3])) == 1 ? true : false, createdAt: String(stringToArr[5]), updatedAt: String(stringToArr[6]))
                    print("Result", createResultCsv)

                    self.dismiss(animated: true, completion: {
                        self.delegate?.csvData(expense: createResultCsv)
                    })
                } catch let error as NSError {
                    debugPrint("error", error)
                }
            }
            //        Toast Message
            CustomToast.show(message: "Successfully import", bgColor: .black, textColor: .white, labelFont: .boldSystemFont(ofSize: 14), showIn: .top, controller: self)

            let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "home")
            vc.modalPresentationStyle = .overFullScreen
            present(vc, animated: true)
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
            print("Saved values")
            for data in result {
                print("AMOUNT", data.value(forKey: "amount") as? Int ?? "")

                let obj = ExpenseModel(
                    id: (data.value(forKey: "id") as? UUID),
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


