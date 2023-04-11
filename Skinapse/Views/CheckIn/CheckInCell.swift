//
//  CheckInCell.swift
//  Skinapse
//
//  Created by Jake Benton on 8/1/18.
//  Copyright © 2018 skinapse. All rights reserved.
//

import UIKit

class CheckInCell: UIView {
    weak var scrollView: UIScrollView?

    init() {
        super.init(frame: .zero)

        initialLayout()
    }

    @objc dynamic func initialLayout() {
        translatesAutoresizingMaskIntoConstraints = false
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class CheckInSpacerCell: CheckInCell {

    class Layout: MasterLayout {}

    override init() {
        super.init()

        backgroundColor = .clear

        heightAnchor.constraint(equalToConstant: Layout.minButtonSize).isActive = true
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

typealias CheckInChecklistCellInfo = (title: String, options: [String])

class CheckInChecklistCell: CheckInCell {

    class Layout: MasterLayout {
        static let titleFont: UIFont = .main(size: 12, weight: .bold)
    }

    private let info: CheckInChecklistCellInfo
    private let titleLabel = Layout.label(withColor: .black, font: Layout.titleFont)
    private lazy var rows: [CheckInChecklistCellRow] = {
        return info.options.enumerated().map { CheckInChecklistCellRow(text: $0.element, index: $0.offset) }
    }()

    init(info: CheckInChecklistCellInfo) {
        self.info = info
        super.init()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension CheckInChecklistCell {
    override func initialLayout() {
        super.initialLayout()

        backgroundColor = .white
        addSubview(titleLabel)

        titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: Layout.standardSpacing).isActive = true
        titleLabel.leftAnchor.constraint(equalTo: leftAnchor, constant: Layout.standardSpacing).isActive = true
        titleLabel.rightAnchor.constraint(equalTo: rightAnchor, constant: -Layout.standardSpacing).isActive = true

        titleLabel.text = info.title

        var previousAnchor = titleLabel.bottomAnchor
        rows.enumerated().forEach { index, row in
            addSubview(row)
            row.topAnchor.constraint(equalTo: previousAnchor, constant: index == 0 ? Layout.mediumSpacing : 0).isActive = true
            row.leftAnchor.constraint(equalTo: leftAnchor, constant: Layout.standardSpacing).isActive = true
            row.rightAnchor.constraint(equalTo: rightAnchor, constant: -Layout.standardSpacing).isActive = true
            row.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(checkTapped(gesture:))))
            previousAnchor = row.bottomAnchor
        }

        rows.last?.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -Layout.standardSpacing).isActive = true
    }

    @objc private func checkTapped(gesture: UITapGestureRecognizer) {
        guard let view = gesture.view as? CheckInChecklistCellRow else { return }

        rows[view.index].isChecked = !rows[view.index].isChecked
    }
}

class CheckInChecklistCellRow: UIView {

    class Layout: MasterLayout {
        static let font: UIFont = .main(size: 13)
        static let checkHeight: CGFloat = 24
        static let checkWidth: CGFloat = 25
        static let height: CGFloat = 36
        static let checkDuration: TimeInterval = 0.3
        static let uncheckDuration: TimeInterval = 0.2
        static let springDampening: CGFloat = 0.6
    }

    var isChecked = false {
        didSet { isChecked ? animateCheck() : animateUncheck() }
    }

    let index: Int
    private let text: String
    private let unchecked = Layout.imageView(withImage: #imageLiteral(resourceName: "check_unchecked"), renderingMode: .alwaysOriginal)
    private let checked = Layout.imageView(withImage: #imageLiteral(resourceName: "check_checked"), renderingMode: .alwaysOriginal)
    private let label = Layout.label(withColor: .black, font: Layout.font)

    private var views: [UIView] {
        return [unchecked, checked, label]
    }

    init(text: String, index: Int) {
        self.text = text
        self.index = index
        super.init(frame: .zero)
        initialLayout()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension CheckInChecklistCellRow {
    private func initialLayout() {
        translatesAutoresizingMaskIntoConstraints = false

        views.forEach {
            addSubview($0)
            $0.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        }

        unchecked.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        unchecked.heightAnchor.constraint(equalToConstant: Layout.checkHeight).isActive = true
        unchecked.widthAnchor.constraint(equalToConstant: Layout.checkWidth).isActive = true

        checked.centerXAnchor.constraint(equalTo: unchecked.centerXAnchor).isActive = true
        checked.centerYAnchor.constraint(equalTo: unchecked.centerYAnchor).isActive = true
        checked.heightAnchor.constraint(equalToConstant: Layout.checkHeight).isActive = true
        checked.widthAnchor.constraint(equalToConstant: Layout.checkWidth).isActive = true

        label.leftAnchor.constraint(equalTo: unchecked.rightAnchor, constant: Layout.mediumSpacing).isActive = true
        label.rightAnchor.constraint(equalTo: rightAnchor).isActive = true

        heightAnchor.constraint(equalToConstant: Layout.height).isActive = true

        checked.transform = Layout.scaleShrink
        label.text = text
    }

    private func animateCheck() {
        self.checked.alpha = 1
        UIView.animate(
            withDuration: Layout.checkDuration,
            delay: 0,
            usingSpringWithDamping: Layout.springDampening,
            initialSpringVelocity: 0,
            options: [],
            animations: { [weak self] in
                self?.checked.transform = Layout.scaleReset
            }
        )
    }

    private func animateUncheck() {
        UIView.animate(
            withDuration: Layout.uncheckDuration,
            animations: { [weak self] in
                self?.checked.transform = Layout.scaleShrink
            }
        ) { [weak self] _ in
            self?.checked.alpha = 0
        }
    }
}
