//
//  UIColor.swift
//  Skinapse
//
//  Created by Jake Benton on 7/23/18.
//  Copyright © 2018 skinapse. All rights reserved.
//

import UIKit

extension UIColor {

    static var mainOrange = UIColor(red: 245/255, green: 117/255, blue: 95/255, alpha: 1)
    static var backgroundGrey = UIColor(red: 251/255, green: 249/255, blue: 250/255, alpha: 1)
    static var selectedGrey = UIColor(red: 231/255, green: 229/255, blue: 230/255, alpha: 1)
    static var lightText = UIColor(red: 195/255, green: 195/255, blue: 202/255, alpha: 1)

    static var indigo = UIColor(red: 109/255, green: 111/255, blue: 225/255, alpha: 1)
    static var lilac = UIColor(red: 225/255, green: 208/255, blue: 237/255, alpha: 1)
    static var yellow = UIColor(red: 248/255, green: 218/255, blue: 104/255, alpha: 1)
    static var peach = UIColor(red: 249/255, green: 206/255, blue: 200/255, alpha: 1)
    static var aquamarine = UIColor(red: 0/255, green: 159/255, blue: 146/255, alpha: 1)
    static var seafoam = UIColor(red: 175/255, green: 236/255, blue: 208/255, alpha: 1)

    static func indigo(alpha: CGFloat) -> UIColor {
        return UIColor(red: 109/255, green: 111/255, blue: 225/255, alpha: alpha)
    }
    static func lilac(alpha: CGFloat) -> UIColor {
        return UIColor(red: 225/255, green: 208/255, blue: 237/255, alpha: alpha)
    }
    static func yellow(alpha: CGFloat) -> UIColor {
        return UIColor(red: 248/255, green: 218/255, blue: 104/255, alpha: alpha)
    }
    static func peach(alpha: CGFloat) -> UIColor {
        return UIColor(red: 249/255, green: 206/255, blue: 200/255, alpha: alpha)
    }
    static func aquamarine(alpha: CGFloat) -> UIColor {
        return UIColor(red: 0/255, green: 159/255, blue: 146/255, alpha: alpha)
    }
    static func seafoam(alpha: CGFloat) -> UIColor {
        return UIColor(red: 175/255, green: 236/255, blue: 208/255, alpha: alpha)
    }
}
