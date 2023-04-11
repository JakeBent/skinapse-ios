//
//  CheckInProductsCell.swift
//  Skinapse
//
//  Created by Jake Benton on 8/12/18.
//  Copyright © 2018 skinapse. All rights reserved.
//

import UIKit

class CheckInProductsCell: CheckInCell {

    class Constants: MasterConstants {
        static let saveText = "SAVE"
        static let addProductsText = "Add Products"
    }

    class Layout: MasterLayout {
        override class var transitionDuration: TimeInterval { return 0.25 }
        static let titleFont: UIFont = .main(size: 12, weight: .bold)
        static let addProductsFont: UIFont = .main(size: 13)
        static let plusButtonSize: CGFloat = 15
        static let headerHeight = CheckInView.Layout.headerHeight
    }

    let entryView = CheckInProductsEntryView()

    private let title: String
    private let headerView = Layout.view(withColor: .mainOrange)
    private let titleLabel = Layout.label(withColor: .white, font: Layout.titleFont)
    private let saveButton = Layout.textButton(withText: Constants.saveText, color: .white)
    private let centerView = Layout.view(withColor: .white)
    private let plusButton = Layout.imageView(withImage: #imageLiteral(resourceName: "plus"), tint: .mainOrange)
    private let addProductsLabel = Layout.label(
        withColor: .mainOrange,
        font: Layout.addProductsFont,
        text: Constants.addProductsText
    )
    private var plusBottomConstraint: NSLayoutConstraint!
    private var entryViewBottomConstraint: NSLayoutConstraint!
    private var firstTap: UITapGestureRecognizer!

    private var views: [UIView] {
        return [headerView, centerView]
    }

    init(title: String) {
        self.title = title
        super.init()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension CheckInProductsCell {
    override func initialLayout() {
        super.initialLayout()

        clipsToBounds = true
        isUserInteractionEnabled = true

        views.forEach { addSubview($0) }
        headerView.addSubview(titleLabel)
        headerView.addSubview(saveButton)
        centerView.addSubview(plusButton)
        centerView.addSubview(addProductsLabel)
        centerView.addSubview(entryView)

        headerView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        headerView.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        headerView.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        headerView.heightAnchor.constraint(equalToConstant: Layout.headerHeight * (2 / 3)).isActive = true

        titleLabel.leftAnchor.constraint(equalTo: headerView.leftAnchor, constant: Layout.standardSpacing).isActive = true
        titleLabel.centerYAnchor.constraint(equalTo: headerView.centerYAnchor).isActive = true

        saveButton.rightAnchor.constraint(equalTo: headerView.rightAnchor, constant: -Layout.standardSpacing).isActive = true
        saveButton.centerYAnchor.constraint(equalTo: headerView.centerYAnchor).isActive = true

        centerView.topAnchor.constraint(equalTo: headerView.bottomAnchor).isActive = true
        centerView.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        centerView.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        centerView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true

        entryView.topAnchor.constraint(equalTo: centerView.topAnchor).isActive = true
        entryView.leftAnchor.constraint(equalTo: centerView.leftAnchor).isActive = true
        entryView.rightAnchor.constraint(equalTo: centerView.rightAnchor).isActive = true
        entryViewBottomConstraint = entryView.bottomAnchor.constraint(equalTo: centerView.bottomAnchor)

        plusButton.topAnchor.constraint(equalTo: centerView.topAnchor, constant: Layout.standardSpacing).isActive = true
        plusButton.leftAnchor.constraint(equalTo: centerView.leftAnchor, constant: Layout.standardSpacing).isActive = true
        plusButton.heightAnchor.constraint(equalToConstant: Layout.plusButtonSize).isActive = true
        plusButton.widthAnchor.constraint(equalTo: plusButton.heightAnchor).isActive = true

        plusBottomConstraint = plusButton.bottomAnchor.constraint(equalTo: centerView.bottomAnchor, constant: -Layout.standardSpacing)
        plusBottomConstraint.isActive = true

        addProductsLabel.leftAnchor.constraint(equalTo: plusButton.rightAnchor, constant: Layout.smallSpacing).isActive = true
        addProductsLabel.centerYAnchor.constraint(equalTo: plusButton.centerYAnchor).isActive = true

        entryView.layout = { [weak self] in self?.scrollView?.layoutIfNeeded() }
        entryView.expand = { [weak self] in self?.reExpand() }
        titleLabel.text = title
        saveButton.alpha = 0

        firstTap = UITapGestureRecognizer(target: self, action: #selector(expand))
        addGestureRecognizer(firstTap)
        saveButton.addTarget(self, action: #selector(shrink), for: .touchUpInside)
    }

    @objc private func expand() {
        firstTap.isEnabled = false
        plusBottomConstraint.isActive = false
        entryViewBottomConstraint.isActive = true
        entryView.isHidden = false
        UIView.animate(withDuration: Layout.transitionDuration, animations: {
            self.scrollView?.layoutIfNeeded()
            self.plusButton.alpha = 0
            self.addProductsLabel.alpha = 0
            self.saveButton.alpha = 1
        }) { _ in
            self.entryView.assign()
        }
    }

    @objc private func shrink() {
        entryView.resign()
        entryView.resultsViewHeight = 0
        UIView.animate(withDuration: Layout.transitionDuration) { [weak self] in
            self?.saveButton.alpha = 0
            self?.scrollView?.layoutIfNeeded()
        }
    }

    private func reExpand() {
        entryView.resultsViewHeight = CheckInProductsEntryView.Layout.resultsHeight
        UIView.animate(withDuration: Layout.transitionDuration) { [weak self] in
            self?.scrollView?.layoutIfNeeded()
            self?.saveButton.alpha = 1
        }
    }
}
