//
//  HomeViewViewModel.swift
//  Skinapse
//
//  Created by Jacob Benton on 4/11/23.
//  Copyright © 2023 skinapse. All rights reserved.
//

import Foundation

class HomeViewViewModel {
    var viewController: HomeViewController?
    var user: User? {
        didSet {
            
        }
    }
    
    func fetchData() {
        Task {
            user = await API.me()
        }
    }
}
