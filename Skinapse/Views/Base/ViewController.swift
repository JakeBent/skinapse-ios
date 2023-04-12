//
//  ViewController.swift
//  Skinapse
//
//  Created by Jake Benton on 7/25/18.
//  Copyright © 2018 skinapse. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    var navController: MainNavigationController? {
        return navigationController as? MainNavigationController
    }
    let contentView = MasterLayout.view(withColor: .backgroundGrey)
    var contentViewLeftConstraint: NSLayoutConstraint!
    var contentViewRightConstraint: NSLayoutConstraint!
    var contentViewBottomConstraint: NSLayoutConstraint!
    var contentViewTopConstraint: NSLayoutConstraint!

    init() {
        super.init(nibName: nil, bundle: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        initialLayout()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        reset()

        switch UIApplication.shared.statusBarOrientation {
        case .landscapeLeft:
            moveLeft()
        case .landscapeRight:
            moveRight()
        default:
            moveDown()
        }

        UIView.animate(withDuration: MasterLayout.transitionDuration) { [weak self] in
            self?.reset()
        }
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)

        coordinator.animate(alongsideTransition: { [weak self] _ in
            self?.layout(for: size)
            self?.view.layoutIfNeeded()
        })
    }

    @objc dynamic func initialLayout() {
        view.backgroundColor = .backgroundGrey
        view.addSubview(contentView)

        contentViewLeftConstraint = contentView.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor)
        contentViewRightConstraint = contentView.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor)
        contentViewBottomConstraint = contentView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        contentViewTopConstraint = contentView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor)

        [
            contentViewLeftConstraint,
            contentViewRightConstraint,
            contentViewBottomConstraint,
            contentViewTopConstraint,
        ].forEach { $0.isActive = true }
    }

    func layout(for size: CGSize, startOrientation: UIInterfaceOrientation? = nil) {
        switch UIApplication.shared.statusBarOrientation {
        case .landscapeLeft:
            contentViewLeftConstraint.constant = 24
            contentViewRightConstraint.constant = 0
            contentViewBottomConstraint.constant = 0
        case .landscapeRight:
            contentViewLeftConstraint.constant = 0
            contentViewRightConstraint.constant = -24
            contentViewBottomConstraint.constant = 0
        default:
            contentViewLeftConstraint.constant = 0
            contentViewRightConstraint.constant = 0
            contentViewBottomConstraint.constant = -MasterLayout.tabBarSize
        }

        contentViewTopConstraint.constant = 0
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension ViewController {
    func reset() {
        layout(for: MasterLayout.screenSize)
        view.layoutIfNeeded()
    }

    func moveLeft() {
        contentViewLeftConstraint.constant = -MasterLayout.screenWidth + 24
        contentViewRightConstraint.constant = -MasterLayout.screenWidth
        view.layoutIfNeeded()
    }

    func moveRight() {
        contentViewLeftConstraint.constant = MasterLayout.screenWidth
        contentViewRightConstraint.constant = MasterLayout.screenWidth - 24
        view.layoutIfNeeded()
    }

    func moveDown() {
        contentViewTopConstraint.constant = MasterLayout.screenHeight
        contentViewBottomConstraint.constant = MasterLayout.screenHeight - MasterLayout.tabBarSize
        view.layoutIfNeeded()
    }
}
