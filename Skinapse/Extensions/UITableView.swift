//
//  UITableView.swift
//  Skinapse
//
//  Created by Jake Benton on 7/31/18.
//  Copyright © 2018 skinapse. All rights reserved.
//

import UIKit

extension UITableView {
    func register(cellClass: UITableViewCell.Type) {
        register(cellClass, forCellReuseIdentifier: String(describing: cellClass))
    }

    func register(headerClass: UITableViewHeaderFooterView.Type) {
        register(headerClass, forHeaderFooterViewReuseIdentifier: String(describing: headerClass))
    }

    func dequeue<T: UITableViewCell>() -> T {
        return dequeueReusableCell(withIdentifier: String(describing: T.self)) as! T
    }

    func dequeue<T: UITableViewHeaderFooterView>() -> T {
        return dequeueReusableHeaderFooterView(withIdentifier: String(describing: T.self)) as! T
    }
}
