/*
 * ChatLayout
 * ItemModel.swift
 * https://github.com/ekazaev/ChatLayout
 *
 * Created by Eugene Kazaev in 2020-2022.
 * Distributed under the MIT license.
 */

import Foundation
import UIKit



struct ItemModel {
	
	struct Configuration {
		
		let preferredSize: CGSize
		let calculatedSize: CGSize?
		
		let alignment: ChatItemAlignment
		let pinning: ChatItemPinning
		
	}
	
	let id: UUID
	
	var preferredSize: CGSize
	var calculatedSize: CGSize?
	var calculatedOnce: Bool = false
	
	var alignment: ChatItemAlignment
	var pinning: ChatItemPinning
	var pinned: Bool {pinning != .none}
	
	var offsetY: CGFloat = .zero
	
	var origin: CGPoint {
		return CGPoint(x: 0, y: offsetY)
	}
	
	var height: CGFloat {
		return size.height
	}
	
	var locationHeight: CGFloat {
		return offsetY + height
	}
	
	var size: CGSize {
		guard let calculatedSize = calculatedSize else {
			return preferredSize
		}
		
		return calculatedSize
	}
	
	var frame: CGRect {
		return CGRect(origin: origin, size: size)
	}
	
	init(id: UUID = UUID(), with configuration: Configuration) {
		self.id = id
		self.pinning = configuration.pinning
		self.alignment = configuration.alignment
		self.preferredSize = configuration.preferredSize
		self.calculatedSize = configuration.calculatedSize
		self.calculatedOnce = configuration.calculatedSize != nil
	}
	
	/* We are just resetting `calculatedSize` if needed as the actual size will be found in invalidationContext(forPreferredLayoutAttributes:, withOriginalAttributes:).
	 * It is important for the rotation to keep previous frame size. */
	mutating func resetSize() {
		guard let oldSize = calculatedSize else {
			return
		}
		calculatedSize = nil
		preferredSize = oldSize
	}
	
}
