//
//  UIFont.swift
//  Skinapse
//
//  Created by Jake Benton on 7/23/18.
//  Copyright © 2018 skinapse. All rights reserved.
//

import UIKit

enum FontWeight {
    case normal, medium, bold
}

extension UIFont {
    static func main(size: CGFloat, weight: FontWeight = .normal) -> UIFont {
        switch weight {
        case .normal:
            return UIFont(name: "Avenir-Book", size: size)!
        case .medium:
            return UIFont(name: "Avenir-Medium", size: size)!
        case .bold:
            return UIFont(name: "Avenir-Black", size: size)!
        }
    }
}

extension Date {
    static let formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM d"
        return formatter
    }()

    static func string(from date: Date) -> String {
        return formatter.string(from: date)
    }
}
