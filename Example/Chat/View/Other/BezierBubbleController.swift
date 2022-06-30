//
// STableLayout
// BezierBubbleController.swift
// https://github.com/ekazaev/ChatLayout
//
// Created by Eugene Kazaev in 2020-2022.
// Distributed under the MIT license.
//

import Foundation
import UIKit

final class BezierBubbleController<CustomView: UIView>: BubbleController {

    private let controllerProxy: any BubbleController

    private let type: MessageType

    private let bubbleType: Cell.BubbleType

    weak var bubbleView: BezierMaskedView<CustomView>? {
        didSet {
            setupBubbleView()
        }
    }

    init(bubbleView: BezierMaskedView<CustomView>, controllerProxy: any BubbleController, type: MessageType, bubbleType: Cell.BubbleType) {
        self.controllerProxy = controllerProxy
        self.type = type
        self.bubbleType = bubbleType
        self.bubbleView = bubbleView
        setupBubbleView()
    }

    private func setupBubbleView() {
        guard let bubbleView = bubbleView else {
            return
        }

        bubbleView.messageType = type
        bubbleView.bubbleType = bubbleType
    }

}
