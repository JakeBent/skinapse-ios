//
//  PassThroughView.swift
//  Skinapse
//
//  Created by Jake Benton on 7/31/18.
//  Copyright © 2018 skinapse. All rights reserved.
//

import UIKit

class PassThroughView: UIView {
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        return false
    }
}
