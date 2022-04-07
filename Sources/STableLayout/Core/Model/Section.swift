/*
 * STableLayout
 * Section.swift
 * https://github.com/ekazaev/ChatLayout
 *
 * Created by Eugene Kazaev in 2020-2022.
 * Distributed under the MIT license.
 */

import Foundation
import UIKit



struct Section {
	
	let id: UUID
	
	private(set) var header: Item?
	private(set) var footer: Item?
	private(set) var items: [Item]
	
	/* The following statements are true when the model is assembled:
	 *   - Both arrays are sorted ascending;
	 *   - The intersection of staticItemIndexes and pinnedItemIndexes is empty;
	 *   - The union of staticItemIndexes and pinnedItemIndexes contains all of the indexes of items (0..<items.count). */
	private(set) var staticItemIndexes = [Array<Item>.Index]()
	private(set) var pinnedItemIndexes = [Array<Item>.Index]()

	var offsetY: CGFloat = 0
	
	private unowned var collectionLayout: STableLayoutRepresentation
	
	var count: Int {
		return items.count
	}
	
	var frame: CGRect {
		let additionalInsets = collectionLayout.settings.additionalInsets
		return CGRect(
			x: 0,
			y: offsetY,
			width: collectionLayout.visibleBounds.width - additionalInsets.left - additionalInsets.right,
			height: height
		)
	}
	
	var height: CGFloat {
		if let footer = footer {
			return footer.frame.maxY
		} else {
			guard let lastItem = items.last else {
				return header?.frame.maxY ?? .zero
			}
			return lastItem.locationHeight
		}
	}
	
	var locationHeight: CGFloat {
		return offsetY + height
	}
	
	init(
		id: UUID = UUID(),
		header: Item?,
		footer: Item?,
		items: [Item] = [],
		collectionLayout: STableLayoutRepresentation
	) {
		self.id = id
		self.items = items
		self.collectionLayout = collectionLayout
		self.header = header
		self.footer = footer
	}
	
	mutating func assembleLayout() {
		var offsetY: CGFloat = 0
		
		if header != nil {
			header?.offsetY = 0
			offsetY += header?.frame.height ?? 0
		}
		
		staticItemIndexes.removeAll()
		pinnedItemIndexes.removeAll()
		staticItemIndexes.reserveCapacity(items.count)
		
		for rowIndex in 0..<items.count {
			items[rowIndex].offsetY = offsetY
			offsetY += items[rowIndex].height + collectionLayout.settings.interItemSpacing
			if !items[rowIndex].pinned {staticItemIndexes.append(rowIndex)}
			else                       {pinnedItemIndexes.append(rowIndex)}
		}
		
		if footer != nil {
			footer?.offsetY = offsetY
		}
	}
	
	/* ****************************************************************
	   MARK: To use when its is important to make the correct insertion
	   **************************************************************** */
	
	mutating func setAndAssemble(header: Item) {
		guard let oldHeader = self.header else {
			self.header = header
			offsetEverything(below: -1, by: header.height)
			return
		}
#if DEBUG
		if header.id != oldHeader.id {
			assertionFailure("Internal inconsistency")
		}
#endif
		self.header = header
		let heightDiff = header.height - oldHeader.height
		offsetEverything(below: -1, by: heightDiff)
	}
	
	mutating func setAndAssemble(item: Item, at index: Int) {
		guard index < count else {
			assertionFailure("Incorrect item index.")
			return
		}
		let oldItem = items[index]
#if DEBUG
		if item.id != oldItem.id {
			assertionFailure("Internal inconsistency")
		}
#endif
		items[index] = item
		
		let heightDiff = item.height - oldItem.height
		offsetEverything(below: index, by: heightDiff)
		
		/* TVR TODO: Optimize this */
		if oldItem.pinned && !item.pinned {
			pinnedItemIndexes.removeAll{ $0 == index }
			staticItemIndexes.append(index)
			staticItemIndexes.sort()
		} else if !oldItem.pinned && item.pinned {
			staticItemIndexes.removeAll{ $0 == index }
			pinnedItemIndexes.append(index)
			pinnedItemIndexes.sort()
		}
	}
	
	mutating func setAndAssemble(footer: Item) {
#if DEBUG
		if let oldFooter = self.footer,
			footer.id != oldFooter.id {
			assertionFailure("Internal inconsistency")
		}
#endif
		self.footer = footer
	}
	
	/* *******************
	   MARK: Just updaters
	   ******************* */
	
	mutating func set(header: Item?) {
		self.header = header
	}
	
	mutating func set(items: [Item]) {
		self.items = items
	}
	
	mutating func set(footer: Item?) {
		self.footer = footer
	}
	
	private mutating func offsetEverything(below index: Int, by heightDiff: CGFloat) {
		guard heightDiff != 0 else {
			return
		}
		if index < items.count - 1 {
			for index in (index + 1)..<items.count {
				items[index].offsetY += heightDiff
			}
		}
		footer?.offsetY += heightDiff
	}
	
	/* ***********************************************
	   MARK: To use only withing process(updateItems:)
	   *********************************************** */
	
	mutating func insert(_ item: Item, at index: Int) {
		guard index <= count else {
			assertionFailure("Incorrect item index.")
			return
		}
		items.insert(item, at: index)
	}
	
	mutating func replace(_ item: Item, at index: Int) {
		guard index <= count else {
			assertionFailure("Incorrect item index.")
			return
		}
		items[index] = item
	}
	
	mutating func remove(at index: Int) {
		guard index < count else {
			assertionFailure("Incorrect item index.")
			return
		}
		items.remove(at: index)
	}
	
}
