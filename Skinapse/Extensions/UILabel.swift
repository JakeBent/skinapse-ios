//
//  UILabel.swift
//  Skinapse
//
//  Created by Jake Benton on 7/27/18.
//  Copyright © 2018 skinapse. All rights reserved.
//

import UIKit

extension UILabel {
    func getHeight(forWidth: CGFloat? = nil) -> CGFloat {
        guard let text = text else { return 0 }
        let width = forWidth ?? self.bounds.width
        let maxSize = CGSize(width: width, height: 2000)
        let attrString = NSAttributedString(string: text, attributes: [.font: font])
        let rect = attrString.boundingRect(with: maxSize, options: .usesLineFragmentOrigin, context: nil)
        return rect.height
    }
}
