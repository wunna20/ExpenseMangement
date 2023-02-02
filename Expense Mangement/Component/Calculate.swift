//
//  Calculate.swift
//  Expense Mangement
//
//  Created by Wunna on 2/2/23.
//

import Foundation

class CalculateAmt {
    static func calculateTax(percentageVal:Double, incomeAmount:Double)->Double {
        let per = percentageVal / 100.0
        let taxRate = incomeAmount * per
        let finalRes = incomeAmount - taxRate
        print("inner final Res", finalRes)
        return finalRes
    }
    
    static func calculateTaxRate (percentageVal:Double, incomeAmount:Double)->Double {
        let per = percentageVal / 100.0
        let taxRate = incomeAmount * per
        return taxRate
    }
}
