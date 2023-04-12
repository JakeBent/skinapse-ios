//
//  HomeViewController.swift
//  Skinapse
//
//  Created by Jake Benton on 7/23/18.
//  Copyright © 2018 skinapse. All rights reserved.
//

import UIKit

class HomeViewController: ViewController {

    class Layout: MasterLayout {

    }

    class Constants: MasterConstants {
        static let checkIns = [
            [ "date": "June 29th" ],
            [ "date": "July 5th" ],
            [ "date": "July 8th" ],
            [ "date": "July 12th" ],
            [ "date": "July 23rd" ],
            [ "date": "July 28th" ],
            [ "date": "August 1st" ],
            [ "date": "August 2nd" ],
            [ "date": "August 5th" ],
        ]
    }
    
    let viewModel: HomeViewViewModel?
    let titleLabel = Layout.label(
        withColor: .mainOrange,
        font: .main(size: 36, weight: .bold),
        text: "Good morning,"
    )
    let nameLabel = Layout.label(withColor: .mainOrange, font: .main(size: 36))
    let trackView = TrackView()
    var trackCenterXConstraint: NSLayoutConstraint!
    var trackCenterYConstraint: NSLayoutConstraint!
    var trackTopConstraint: NSLayoutConstraint!
    var trackRightConstraint: NSLayoutConstraint!
    let checkInContainer = Layout.stack(
        withAxis: .vertical,
        distribution: .fillProportionally,
        alignment: .center,
        spacing: Layout.shrinkingSpacing
    )
    var checkInBottomConstraint: NSLayoutConstraint!
    var checkInCenterXConstraint: NSLayoutConstraint!
    var checkInLeftConstraint: NSLayoutConstraint!
    let dateLabel = Layout.label(withColor: .black, font: .main(size: 18, weight: .bold), text: "Date")
    let streakLabel = Layout.label(withColor: .black, font: .main(size: 18), text: "Date")
    let spacer = Layout.view(withColor: .backgroundGrey)
    let checkInButton = Layout.imageButton(withImage: #imageLiteral(resourceName: "check_in"))
    var views: [UIView] {
        return [titleLabel, nameLabel, trackView, checkInContainer]
    }
    var checkInViews: [UIView] {
        return [dateLabel, streakLabel, spacer, checkInButton]
    }
    
    override init() {
        viewModel = HomeViewViewModel()
        super.init()
        
        viewModel?.viewController = self
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        viewModel?.fetchData()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        layout(for: Layout.screenSize)
        setup()
    }

//    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
//        super.viewWillTransition(to: size, with: coordinator)
//
//        coordinator.animate(alongsideTransition: { [weak self] _ in
//            self?.layout(for: size)
//            self?.view.layoutIfNeeded()
//        })
//    }

    @objc private func checkInTapped() {
        navController?.startCheckIn()
    }

    override func layout(for size: CGSize, startOrientation: UIInterfaceOrientation? = nil) {

        super.layout(for: size, startOrientation: startOrientation)

        switch UIApplication.shared.statusBarOrientation {
        case .landscapeRight:
            trackTopConstraint.isActive = false
            trackCenterXConstraint.isActive = false
            trackCenterYConstraint.isActive = true
            trackRightConstraint.isActive = true
            checkInCenterXConstraint.isActive = false
            checkInLeftConstraint.isActive = true
            checkInContainer.alignment = .leading
        case .landscapeLeft:
            trackTopConstraint.isActive = false
            trackCenterXConstraint.isActive = false
            trackCenterYConstraint.isActive = true
            trackRightConstraint.isActive = true
            checkInCenterXConstraint.isActive = false
            checkInLeftConstraint.isActive = true
            checkInContainer.alignment = .leading
        default:
            trackTopConstraint.isActive = true
            trackCenterXConstraint.isActive = true
            trackCenterYConstraint.isActive = false
            trackRightConstraint.isActive = false
            checkInCenterXConstraint.isActive = true
            checkInLeftConstraint.isActive = false
            checkInContainer.alignment = .center
        }
    }

    private func setup(user: User? = nil) {
        nameLabel.text = user?.username
        dateLabel.text = ""
        streakLabel.text = "17 day streak"
        trackView.checkIns = Constants.checkIns
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension HomeViewController {
    override func initialLayout() {
        super.initialLayout()

        contentView.backgroundColor = .backgroundGrey

        views.forEach { contentView.addSubview($0) }
        checkInContainer.set(subviews: checkInViews)

        titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: Layout.standardSpacing).isActive = true
        titleLabel.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -Layout.standardSpacing).isActive = true
        titleLabel.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: Layout.standardSpacing).isActive = true

        nameLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: Layout.smallSpacing).isActive = true
        nameLabel.leftAnchor.constraint(equalTo: titleLabel.leftAnchor).isActive = true
        nameLabel.rightAnchor.constraint(equalTo: titleLabel.rightAnchor).isActive = true

        trackView.widthAnchor.constraint(equalToConstant: Layout.trackSize).isActive = true
        trackView.heightAnchor.constraint(equalTo: trackView.widthAnchor).isActive = true
        trackTopConstraint = trackView.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: Layout.standardSpacing)
        trackTopConstraint.isActive = true
        trackCenterXConstraint = trackView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor)
        trackCenterXConstraint.isActive = true
        trackCenterYConstraint = trackView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        trackRightConstraint = trackView.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -Layout.standardSpacing)

        checkInContainer.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -Layout.standardSpacing).isActive = true
        checkInCenterXConstraint = checkInContainer.centerXAnchor.constraint(equalTo: contentView.centerXAnchor)
        checkInCenterXConstraint.isActive = true
        checkInLeftConstraint = checkInContainer.leftAnchor.constraint(equalTo: nameLabel.leftAnchor)

        spacer.heightAnchor.constraint(equalToConstant: Layout.smallShrinkingSpacing).isActive = true

        checkInButton.addTarget(self, action: #selector(checkInTapped), for: .touchUpInside)
    }
}

extension HomeViewController: TrackViewDelegate {
    func trackViewDidChangeSection(_ trackView: TrackView, section: Int) {
        dateLabel.text = Constants.checkIns[section]["date"]
    }
}
