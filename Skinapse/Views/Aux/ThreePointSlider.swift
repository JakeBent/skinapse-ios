//
//  ThreePointSlider.swift
//  Skinapse
//
//  Created by Jake Benton on 7/30/18.
//  Copyright © 2018 skinapse. All rights reserved.
//

import UIKit

protocol SliderDelegate: class {
    func valueChanged(to index: Int)
}

class ThreePointSlider: UIControl {

    class Layout: MasterLayout {
        static let stackSpacing: CGFloat = 10
    }

    weak var delegate: SliderDelegate?
    private static let width: CGFloat = 120
    private static let segmentWidth: CGFloat = width / 3

    var selectedIndex = -1 {
        didSet {
            first.tintColor = selectedIndex > -1 ? .black : .gray
            second.tintColor = selectedIndex > 0 ? .black : .gray
            third.tintColor = selectedIndex > 1 ? .black : .gray
            delegate?.valueChanged(to: selectedIndex)
        }
    }

    private let first = Layout.imageView(
        withImage: #imageLiteral(resourceName: "circle"),
        tint: .gray,
        contentMode: .center
    )
    private let second = Layout.imageView(
        withImage: #imageLiteral(resourceName: "circle"),
        tint: .gray,
        contentMode: .center
    )
    private let third = Layout.imageView(
        withImage: #imageLiteral(resourceName: "circle"),
        tint: .gray,
        contentMode: .center
    )
    private let stack = Layout.stack(
        withAxis: .horizontal,
        distribution: .fillEqually,
        alignment: .fill,
        spacing: Layout.stackSpacing
    )

    private var views: [UIView] {
        return [first, second, third]
    }

    init() {
        super.init(frame: .zero)

        initialLayout()
    }

    override func beginTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        updateValue(forTouch: touch)
        return true
    }

    override func continueTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        updateValue(forTouch: touch)
        return true
    }

    override func endTracking(_ touch: UITouch?, with event: UIEvent?) {
        guard let touch = touch else { return }
        updateValue(forTouch: touch)
    }


    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}

extension ThreePointSlider {
    func initialLayout() {
        translatesAutoresizingMaskIntoConstraints = false

        addSubview(stack)
        views.forEach {
            stack.addArrangedSubview($0)
            $0.isUserInteractionEnabled = false
        }

        stack.pinToEdges(of: self, padding: 10)

        stack.isUserInteractionEnabled = false
    }

    private func updateValue(forTouch touch: UITouch) {
        let location = touch.location(in: self)
        var index = Int(floor(location.x / ThreePointSlider.segmentWidth))
        if index < -1 { index = -1 }
        if index > 2 { index = 2 }
        selectedIndex = index
    }
}
