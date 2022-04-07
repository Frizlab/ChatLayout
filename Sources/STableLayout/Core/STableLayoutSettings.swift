/*
 * STableLayout
 * STableLayoutSettings.swift
 * https://github.com/ekazaev/ChatLayout
 *
 * Created by Eugene Kazaev in 2020-2022.
 * Distributed under the MIT license.
 */

import Foundation
import UIKit



/** `STableLayout` settings. */
public struct STableLayoutSettings {
	
	/**
	 Estimated item size for `STableLayout`.
	 This value will be used as the initial size of the item and the final size will be calculated using `UICollectionViewCell.preferredLayoutAttributesFitting(...)`. */
	public var estimatedItemSize: CGSize?
	
	/** Spacing between the items in the section. */
	public var interItemSpacing: CGFloat = 0
	
	/** Spacing between the sections. */
	public var interSectionSpacing: CGFloat = 0
	
	/** Additional insets for the `STableLayout` content. */
	public var additionalInsets: UIEdgeInsets = .zero
	
	/** Pinning must be explicitly allowed because it has a performance impact (the layout must be invalidated whenever the collection view is scrolled). */
	public var allowPinning: Bool = false
	
}
