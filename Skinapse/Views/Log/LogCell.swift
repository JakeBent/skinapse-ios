//
//  LogCell.swift
//  Skinapse
//
//  Created by Jake Benton on 7/30/18.
//  Copyright © 2018 skinapse. All rights reserved.
//

import UIKit

class LogCell: UITableViewCell {

    class Layout: MasterLayout {
        static let titleFont: UIFont = .main(size: 11, weight: .bold)
        static let titleWidth: CGFloat = smallestSide / 5
    }

    let titleLabel = Layout.label(
        withColor: .black,
        font: Layout.titleFont,
        alignment: .right
    )
    var titleTopConstraint: NSLayoutConstraint!

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        contentView.backgroundColor = .white
        contentView.addSubview(titleLabel)

        titleTopConstraint = titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: Layout.standardSpacing)
        titleTopConstraint.isActive = true
        titleLabel.widthAnchor.constraint(equalToConstant: Layout.titleWidth).isActive = true
        titleLabel.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: Layout.standardSpacing).isActive = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {

    }

    override func setHighlighted(_ highlighted: Bool, animated: Bool) {

    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
