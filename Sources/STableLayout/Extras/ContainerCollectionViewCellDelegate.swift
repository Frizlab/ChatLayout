//
// STableLayout
// ContainerCollectionViewCellDelegate.swift
// https://github.com/ekazaev/ChatLayout
//
// Created by Eugene Kazaev in 2020-2022.
// Distributed under the MIT license.
//

import Foundation
import UIKit

/// A delegate of `ContainerCollectionViewCell`/`ContainerCollectionReusableView` should implement this methods if
/// it is required to participate in containers lifecycle.
public protocol ContainerCollectionViewCellDelegate: AnyObject {

    /// Perform any clean up necessary to prepare the view for use again.
    func prepareForReuse()

    /// Allows to override the call of `ContainerCollectionViewCell`/`ContainerCollectionReusableView`
    /// `UICollectionReusableView.preferredLayoutAttributesFitting(...)` and make the layout calculations.
    ///
    /// **NB**: You must override it to avoid unnecessary autolayout calculations if you are providing exact cell size
    /// in `STableLayoutDelegate.sizeForItem(...)` and return `layoutAttributes` without modifications.
    /// - Parameter layoutAttributes: `STableLayoutAttributes` provided by `STableLayout`
    /// - Returns: Modified `STableLayoutAttributes` on nil if `UICollectionReusableView.preferredLayoutAttributesFitting(...)`
    ///            should be called instead.
    func preferredLayoutAttributesFitting(_ layoutAttributes: STableLayoutAttributes) -> STableLayoutAttributes?

    /// Allows to additionally modify `STableLayoutAttributes` after the `UICollectionReusableView.preferredLayoutAttributesFitting(...)`
    /// call.
    /// - Parameter layoutAttributes: `STableLayoutAttributes` provided by `STableLayout`.
    /// - Returns: Modified `STableLayoutAttributes`
    func modifyPreferredLayoutAttributesFitting(_ layoutAttributes: STableLayoutAttributes)

    /// Apply the specified layout attributes to the view.
    /// Keep in mind that this method can be called multiple times.
    /// - Parameter layoutAttributes: `STableLayoutAttributes` provided by `STableLayout`.
    func apply(_ layoutAttributes: STableLayoutAttributes)

}

/// Default extension to make the methods optional for implementation in the successor
public extension ContainerCollectionViewCellDelegate {

    /// Default implementation does nothing.
    func prepareForReuse() {}

    /// Default implementation returns: `nil`.
    func preferredLayoutAttributesFitting(_ layoutAttributes: STableLayoutAttributes) -> STableLayoutAttributes? {
        return nil
    }

    /// Default implementation does nothing.
    func modifyPreferredLayoutAttributesFitting(_ layoutAttributes: STableLayoutAttributes) {}

    /// Default implementation does nothing.
    func apply(_ layoutAttributes: STableLayoutAttributes) {}

}
