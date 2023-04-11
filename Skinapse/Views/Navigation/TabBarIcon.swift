//
//  TabBarIcon.swift
//  Skinapse
//
//  Created by Jake Benton on 7/23/18.
//  Copyright © 2018 skinapse. All rights reserved.
//

import UIKit

class TabBarIcon: UIView {

    class Layout: MasterLayout {
        static let selectedColor: UIColor = .black
        static let unselectedColor: UIColor = .lightGray
    }

    var isSelected = false {
        didSet {
            imageView.tintColor = isSelected ? Layout.selectedColor : Layout.unselectedColor
        }
    }

    private let imageView = Layout.imageView(withImage: nil, tint: .lightGray)

    init(image: UIImage) {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        isUserInteractionEnabled = true

        imageView.image = image.withRenderingMode(.alwaysTemplate)

        addSubview(imageView)
        imageView.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        imageView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

