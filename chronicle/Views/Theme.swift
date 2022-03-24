//
//  Theme.swift
//  chronicle
//
//  Created by Alfonce Nzioka on 3/24/22.
//  Copyright © 2022 OpenLattice, Inc. All rights reserved.
//

import Foundation
import UIKit
import SwiftUI

class Theme {
    static func navigationBarStyle() {
        let navigationAppearance = UINavigationBarAppearance()
        navigationAppearance.configureWithOpaqueBackground()
        navigationAppearance.backgroundColor = UIColor(.primaryPurple)
        let textAttributes: [NSAttributedString.Key : Any ] = [
            .foregroundColor: UIColor.white,
            .font: UIFont.systemFont(ofSize: 20, weight: UIFont.Weight.bold)
        ]
        navigationAppearance.titleTextAttributes = textAttributes
        navigationAppearance.largeTitleTextAttributes = textAttributes
        
        UINavigationBar.appearance().standardAppearance = navigationAppearance
        UINavigationBar.appearance().compactAppearance = navigationAppearance
        UINavigationBar.appearance().scrollEdgeAppearance = navigationAppearance
        UINavigationBar.appearance().tintColor = UIColor.white
    }
}
