//
//  SplashViewController.swift
//  Skinapse
//
//  Created by Jake Benton on 8/1/18.
//  Copyright © 2018 skinapse. All rights reserved.
//

import UIKit

class SplashViewController: UIViewController {

    class Layout: MasterLayout {
        static let logoWidth: CGFloat = 220
        static let logoHeight: CGFloat = 50
        static let animationDelay: TimeInterval = 0.5
    }

    var closeAction: (() -> Void)?
    private let logo = Layout.imageView(withImage: #imageLiteral(resourceName: "logo"), renderingMode: .alwaysOriginal)
    private var logoYConstraint: NSLayoutConstraint!
    private var logoXConstraint: NSLayoutConstraint!

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .backgroundGrey
        view.addSubview(logo)

        logo.heightAnchor.constraint(equalToConstant: Layout.logoHeight).isActive = true
        logo.widthAnchor.constraint(equalToConstant: Layout.logoWidth).isActive = true
        logoXConstraint = logo.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        logoXConstraint.isActive = true
        logoYConstraint = logo.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        logoYConstraint.isActive = true
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        switch UIApplication.shared.statusBarOrientation {
        case .landscapeLeft:
            logoXConstraint.constant = -Layout.screenWidth * 0.75
        case .landscapeRight:
            logoXConstraint.constant = Layout.screenWidth * 0.75
        default:
            logoYConstraint.constant = Layout.screenHeight * 0.75
        }

        UIView.animate(
            withDuration: Layout.transitionDuration,
            delay: Layout.animationDelay,
            options: [],
            animations: { [weak self] in
                self?.view.layoutIfNeeded()
            }
        ) { [weak self] _ in
            self?.closeAction?()
        }
    }
}
