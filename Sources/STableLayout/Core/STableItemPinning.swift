/*
 * STableLayout
 * STableItemPinning.swift
 * https://github.com/ekazaev/ChatLayout
 *
 * Created by Eugene Kazaev in 2020-2022.
 * Distributed under the MIT license.
 */

import Foundation
import UIKit



/**
 Where should the item be pinned (relative to the collection view visible area)?
 
 Pinning is done relatively to a section.
 Pinning a non-header or footer is uncommon, but not impossible. */
public enum STableItemPinning : Hashable {
	
	/** Do not pin the item. */
	case none
	
	/** Pin the item on top of the visible area (usual for headers). */
	case top
	
	/** Pin the item at the bottom the visible area (usual for footers). */
	case bottom
	
}
