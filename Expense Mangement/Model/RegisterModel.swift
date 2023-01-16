//
//  RegisterModel.swift
//  Expense Mangement
//
//  Created by Wunna on 12/12/22.
//

import Foundation

struct RegisterModel : Decodable {
    let name: String?
    let email: String?
    let password: String?
    let confirmPassword: String?
}
