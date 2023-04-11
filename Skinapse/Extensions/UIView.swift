//
//  UIView.swift
//  Skinapse
//
//  Created by Jake Benton on 7/23/18.
//  Copyright © 2018 skinapse. All rights reserved.
//

import UIKit

extension UIView {

    func pinToEdges(of superView: UIView, padding: CGFloat = 0) {
        topAnchor.constraint(equalTo: superView.topAnchor, constant: padding).isActive = true
        leftAnchor.constraint(equalTo: superView.leftAnchor, constant: padding).isActive = true
        bottomAnchor.constraint(equalTo: superView.bottomAnchor, constant: -padding).isActive = true
        rightAnchor.constraint(equalTo: superView.rightAnchor, constant: -padding).isActive = true
    }

    func pinToEdges(of superView: UIView, vPadding: CGFloat, hPadding: CGFloat) {
        topAnchor.constraint(equalTo: superView.topAnchor, constant: vPadding).isActive = true
        leftAnchor.constraint(equalTo: superView.leftAnchor, constant: hPadding).isActive = true
        bottomAnchor.constraint(equalTo: superView.bottomAnchor, constant: -vPadding).isActive = true
        rightAnchor.constraint(equalTo: superView.rightAnchor, constant: -hPadding).isActive = true
    }

    func addShadow(withColor color: UIColor = .black, opacity: Float = 0.3, radius: CGFloat = 3, offsetY: CGFloat = 0) {
        layer.shadowColor = color.cgColor
        layer.shadowOpacity = opacity
        layer.shadowRadius = radius
        layer.shadowOffset = CGSize(width: 0, height: offsetY)
    }
}
