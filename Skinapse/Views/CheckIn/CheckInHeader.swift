//
//  CheckInHeader.swift
//  Skinapse
//
//  Created by Jake Benton on 8/12/18.
//  Copyright © 2018 skinapse. All rights reserved.
//

import UIKit

class CheckInHeader: UIView {

    class Layout: MasterLayout {
        static let titleFont: UIFont = .main(size: 14, weight: .bold)
        static let arrowWidth: CGFloat = 10
        static let arrowHeight: CGFloat = 5
    }

    class Constants: MasterConstants {
        static let cancelText = "CANCEL"
        static let doneText = "DONE"
    }

    let cancelButton = Layout.textButton(withText: Constants.cancelText, color: .lightText)
    let doneButton = Layout.textButton(withText: Constants.doneText, color: .mainOrange)
    let titleView = Layout.view(withColor: .clear)
    private let titleLabel = Layout.label(
        withColor: .black,
        font: Layout.titleFont,
        text: "\(Date.string(from: Date()))"
    )
    private let calendarArrow = Layout.imageView(withImage: #imageLiteral(resourceName: "down_carat"), renderingMode: .alwaysOriginal)

    private var views: [UIView] {
        return [cancelButton, doneButton, titleView]
    }

    init() {
        super.init(frame: .zero)
        initialLayout()
    }

    func rotateArrowTo(angle: CGFloat) {
        calendarArrow.transform = CGAffineTransform(rotationAngle: angle)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension CheckInHeader {
    func initialLayout() {
        backgroundColor = .white
        translatesAutoresizingMaskIntoConstraints = false

        views.forEach {
            addSubview($0)
            $0.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        }
        titleView.addSubview(titleLabel)
        titleView.addSubview(calendarArrow)

        cancelButton.leftAnchor.constraint(equalTo: leftAnchor, constant: Layout.standardSpacing).isActive = true
        doneButton.rightAnchor.constraint(equalTo: rightAnchor, constant: -Layout.standardSpacing).isActive = true
        titleView.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        titleView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true

        calendarArrow.rightAnchor.constraint(equalTo: titleView.rightAnchor).isActive = true
        calendarArrow.centerYAnchor.constraint(equalTo: titleView.centerYAnchor).isActive = true
        calendarArrow.widthAnchor.constraint(equalToConstant: Layout.arrowWidth).isActive = true
        calendarArrow.heightAnchor.constraint(equalToConstant: Layout.arrowHeight).isActive = true

        titleLabel.leftAnchor.constraint(equalTo: titleView.leftAnchor).isActive = true
        titleLabel.topAnchor.constraint(equalTo: titleView.topAnchor).isActive = true
        titleLabel.bottomAnchor.constraint(equalTo: titleView.bottomAnchor).isActive = true
        titleLabel.rightAnchor.constraint(equalTo: calendarArrow.leftAnchor, constant: -Layout.smallSpacing).isActive = true
    }
}

