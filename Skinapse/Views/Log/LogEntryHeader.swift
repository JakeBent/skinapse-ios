//
//  LogEntryHeader.swift
//  Skinapse
//
//  Created by Jake Benton on 7/27/18.
//  Copyright © 2018 skinapse. All rights reserved.
//

import UIKit

class LogEntryHeader: UITableViewHeaderFooterView {

    class Layout: MasterLayout {
        static let titleFont: UIFont = .main(size: 18)
    }

    let titleLabel = Layout.label(withColor: .gray, font: Layout.titleFont)

    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)

        backgroundView = Layout.view(withColor: .backgroundGrey)
        addSubview(titleLabel)
        titleLabel.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        titleLabel.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
    }

    func setup(text: String) {
        titleLabel.text = text
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
