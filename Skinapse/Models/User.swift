//
//  User.swift
//  Skinapse
//
//  Created by Jake Benton on 8/1/18.
//  Copyright © 2018 skinapse. All rights reserved.
//

import UIKit

struct User: Codable {
    let id: String
    let name: String
    let email: String
    let acneHistory: String
    let birthday: Date
}
