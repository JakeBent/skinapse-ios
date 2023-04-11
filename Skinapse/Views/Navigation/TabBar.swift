//
//  TabBar.swift
//  Skinapse
//
//  Created by Jake Benton on 7/23/18.
//  Copyright © 2018 skinapse. All rights reserved.
//

import UIKit

protocol TabBarDelegate: AnyObject {
    func didChange(index: Int)
}

class TabBar: UIView {

    class Layout: MasterLayout {
        static let shadowColor: CGColor = UIColor(white: 150/255, alpha: 1).cgColor
        static let shadowRadius: CGFloat = 2
        static let shadowOpacity: Float = 0.2
        static let rightRotation = CGAffineTransform(rotationAngle: 3 * .pi / 2)
        static let leftRotation = CGAffineTransform(rotationAngle: .pi / 2)
        static let spacerHeight: CGFloat = 20
    }

    weak var delegate: TabBarDelegate?
    var selectedIndex: Int = 0 {
        didSet {
            views.enumerated().forEach {
                let (index, view) = $0
                view.isSelected = index == selectedIndex
            }
            delegate?.didChange(index: selectedIndex)
        }
    }

    private let stack = Layout.stack(
        withAxis: .horizontal,
        distribution: .fillEqually,
        alignment: .fill
    )
    private let first = TabBarIcon(image: #imageLiteral(resourceName: "tab_home"))
    private let second = TabBarIcon(image: #imageLiteral(resourceName: "tab_log"))
    private let third = TabBarIcon(image: #imageLiteral(resourceName: "tab_data"))
    private let fourth = TabBarIcon(image: #imageLiteral(resourceName: "tab_profile"))
    private let spacer = Layout.view(withColor: .white)
    private var spacerHeightConstraint: NSLayoutConstraint?
    private var views: [TabBarIcon] {
        return [first, second, third, fourth]
    }

    init() {
        super.init(frame: .zero)
        initialLayout()
    }

    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension TabBar {
    private func initialLayout() {
        backgroundColor = .white

        clipsToBounds = false
        layer.shadowColor = Layout.shadowColor
        layer.shadowRadius = Layout.shadowRadius
        layer.shadowOpacity = Layout.shadowOpacity

        addSubview(stack)

        if Layout.isIPhoneX {
            addSubview(spacer)
            spacer.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
            spacer.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
            spacer.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
            spacerHeightConstraint = spacer.heightAnchor.constraint(equalToConstant: Layout.spacerHeight)
            spacerHeightConstraint?.isActive = true

            stack.topAnchor.constraint(equalTo: topAnchor).isActive = true
            stack.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
            stack.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
            stack.bottomAnchor.constraint(equalTo: spacer.topAnchor).isActive = true
        } else {
            stack.pinToEdges(of: self)
        }

        views.forEach { view in
            stack.addArrangedSubview(view)
        }

        first.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(firstTapped)))
        second.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(secondTapped)))
        third.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(thirdTapped)))
        fourth.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(fourthTapped)))
    }

    func rotateToRightLandscape() {
        views.forEach { $0.transform = Layout.rightRotation }
        spacerHeightConstraint?.constant = 0
    }

    func rotateToLeftLandscape() {
        views.forEach { $0.transform = Layout.leftRotation }
        spacerHeightConstraint?.constant = 0
    }

    func rotateToPortrait() {
        views.forEach { $0.transform = Layout.rotationReset }
        spacerHeightConstraint?.constant = Layout.spacerHeight
    }

    @objc private func firstTapped() { set(index: 0) }
    @objc private func secondTapped() { set(index: 1) }
    @objc private func thirdTapped() { set(index: 2) }
    @objc private func fourthTapped() { set(index: 3) }

    @objc private func set(index: Int) {
        guard selectedIndex != index else { return }
        selectedIndex = index
    }
}
