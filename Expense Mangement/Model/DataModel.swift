//
//  DataModel.swift
//  Expense Mangement
//
//  Created by Wunna on 12/21/22.
//

import Foundation

struct Sale {
    var month: String
    var value: Double
}


class DataGenerator {
    static var randomizedSale: Double {
            return Double(arc4random_uniform(10000) + 1) / 10
        }
        
    
    static func data() -> Array<Any> {
        let months = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]
        var sales = [Sale]()

        for month in months {
            let sale = Sale(month: month, value: randomizedSale)
            sales.append(sale)
        }
        
        return sales
    }
}


