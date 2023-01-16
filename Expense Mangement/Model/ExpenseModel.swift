//
//  ExpenseModel.swift
//  Expense Mangement
//
//  Created by Wunna on 12/13/22.
//

import Foundation

struct ExpenseModel : Decodable {

    let title: String?
    let category: String?
    let amount: Int?
    let date: String?
    let type: Bool?
    let createdAt: String?
    let updatedAt: String?
}

var expense : [ExpenseModel] = []


