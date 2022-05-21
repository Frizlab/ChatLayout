/*
 * STableLayout
 * STableLayoutDelegate.swift
 * https://github.com/ekazaev/ChatLayout
 *
 * Created by Eugene Kazaev in 2020-2022.
 * Distributed under the MIT license.
 */

import Foundation
import UIKit



/* TODO: Use a proper name for the delegate methods (w/ the proper prefix, e.g. sTableLayoutShouldPresentHeader(...)) */

/** Represents the point in time `STableLayout` when chat layout asks about layout attributes modification. */
public enum InitialAttributesRequestType {
	
	/** `UICollectionView` initially asks about the layout of an item. */
	case initial
	
	/** An item is being invalidated. */
	case invalidation
	
}


/** `STableLayout` delegate. */
public protocol STableLayoutDelegate : AnyObject {
	
	/**
	 `STableLayout` will call this method to ask if it should present the header in the current layout.
	 
	 - Parameters:
	   - sTableLayout: STableLayout reference.
	   - sectionIndex: Index of the section.
	 - Returns: `Bool`. */
	func shouldPresentHeader(_ sTableLayout: STableLayout, at sectionIndex: Int) -> Bool
	
	/**
	 `STableLayout` will call this method to ask if it should present the footer in the current layout.
	 
	 - Parameters:
	   - sTableLayout: STableLayout reference.
	   - sectionIndex: Index of the section.
	 - Returns: `Bool`. */
	func shouldPresentFooter(_ sTableLayout: STableLayout, at sectionIndex: Int) -> Bool
	
	/**
	 `STableLayout` will call this method to ask what size the item should have.
	 
	 - Note: If you are trying to speed up the layout process by returning exact item sizes in this method,
	 do not forget to change `UICollectionReusableView.preferredLayoutAttributesFitting(...)` method
	 and do not call `super.preferredLayoutAttributesFitting(...)` there as it will measure the `UIView` using Autolayout Engine anyway.
	
	 - Parameters:
	   - sTableLayout: STableLayout reference.
	   - kind: Type of element represented by `ItemKind`.
	   - indexPath: Index path of the item.
	 - Returns: `ItemSize`. */
	func sizeForItem(_ sTableLayout: STableLayout, of kind: ItemKind, at indexPath: IndexPath) -> ItemSize
	
	/**
	 `STableLayout` will call this method to ask what type of alignment the item should have.
	 
	 - Parameters:
	 - sTableLayout: STableLayout reference.
	 - kind: Type of element represented by `ItemKind`.
	 - indexPath: Index path of the item.
	 - Returns: `STableItemAlignment`. */
	func alignmentForItem(_ sTableLayout: STableLayout, of kind: ItemKind, at indexPath: IndexPath) -> STableItemAlignment
	
	/**
	 `STableLayout` will call this method to ask what type of pinning the item should have.
	 
	 - Note: Pinning must be explicitly allowed in STableLayout’s settings.
	 
	 - Parameters:
	 - sTableLayout: STableLayout reference.
	 - kind: Type of element represented by `ItemKind`.
	 - indexPath: Index path of the item.
	 - Returns: `STableItemAlignment`. */
	func pinningForItem(_ sTableLayout: STableLayout, of kind: ItemKind, at indexPath: IndexPath) -> STableItemPinning
	
	/**
	 Asks the delegate to modify a layout attributes instance so that it represents the initial visual state of an item being inserted.
	 The `originalAttributes` instance is a reference type, and therefore can be modified directly.
	
	 - Parameters:
	   - sTableLayout: STableLayout reference.
	   - kind: Type of element represented by `ItemKind`.
	   - indexPath: Index path of the item.
	   - originalAttributes: `STableLayoutAttributes` that the `STableLayout` is going to use.
	   - state: `InitialAttributesRequestType` instance. Represents when is this method being called. */
	func initialLayoutAttributesForInsertedItem(_ sTableLayout: STableLayout, of kind: ItemKind, at indexPath: IndexPath, modifying originalAttributes: STableLayoutAttributes, on state: InitialAttributesRequestType)
	
	/**
	 Asks the delegate to modify a layout attributes instance so that it represents the final visual state of an item being removed via `UICollectionView.deleteSections(_:)`.
	
	 The `originalAttributes` instance is a reference type, and therefore can be modified directly.
	
	 - Parameters:
	   - sTableLayout: STableLayout reference.
	   - kind: Type of element represented by `ItemKind`.
	   - indexPath: Index path of the item.
	   - originalAttributes: `STableLayoutAttributes` that the `STableLayout` is going to use. */
	func finalLayoutAttributesForDeletedItem(_ sTableLayout: STableLayout, of kind: ItemKind, at indexPath: IndexPath, modifying originalAttributes: STableLayoutAttributes)
	
}

/** Default extension. */
public extension STableLayoutDelegate {
	
	/** Default implementation returns: `false`. */
	func shouldPresentHeader(_ sTableLayout: STableLayout, at sectionIndex: Int) -> Bool {
		return false
	}
	
	/** Default implementation returns: `false`. */
	func shouldPresentFooter(_ sTableLayout: STableLayout, at sectionIndex: Int) -> Bool {
		return false
	}
	
	/** Default implementation returns: `ItemSize.auto`. */
	func sizeForItem(_ sTableLayout: STableLayout, of kind: ItemKind, at indexPath: IndexPath) -> ItemSize {
		return .auto
	}
	
	/** Default implementation returns: `STableItemAlignment.fullWidth`. */
	func alignmentForItem(_ sTableLayout: STableLayout, of kind: ItemKind, at indexPath: IndexPath) -> STableItemAlignment {
		return .fullWidth
	}
	
	/** Default implementation returns: ``STableItemPinning.none``. */
	func pinningForItem(_ sTableLayout: STableLayout, of kind: ItemKind, at indexPath: IndexPath) -> STableItemPinning {
		return .none
	}
	
	/** Default implementation sets a `STableLayoutAttributes.alpha` to zero. */
	func initialLayoutAttributesForInsertedItem(_ sTableLayout: STableLayout, of kind: ItemKind, at indexPath: IndexPath, modifying originalAttributes: STableLayoutAttributes, on state: InitialAttributesRequestType) {
		originalAttributes.alpha = 0
	}
	
	/** Default implementation sets a `STableLayoutAttributes.alpha` to zero. */
	func finalLayoutAttributesForDeletedItem(_ sTableLayout: STableLayout, of kind: ItemKind, at indexPath: IndexPath, modifying originalAttributes: STableLayoutAttributes) {
		originalAttributes.alpha = 0
	}
	
}
