//
//  UIStackView.swift
//  Skinapse
//
//  Created by Jake Benton on 7/25/18.
//  Copyright © 2018 skinapse. All rights reserved.
//

import UIKit

extension UIStackView {
    func set(subviews: [UIView]) {
        let removedSubviews = arrangedSubviews.reduce([]) { (allSubviews, subview) -> [UIView] in
            removeArrangedSubview(subview)
            return allSubviews + [subview]
        }

        NSLayoutConstraint.deactivate(removedSubviews.flatMap({ $0.constraints }))
        removedSubviews.forEach({ $0.removeFromSuperview() })

        subviews.forEach { $0.sizeToFit(); addArrangedSubview($0) }
    }
}
