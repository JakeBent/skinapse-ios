//
//  CheckInSliderCell.swift
//  Skinapse
//
//  Created by Jake Benton on 8/1/18.
//  Copyright © 2018 skinapse. All rights reserved.
//

import UIKit

typealias CheckInSliderCellInfo = (title: String, descriptions: [String])

class CheckInSliderCell: CheckInCell, SliderDelegate {

    class Layout: MasterLayout {
        override class var transitionDuration: TimeInterval { return 0.2 }
    }

    private let descriptions: [String]
    private let titleLabel = Layout.label(withColor: .black, font: .main(size: 11, weight: .bold))
    private let slider = ThreePointSlider()
    private let descriptionLabel = Layout.label(withColor: .lightText, font: .main(size: 12))

    private var views: [UIView] {
        return [titleLabel, slider, descriptionLabel]
    }

    init(info: CheckInSliderCellInfo) {
        self.descriptions = info.descriptions
        super.init()

        backgroundColor = .white
        views.forEach { addSubview($0) }

        titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: Layout.standardSpacing).isActive = true
        titleLabel.leftAnchor.constraint(equalTo: leftAnchor, constant: Layout.standardSpacing).isActive = true
        titleLabel.rightAnchor.constraint(equalTo: rightAnchor, constant: -Layout.standardSpacing).isActive = true

        slider.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: Layout.smallSpacing).isActive = true
        slider.leftAnchor.constraint(equalTo: titleLabel.leftAnchor, constant: -10).isActive = true

        descriptionLabel.topAnchor.constraint(equalTo: slider.bottomAnchor, constant: Layout.smallSpacing).isActive = true
        descriptionLabel.leftAnchor.constraint(equalTo: leftAnchor, constant: Layout.standardSpacing).isActive = true
        descriptionLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -Layout.standardSpacing).isActive = true

        titleLabel.text = info.title
        slider.delegate = self
    }

    func valueChanged(to index: Int) {
        if index == -1 {
            UIView.animate(withDuration: Layout.transitionDuration) { [weak self] in
                self?.descriptionLabel.text = nil
                self?.scrollView?.layoutIfNeeded()
            }
        } else {
            if descriptionLabel.text == nil {
                UIView.animate(withDuration: Layout.transitionDuration) { [weak self] in
                    self?.descriptionLabel.text = self?.descriptions[index]
                    self?.scrollView?.layoutIfNeeded()
                }
            } else {
                descriptionLabel.text = descriptions[index]
            }
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

