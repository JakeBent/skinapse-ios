//
//  ProductLogCell.swift
//  Skinapse
//
//  Created by Jake Benton on 7/30/18.
//  Copyright © 2018 skinapse. All rights reserved.
//

import UIKit

class ProductLogCell: LogCell {

    let stackView = Layout.stack(withAxis: .vertical, distribution: .fill, alignment: .leading)

    static let size: CGSize = CGSize(width: Layout.smallestSide, height: 100)

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        contentView.addSubview(stackView)
        stackView.leftAnchor.constraint(equalTo: titleLabel.rightAnchor, constant: Layout.standardSpacing).isActive = true
        stackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: Layout.mediumSpacing).isActive = true
        stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -Layout.mediumSpacing).isActive = true

        titleLabel.textColor = .mainOrange
    }

    func setup() {
        let labels = [
            Layout.label(withColor: .black, font: .main(size: 18), numberOfLines: 1, text: "Clinique Cleanser"),
            Layout.label(withColor: .black, font: .main(size: 18), numberOfLines: 1, text: "Nivea Toner"),
            Layout.label(withColor: .black, font: .main(size: 18), numberOfLines: 1, text: "Nivea Moisturizer"),
        ]
        titleLabel.text = "MORNING"
        stackView.set(subviews: labels)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class SliderLogCell: LogCell {

    static let size: CGSize = CGSize(width: Layout.smallestSide, height: 58)

    private let slider = ThreePointSlider()

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        contentView.addSubview(slider)
        slider.leftAnchor.constraint(equalTo: titleLabel.rightAnchor, constant: Layout.standardSpacing - 10).isActive = true
        slider.topAnchor.constraint(equalTo: contentView.topAnchor, constant: Layout.smallSpacing).isActive = true
        slider.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -Layout.smallSpacing).isActive = true

        titleTopConstraint.constant = 16
    }

    func setup() {
        titleLabel.text = "SLEEP"
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
