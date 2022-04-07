/*
 * STableLayout
 * STableLayoutAttributes.swift
 * https://github.com/ekazaev/ChatLayout
 *
 * Created by Eugene Kazaev in 2020-2022.
 * Distributed under the MIT license.
 */

import Foundation
import UIKit



/** Custom implementation of `UICollectionViewLayoutAttributes`. */
public final class STableLayoutAttributes : UICollectionViewLayoutAttributes {
	
	/** Alignment of the current item. Can be changed within `UICollectionViewCell.preferredLayoutAttributesFitting(...)`. */
	public var alignment: STableItemAlignment = .fullWidth
	
	/** `STableLayout`s additional insets setup using `STableLayoutSettings`. Added for convenience. */
	public internal(set) var additionalInsets: UIEdgeInsets = .zero
	
	/** `UICollectionView`s frame size. Added for convenience. */
	public internal(set) var viewSize: CGSize = .zero
	
	/** `UICollectionView`s adjusted content insets. Added for convenience. */
	public internal(set) var adjustedContentInsets: UIEdgeInsets = .zero
	
	/** `STableLayout`s visible bounds size excluding `adjustedContentInsets`. Added for convenience. */
//	public internal(set) var visibleBoundsSize: CGSize = .zero
	
	/** `STableLayout`s visible bounds size excluding `adjustedContentInsets` and `additionalInsets`. Added for convenience. */
	public internal(set) var layoutFrame: CGRect = .zero
	
	public internal(set) var pinned: Bool = false
	
#if DEBUG
	var id: UUID?
#endif
	
	convenience init(kind: ItemKind, indexPath: IndexPath = IndexPath(item: 0, section: 0)) {
		switch kind {
			case .cell:
				self.init(forCellWith: indexPath)
			case .header:
				self.init(forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, with: indexPath)
			case .footer:
				self.init(forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, with: indexPath)
		}
	}
	
	/** Returns an exact copy of `STableLayoutAttributes`. */
	public override func copy(with zone: NSZone? = nil) -> Any {
		let copy = super.copy(with: zone) as! STableLayoutAttributes
		copy.alignment = alignment
		copy.additionalInsets = additionalInsets
		copy.viewSize = viewSize
		copy.adjustedContentInsets = adjustedContentInsets
//		copy.visibleBoundsSize = visibleBoundsSize
		copy.layoutFrame = layoutFrame
#if DEBUG
		copy.id = id
#endif
		return copy
	}
	
	/** Returns a Boolean value indicating whether two `STableLayoutAttributes` are considered equal. */
	public override func isEqual(_ object: Any?) -> Bool {
		return super.isEqual(object)
		&& alignment == (object as? STableLayoutAttributes)?.alignment
	}
	
	/** `ItemKind` represented by this attributes object. */
	public var kind: ItemKind {
		switch (representedElementCategory, representedElementKind) {
			case (.cell, nil):
				return .cell
			case (.supplementaryView, .some(UICollectionView.elementKindSectionHeader)):
				return .header
			case (.supplementaryView, .some(UICollectionView.elementKindSectionFooter)):
				return .footer
			default:
				preconditionFailure("Unsupported element kind")
		}
	}
	
	func typedCopy() -> STableLayoutAttributes {
		guard let typedCopy = copy() as? STableLayoutAttributes else {
			fatalError("Internal inconsistency")
		}
		return typedCopy
	}
	
}
