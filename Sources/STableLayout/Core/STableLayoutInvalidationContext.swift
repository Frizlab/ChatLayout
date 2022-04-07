/*
 * STableLayout
 * STableLayoutInvalidationContext.swift
 * https://github.com/ekazaev/ChatLayout
 *
 * Created by Eugene Kazaev in 2020-2022.
 * Distributed under the MIT license.
 */

import Foundation
import UIKit



/** Custom implementation of `UICollectionViewLayoutInvalidationContext`. */
public final class STableLayoutInvalidationContext : UICollectionViewLayoutInvalidationContext {
	
	/**
	 Indicates whether to recompute the positions and sizes of the items based on the current collection view and delegate layout metrics. */
	public var invalidateLayoutMetrics = true
	/**
	 If this is true, only the pinned items should be invalidated; everything should be left as-is. */
	public var invalidateForPinning = false
	
}
