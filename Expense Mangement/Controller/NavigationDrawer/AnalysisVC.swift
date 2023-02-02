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
import DropDown


@available(iOS 13.0, *)
@available(iOS 13.0, *)
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
    var catDataArr: [Any] = []
    var catIncomeDataArr: [Any] = []

    var dateArray: [String] = []
    var dateExpenseArr: [Int] = []
    let dropDown = DropDown()
    var selected: Int = 0
    var totalDuplicate: Int = 0
    var totalDate: [String] = []
    
    
    var dataItem:[Expenses]?
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
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
            
            calculateByCategory()
            customizeChart(dataPoints: catArr, values: catDataArr.map{ $0 as! Int64 })
            print("outer catData", catDataArr)
            
            calculateDateByExpense()
            customizeBarChart(dataPoints: monthsArr, values: dateExpenseArr.map{ Double(Int($0)) })
            
            
            calculateByIncomeCategory()
            customizeIncomeCatPieChart(dataPoints: catIncomeArr, values: catIncomeDataArr.map{ $0 as! Int64 })

        }
        fetchExpense()
        
        print("dataItem", dataItem as Any)
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
            self.barChartView.xAxis.avoidFirstLastClippingEnabled = true
          dataBarEntries.append(dataEntry)
        }
        print("bar date", totalDate)
//        self.barChartView.xAxis.valueFormatter = IndexAxisValueFormatter(values: ["hello", "ng[rt"])
        
        
        let chartDataSet = BarChartDataSet(entries: dataBarEntries, label: "Bar Chart View")
        let chartData = BarChartData(dataSet: chartDataSet)
        barChartView.data = chartData
        barChartView.xAxis.setLabelCount(5, force: true)
        barChartView.xAxis.avoidFirstLastClippingEnabled = false
        barChartView.xAxis.forceLabelsEnabled = true
    }
    
    func customizeChart(dataPoints: [String], values: [Int64]) {

        // 1. Set ChartDataEntry
        var dataEntries: [ChartDataEntry] = []


        for i in 0..<catArr.count {
            let dataEntry = PieChartDataEntry(value: Double(values[i]), label: catArr[i], data: catArr[i] as AnyObject)
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
    
    func customizeIncomeCatPieChart(dataPoints: [String], values: [Int64]) {

        // 1. Set ChartDataEntry
        var dataEntries: [ChartDataEntry] = []

        for i in 0..<catIncomeArr.count {
            let dataEntry = PieChartDataEntry(value: Double(values[i]), label: catIncomeArr[i], data:  catIncomeArr[i] as AnyObject)
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


    func fetchExpense() {
        do {
            let request = Expenses.fetchRequest() as NSFetchRequest<Expenses>
            let sort = NSSortDescriptor(key: #keyPath(Expenses.date), ascending: false)
            request.sortDescriptors = [sort]
            self.dataItem = try context.fetch(request)
            
        } catch {
            print("error")
        }
    }
    
    func calculateDateByExpense() {
        
        print("expense", expenseArr)
        let date = Date()
        let calendar = Calendar.current

    
        let exp = dataItem?.filter{$0.type == true}
    
        let testing = exp!.filter{$0.date ?? "Hello" >= "2023/0\(selected + 1)/01"}.filter{$0.date ?? "Hello" <= "2023/0\(selected + 1)/31"}
        print("inner testing", testing)
       
        let crossReference = Dictionary(grouping: testing, by: \.date)
        print("cross", crossReference)
        
        var tmp = [Int]()

        for (key, value) in crossReference {
            totalDuplicate = 0
            for i in 0..<value.count {
                totalDuplicate += Int(value[i].amount)
                totalDate.append(value[i].date!)
                print("totalDup", totalDuplicate)
                print("value date", value[i].date as Any)
                print("XXX", totalDate)
            }
            tmp.append(totalDuplicate)
        }
        dateExpenseArr = tmp
    }

    
    func calculateByCategory() {

      
        let exp = dataItem?.filter{$0.type == true}.filter{$0.date ?? "Hello" >= "2023/0\(selected + 1)/01"}.filter{$0.date ?? "Hello" <= "2023/0\(selected + 1)/31"}
    

        let foodPrice = exp?.filter{$0.category == "Food"}.map{$0.amount}.reduce(0, +)
        let utilPrice = exp?.filter{$0.category == "Utilities"}.map{$0.amount}.reduce(0, +)
        let insurancePrice = exp?.filter{$0.category == "Insurance"}.map{$0.amount}.reduce(0, +)
        let medArrPrice = exp?.filter{$0.category == "Medical & HealthCare"}.map{$0.amount}.reduce(0, +)
        let entArrPrice = exp?.filter{$0.category == "Entertainment"}.map{$0.amount}.reduce(0, +)
        let perArrPirce = exp?.filter{$0.category == "Personal Spending"}.map{$0.amount}.reduce(0, +)
        
        var tmp = [Any]()

        tmp.append(contentsOf: [foodPrice!, utilPrice!, insurancePrice!, medArrPrice!, entArrPrice!, perArrPirce!])
        catDataArr = tmp
        print("catDataArr", catDataArr)
    }
    
    func calculateByIncomeCategory() {
        
        let exp = dataItem?.filter{$0.type == false}.filter{$0.date ?? "Hello" >= "2023/0\(selected + 1)/01"}.filter{$0.date ?? "Hello" <= "2023/0\(selected + 1)/31"}
      
        
        let salPrice = exp?.filter{$0.category == "Salary"}.map{$0.amount}.reduce(0, +)
        let giftPrice = exp?.filter{$0.category == "Gift"}.map{$0.amount}.reduce(0, +)
        let bonusPrice = exp?.filter{$0.category == "Bonus"}.map{$0.amount}.reduce(0, +)
        let awardPrice = exp?.filter{$0.category == "Award"}.map{$0.amount}.reduce(0, +)
        
        var tmp = [Any]()
        
        tmp.append(contentsOf: [salPrice!, giftPrice!, bonusPrice!, awardPrice!])
        catIncomeDataArr = tmp
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




