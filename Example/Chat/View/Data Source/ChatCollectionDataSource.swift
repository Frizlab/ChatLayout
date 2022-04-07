//
// STableLayout
// ChatCollectionDataSource.swift
// https://github.com/ekazaev/ChatLayout
//
// Created by Eugene Kazaev in 2020-2022.
// Distributed under the MIT license.
//

import STableLayout
import Foundation
import UIKit

protocol ChatCollectionDataSource: UICollectionViewDataSource, STableLayoutDelegate {

    var sections: [Section] { get set }

    func prepare(with collectionView: UICollectionView)

}
