//
//  CheckIn.swift
//  Skinapse
//
//  Created by Jake Benton on 8/1/18.
//  Copyright © 2018 skinapse. All rights reserved.
//

import UIKit

struct CheckIn: Codable {
    let id: String
    let didSweat: Bool
    let didGetDirty: Bool
    let didShower: Bool
    let user: User
    let blemishes: [Blemish]
}
