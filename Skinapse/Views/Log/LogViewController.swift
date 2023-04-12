//
//  LogViewController.swift
//  Skinapse
//
//  Created by Jake Benton on 7/25/18.
//  Copyright © 2018 skinapse. All rights reserved.
//

import UIKit

class LogViewController: ViewController {

    class Layout: MasterLayout {
        static let tableViewHeaderHeight: CGFloat = 50
    }

    private let viewModel = LogViewModel()
    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.backgroundColor = .backgroundGrey
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.alwaysBounceVertical = true
        tableView.contentInsetAdjustmentBehavior = .never
        tableView.sectionHeaderHeight = Layout.tableViewHeaderHeight
        tableView.estimatedRowHeight = 100
        tableView.separatorStyle = .none
        tableView.register(cellClass: ProductLogCell.self)
        tableView.register(cellClass: SliderLogCell.self)
        tableView.register(headerClass: LogEntryHeader.self)
        return tableView
    }()
    private let detailContainer = Layout.view(withColor: .backgroundGrey)
    private let silhouette = Layout.imageView(withImage: #imageLiteral(resourceName: "silhouette"), renderingMode: .alwaysOriginal)
    private let slider = ThreePointSlider()
    private var tableViewLeftConstraint: NSLayoutConstraint!
    private var tableViewRightConstraint: NSLayoutConstraint!
    private var tableViewWidthConstraint: NSLayoutConstraint!
    private var detailLeftConstraint: NSLayoutConstraint!
    private var detailRightConstraint: NSLayoutConstraint!

    private var views: [UIView] {
        return [detailContainer, tableView]
    }
    private var detailViews: [UIView] {
        return [silhouette, slider]
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.dataSource = viewModel
        tableView.delegate = viewModel
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) { [weak self] in
            self?.navController?.showAlert(text: "New Alert :)")
        }
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)

        coordinator.animate(alongsideTransition: { _ in
            self.layout(for: size)
        })
    }

    override func layout(for size: CGSize, startOrientation: UIInterfaceOrientation? = nil) {
        super.layout(for: size, startOrientation: startOrientation)

        switch UIApplication.shared.statusBarOrientation {
        case .landscapeLeft:
            tableViewLeftConstraint.isActive = true
            tableViewRightConstraint.isActive = false
            tableViewWidthConstraint.isActive = true
            detailLeftConstraint.constant = Layout.smallestSide
            detailRightConstraint.constant = 0
        case .landscapeRight:
            tableViewLeftConstraint.isActive = true
            tableViewRightConstraint.isActive = false
            tableViewWidthConstraint.isActive = true
            detailLeftConstraint.constant = Layout.smallestSide
            detailRightConstraint.constant = 0
        default:
            tableViewLeftConstraint.isActive = true
            tableViewRightConstraint.isActive = true
            tableViewWidthConstraint.isActive = false
            detailLeftConstraint.constant = 0
            detailRightConstraint.constant = 0
        }
    }
}

extension LogViewController {
    override func initialLayout() {
        super.initialLayout()

        views.forEach { contentView.addSubview($0) }
        detailViews.forEach { detailContainer.addSubview($0) }

        tableViewLeftConstraint = tableView.leftAnchor.constraint(equalTo: contentView.leftAnchor)
        tableViewLeftConstraint.isActive = true
        tableViewRightConstraint = tableView.rightAnchor.constraint(equalTo: contentView.rightAnchor)
        tableViewRightConstraint.isActive = true
        tableViewWidthConstraint = tableView.widthAnchor.constraint(equalToConstant: Layout.smallestSide)
        tableViewWidthConstraint.priority = .defaultHigh
        tableView.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
        tableView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true

        detailContainer.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
        detailContainer.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true
        detailLeftConstraint = detailContainer.leftAnchor.constraint(equalTo: contentView.leftAnchor)
        detailRightConstraint = detailContainer.rightAnchor.constraint(equalTo: contentView.rightAnchor)
        detailLeftConstraint.isActive = true
        detailRightConstraint.isActive = true

        silhouette.widthAnchor.constraint(equalToConstant: Layout.silhouetteWidth).isActive = true
        silhouette.heightAnchor.constraint(equalToConstant: Layout.silhouetteHeight).isActive = true
        silhouette.centerXAnchor.constraint(equalTo: detailContainer.centerXAnchor).isActive = true
        silhouette.centerYAnchor.constraint(equalTo: detailContainer.centerYAnchor).isActive = true

        slider.topAnchor.constraint(equalTo: silhouette.bottomAnchor, constant: Layout.standardSpacing).isActive = true
        slider.centerXAnchor.constraint(equalTo: detailContainer.centerXAnchor).isActive = true

        layout(for: .zero)
    }
}

class LogViewModel: NSObject, UITableViewDataSource, UITableViewDelegate {
//    var checkIns: [CheckIn] = [] {
//        didSet {
//            expanded = checkIns.map { _ in false }
//        }
//    }
    var expanded: [Bool] = []

    func numberOfSections(in tableView: UITableView) -> Int {
        return 4
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let cell: LogEntryHeader = tableView.dequeue()
        cell.setup(text: "June \(section)")
        return cell
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row < 2 {
            let cell: ProductLogCell = tableView.dequeue()
            cell.setup()
            return cell
        } else {
            let cell: SliderLogCell = tableView.dequeue()
            cell.setup()
            return cell
        }
    }
}
