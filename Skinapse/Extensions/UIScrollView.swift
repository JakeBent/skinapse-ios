//
//  UIScrollView.swift
//  Skinapse
//
//  Created by Jake Benton on 8/13/18.
//  Copyright © 2018 skinapse. All rights reserved.
//

import UIKit

extension UIScrollView {
    var isBouncingUp: Bool {
        return contentOffset.y < 0
    }

    var isBouncingDown: Bool {
        return contentOffset.y > contentSize.height - bounds.height + contentInset.top
    }

    func bounceDownAmount(extraOffset: CGFloat) -> CGFloat {
        let offset = contentOffset.y - (contentSize.height - bounds.height + contentInset.top) + extraOffset
        return offset >= 0 ? offset : 0
    }

    var isBouncing: Bool {
        return isBouncingUp || isBouncingDown
    }

    func layoutAs(checkInCells cells: [CheckInCell]) {
        var previousAnchor = topAnchor
        cells.enumerated().forEach { index, cell in
            cell.scrollView = self
            addSubview(cell)
            cell.topAnchor.constraint(equalTo: previousAnchor, constant: index > 0 ? MasterLayout.standardSpacing : 0).isActive = true
            cell.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
            cell.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
            cell.widthAnchor.constraint(equalTo: widthAnchor).isActive = true
            previousAnchor = cell.bottomAnchor
        }
        previousAnchor.constraint(equalTo: bottomAnchor).isActive = true
    }

    func layoutAs(brushes: [CameraToolStack]) {
        var previousAnchor = leftAnchor
        brushes.enumerated().forEach { index, cell in
            addSubview(cell)
            cell.leftAnchor.constraint(equalTo: previousAnchor).isActive = true
            cell.topAnchor.constraint(equalTo: topAnchor).isActive = true
            cell.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
            cell.heightAnchor.constraint(equalTo: heightAnchor).isActive = true
            previousAnchor = cell.rightAnchor
        }
        previousAnchor.constraint(equalTo: rightAnchor).isActive = true
    }
}
