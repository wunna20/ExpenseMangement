//
//  AnalysisVC.swift
//  Expense Mangement
//
//  Created by Wunna on 12/21/22.
//

import UIKit
import Charts
import TinyConstraints
import CoreData
import SwiftCharts
import DropDown


class AnalysisVC: UIViewController {
    
    var expenseArr = [ExpenseModel]()
    var monthsArr = [
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

    let catArr = CreateExpenseVC().catExpenseArr
    let catIncomeArr = CreateExpenseVC().catIncomeArr
    var catDataArr: [Int] = []
    var catIncomeDataArr: [Int] = []

    var dateArray: [String] = []
    var dateExpenseArr: [Int] = []
    let dropDown = DropDown()
    var selected: Int = 0
    
    @IBOutlet weak var vwDropDown: UIView!
    @IBOutlet weak var monthTitle: UILabel!
    @IBOutlet weak var pieChartView: PieChartView!
    @IBOutlet weak var barChartView: BarChartView!
    
    @IBOutlet weak var incomePieCartView: PieChartView!
    
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
            
            calculateDateByExpense()
            customizeBarChart(dataPoints: monthsArr, values: dateExpenseArr.map{ Double(Int($0)) })

        }
        readExpenseData()
        calculateByCategory()
        customizeChart(dataPoints: catArr, values: catDataArr.map{ Double(Int($0)) })
        
        calculateByIncomeCategory()
        customizeIncomeCatPieChart(dataPoints: catIncomeArr, values: catIncomeDataArr.map{ Double(Int($0)) })
        
    }
    
    
    @IBAction func backTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    @IBAction func monthTapped(_ sender: Any) {
        dropDown.show()
    }
    
    
    func customizeBarChart(dataPoints: [String], values: [Double]) {

        var dataBarEntries: [BarChartDataEntry] = []
        for i in 0..<dateExpenseArr.count {
          let dataEntry = BarChartDataEntry(x: Double(i), y: Double(values[i]))
          dataBarEntries.append(dataEntry)
        }
        let chartDataSet = BarChartDataSet(entries: dataBarEntries, label: "Bar Chart View")
        let chartData = BarChartData(dataSet: chartDataSet)
        barChartView.data = chartData

    }
    
    func customizeChart(dataPoints: [String], values: [Double]) {

        // 1. Set ChartDataEntry
        var dataEntries: [ChartDataEntry] = []


        for i in 0..<catArr.count {
            let dataEntry = PieChartDataEntry(value: values[i], label: catArr[i], data:  catArr[i] as AnyObject)
            dataEntries.append(dataEntry)
        }


        // 2. Set ChartDataSet
        let pieChartDataSet = PieChartDataSet(entries: dataEntries, label: "")
        pieChartDataSet.colors = colorsOfCharts(numbersOfColor: dataPoints.count)


        // 3. Set ChartData
        let pieChartData = PieChartData(dataSet: pieChartDataSet)
        let format = NumberFormatter()
        format.numberStyle = .none
        let formatter = DefaultValueFormatter(formatter: format)
        pieChartData.setValueFormatter(formatter)

        // 4. Assign it to the chart's data
        pieChartView.data = pieChartData
        pieChartView.drawEntryLabelsEnabled = false
      }

      private func colorsOfCharts(numbersOfColor: Int) -> [UIColor] {
        var colors: [UIColor] = []
        for _ in 0..<numbersOfColor {
          let red = Double(arc4random_uniform(256))
          let green = Double(arc4random_uniform(256))
          let blue = Double(arc4random_uniform(256))
          let color = UIColor(red: CGFloat(red/255), green: CGFloat(green/255), blue: CGFloat(blue/255), alpha: 1)
          colors.append(color)
        }
        return colors
      }
    
    func customizeIncomeCatPieChart(dataPoints: [String], values: [Double]) {

        // 1. Set ChartDataEntry
        var dataEntries: [ChartDataEntry] = []

        for i in 0..<catIncomeArr.count {
            let dataEntry = PieChartDataEntry(value: values[i], label: catIncomeArr[i], data:  catIncomeArr[i] as AnyObject)
            dataEntries.append(dataEntry)
        }
        

        // 2. Set ChartDataSet
        let pieChartDataSet = PieChartDataSet(entries: dataEntries, label: "")
        pieChartDataSet.colors = colorsOfCharts(numbersOfColor: dataPoints.count)


        // 3. Set ChartData
        let pieChartData = PieChartData(dataSet: pieChartDataSet)
        let format = NumberFormatter()
        format.numberStyle = .none
        let formatter = DefaultValueFormatter(formatter: format)
        pieChartData.setValueFormatter(formatter)

        // 4. Assign it to the chart's data
        incomePieCartView.data = pieChartData
        incomePieCartView.drawEntryLabelsEnabled = false
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

    
    
    func calculateDateByExpense() {
        
        print("expense", expenseArr)
        let date = Date()
        let calendar = Calendar.current

        var year = calendar.component(.year, from: date)
        var month = selected + 1
        var day = calendar.component(.day, from: date)
    
        let exp = expenseArr.filter{$0.type == true}
        print("exp", exp)
    
    
    
        let testing = exp.filter{$0.date! >= "2023/0\(selected + 1)/01"}.filter{$0.date! <= "2023/0\(selected + 1)/31"}
        print("testing", testing)
        
        let monthAmt = testing.map{Int($0.amount!)}
        let testing1 = monthAmt.reduce(0, +)
        print("monthAmt", monthAmt)
        dateExpenseArr = [testing1]

    }
    
    
    func calculateByCategory() {

        let exp = expenseArr.filter{$0.type == true}

        let foodPrice = exp.filter{$0.category == "Food"}.map{$0.amount!}.reduce(0, +)
        let utilPrice = exp.filter{$0.category == "Utilities"}.map{$0.amount!}.reduce(0, +)
        let insurancePrice = exp.filter{$0.category == "Insurance"}.map{$0.amount!}.reduce(0, +)
        let medArrPrice = exp.filter{$0.category == "Medical & HealthCare"}.map{$0.amount!}.reduce(0, +)
        let entArrPrice = exp.filter{$0.category == "Entertainment"}.map{$0.amount!}.reduce(0, +)
        let perArrPirce = exp.filter{$0.category == "Personal Spending"}.map{$0.amount!}.reduce(0, +)
    

        catDataArr += [foodPrice, utilPrice, insurancePrice, medArrPrice, entArrPrice, perArrPirce]
    }
    
    func calculateByIncomeCategory() {
        
        let exp = expenseArr.filter{$0.type == false}
        print("filter income", exp.count)
        
        let salPrice = exp.filter{$0.category == "Salary"}.map{$0.amount!}.reduce(0, +)
        let giftPrice = exp.filter{$0.category == "Gift"}.map{$0.amount!}.reduce(0, +)
        let bonusPrice = exp.filter{$0.category == "Bonus"}.map{$0.amount!}.reduce(0, +)
        let awardPrice = exp.filter{$0.category == "Award"}.map{$0.amount!}.reduce(0, +)
        
        catIncomeDataArr += [salPrice, giftPrice, bonusPrice, awardPrice]
        print("catIncomeDataArr", catIncomeDataArr)
        
    }


    func removeDuplicates(array: [String]) -> [String] {
        var encountered = Set<String>()
        var result: [String] = []
        for value in array {
            if encountered.contains(value) {
                // Do not add a duplicate element.
            }
            else {
                // Add value to the set.
                encountered.insert(value as! String)
                // ... Append the value.
                result.append(value)
            }
        }
        return result
    }

}




