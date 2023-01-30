//
//  fetchData.swift
//  Expense Mangement
//
//  Created by Wunna on 1/25/23.
//

import UIKit
import CoreData

class fetchData: NSObject {
    static let shared = fetchData()
    var selectMonth: Int = 0
    var filterMonthArr = [ExpenseModel]()
  
    
//    public func filterMonthItemFetch ()->[NSManagedObject] {
//        print("selectMonthInfetchData",selectMonth)
//        var filterMonthItems:[NSManagedObject] = []
//        guard let appDelegate =
//                UIApplication.shared.delegate as? AppDelegate else {
//            return filterMonthItems
//        }
//
//        let managedContext = appDelegate.persistentContainer.viewContext
//        print("outer select", selectMonth)
//        let predicate = NSPredicate(format: "date >= %@ AND date <= %@", "2023/0\(selectMonth)/01", "2023/0\(selectMonth)/31")
//       
//
//        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Expenses")
//        fetchRequest.predicate = predicate
//
//        do {
//            filterMonthItems = try managedContext.fetch(fetchRequest)
//            print("hello fetch", filterMonthItems)
//            
//            for data in filterMonthItems {
//                let obj = ExpenseModel(
//                    id: (data.value(forKey: "id")) as? UUID,
//                    title: (data.value(forKey: "title") as! String),
//                    category: (data.value(forKey: "category") as! String),
//                    amount: (data.value(forKey: "amount") as? Int),
//                    date: (data.value(forKey: "date") as? String),
//                    type: (data.value(forKey: "type") as! Bool),
//                    createdAt: (data.value(forKey: "createdAt") as? String),
//                    updatedAt: (data.value(forKey: "updatedAt") as? String)
//                )
//                self.filterMonthArr.append(obj)
//            }
//            print("filterMonthArr", filterMonthArr)
//        } catch let error as NSError {
//            print("Could not fetch. \(error), \(error.userInfo)")
//        }
//        return filterMonthItems
//    }
    
    func filterIncomeFetch ()->[NSManagedObject] {
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
    
    func filterExpFetch ()->[NSManagedObject] {
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
    
    func filterMonthIncome ()->[NSManagedObject] {
        var filterMonthIncomeItem:[NSManagedObject] = []
        guard let appDelegate =
                UIApplication.shared.delegate as? AppDelegate else {
            return filterMonthIncomeItem
        }

        let managedContext = appDelegate.persistentContainer.viewContext
        let predicate = NSPredicate(format: "date >= %@ AND date <= %@ AND type = %@", "2023/0\(selectMonth)/01", "2023/0\(selectMonth)/31", false as NSNumber)
        print("inner select", selectMonth)

        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Expenses")
        fetchRequest.predicate = predicate

        do {
            filterMonthIncomeItem = try managedContext.fetch(fetchRequest)
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
        return filterMonthIncomeItem
    }
    
    func filterMothExpense ()->[NSManagedObject] {
        var filterMothExpenseItem:[NSManagedObject] = []
        guard let appDelegate =
                UIApplication.shared.delegate as? AppDelegate else {
            return filterMothExpenseItem
        }

        let managedContext = appDelegate.persistentContainer.viewContext
        let predicate = NSPredicate(format: "date >= %@ AND date <= %@ AND type = %@", "2023/0\(selectMonth)/01", "2023/0\(selectMonth)/31", true as NSNumber)
        print("outer select", selectMonth)

        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Expenses")
        fetchRequest.predicate = predicate

        do {
            filterMothExpenseItem = try managedContext.fetch(fetchRequest)
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
        return filterMothExpenseItem
    }
}
