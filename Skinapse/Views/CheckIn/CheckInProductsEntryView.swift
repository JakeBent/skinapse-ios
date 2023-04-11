//
//  CheckInProductsEntryView.swift
//  Skinapse
//
//  Created by Jake Benton on 8/12/18.
//  Copyright © 2018 skinapse. All rights reserved.
//

import UIKit

class CheckInProductsEntryView: UIView {

    class Constants: MasterConstants {
        static let products = [
            "Clinique Cleanser",
            "Nivea Toner",
            "Nivea Moisturizer",
            "Clinique Cleanser",
            "Nivea Toner",
            "Nivea Moisturizer",
            "Clinique Cleanser",
            "Nivea Toner",
            "Nivea Moisturizer",
            "Clinique Cleanser",
            "Nivea Toner",
            "Nivea Moisturizer",
        ]
    }

    class Layout: MasterLayout {
        static let resultsHeight: CGFloat = 176
    }

    var resultsViewHeight: CGFloat = 0 {
        didSet {
            resultsViewHeightConstraint.constant = resultsViewHeight
        }
    }

    var layout: (() -> Void)?
    var expand: (() -> Void)?
    let input = Layout.textField()
    private let resultsView: UITableView = {
        let tableView = UITableView()
        tableView.backgroundColor = .white
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.alwaysBounceVertical = true
        tableView.contentInsetAdjustmentBehavior = .never
        tableView.sectionHeaderHeight = 50
        tableView.estimatedRowHeight = 100
        tableView.separatorInset = .zero
        tableView.register(cellClass: UITableViewCell.self)
        return tableView
    }()
    private var resultsViewHeightConstraint: NSLayoutConstraint!
    private let stack = Layout.stack(
        withAxis: .vertical,
        distribution: .equalSpacing,
        alignment: .fill,
        spacing: Layout.smallSpacing
    )


    private var views: [UIView] {
        return [stack, input, resultsView]
    }

    init() {
        super.init(frame: .zero)
        initialLayout()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension CheckInProductsEntryView: UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate {
    private func initialLayout() {
        backgroundColor = .clear
        translatesAutoresizingMaskIntoConstraints = false
        isHidden = true

        views.forEach { addSubview($0) }

        stack.topAnchor.constraint(equalTo: topAnchor, constant: Layout.smallSpacing).isActive = true
        stack.leftAnchor.constraint(equalTo: leftAnchor, constant: Layout.standardSpacing).isActive = true
        stack.rightAnchor.constraint(equalTo: rightAnchor, constant: -Layout.standardSpacing).isActive = true

        input.topAnchor.constraint(equalTo: stack.bottomAnchor, constant: Layout.smallSpacing).isActive = true
        input.leftAnchor.constraint(equalTo: leftAnchor, constant: Layout.standardSpacing).isActive = true
        input.rightAnchor.constraint(equalTo: rightAnchor, constant: -Layout.standardSpacing).isActive = true
        input.heightAnchor.constraint(equalToConstant: 24).isActive = true

        resultsView.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        resultsView.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        resultsView.topAnchor.constraint(equalTo: input.bottomAnchor).isActive = true
        resultsView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        resultsViewHeightConstraint = resultsView.heightAnchor.constraint(equalToConstant: Layout.resultsHeight)
        resultsViewHeightConstraint.isActive = true

        input.delegate = self
        resultsView.dataSource = self
        resultsView.delegate = self
    }

    func assign() {
        input.becomeFirstResponder()
    }

    func resign() {
        input.resignFirstResponder()
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Constants.products.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell = tableView.dequeue()
        cell.textLabel?.font = .main(size: 13)
        cell.textLabel?.text = Constants.products[indexPath.row]
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        stack.addArrangedSubview(Layout.label(withColor: .black, font: .main(size: 14), text: Constants.products[indexPath.row]))
        UIView.animate(withDuration: 0.2) { [weak self] in
            self?.layout?()
        }
    }

    func textFieldDidBeginEditing(_ textField: UITextField) {
        if resultsViewHeightConstraint.constant != Layout.resultsHeight {
            expand?()
        }
    }
}
