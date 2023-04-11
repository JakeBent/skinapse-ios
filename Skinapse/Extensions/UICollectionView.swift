//
//  UICollectionView.swift
//  Skinapse
//
//  Created by Jake Benton on 7/26/18.
//  Copyright © 2018 skinapse. All rights reserved.
//

import UIKit

extension UICollectionView {
    func register(cellClass: UICollectionViewCell.Type) {
        register(cellClass, forCellWithReuseIdentifier: String(describing: cellClass))
    }

    func register(nibFor cellClass: UICollectionViewCell.Type) {
        let className = String(describing: cellClass)
        let nib = UINib(nibName: className, bundle: Bundle(for: cellClass))
        register(nib, forCellWithReuseIdentifier: className)
    }

    func register(headerClass: UICollectionReusableView.Type) {
        register(headerClass,
                 forSupplementaryViewOfKind: UICollectionElementKindSectionHeader,
                 withReuseIdentifier: String(describing: headerClass)
        )
    }

    func dequeue<T: UICollectionViewCell>(indexPath: IndexPath) -> T {
        return dequeueReusableCell(withReuseIdentifier: String(describing: T.self), for: indexPath) as! T
    }

    func dequeueHeader<T: UICollectionReusableView>(indexPath: IndexPath) -> T {
        return dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionHeader, withReuseIdentifier: String(describing: T.self), for: indexPath) as! T
    }
}
