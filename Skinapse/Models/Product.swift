//
//  Product.swift
//  Skinapse
//
//  Created by Jake Benton on 8/1/18.
//  Copyright © 2018 skinapse. All rights reserved.
//

import UIKit

struct Product: Codable {
    let id: String
    let type: String
    let brand: String
    let activeIngredients: [String]
}
