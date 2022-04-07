//
// STableLayout
// MainContainerView.swift
// https://github.com/ekazaev/ChatLayout
//
// Created by Eugene Kazaev in 2020-2022.
// Distributed under the MIT license.
//

import STableLayout
import Foundation
import UIKit

final class MainContainerView<LeadingAccessory: StaticViewFactory, CustomView: UIView, TrailingAccessory: StaticViewFactory>: UIView, SwipeNotifierDelegate {

    var swipeCompletionRate: CGFloat = 0 {
        didSet {
            updateOffsets()
        }
    }

    var avatarView: LeadingAccessory.View? {
        return containerView.leadingView
    }

    var customView: BezierMaskedView<CustomView> {
        return containerView.customView
    }

    var statusView: TrailingAccessory.View? {
        return containerView.trailingView
    }

    weak var accessoryConnectingView: UIView? {
        didSet {
            guard accessoryConnectingView != oldValue else {
                return
            }
            updateAccessoryView()
        }
    }

    var accessoryView = DateAccessoryView()

    var accessorySafeAreaInsets: UIEdgeInsets = .zero {
        didSet {
            guard accessorySafeAreaInsets != oldValue else {
                return
            }
            accessoryOffsetConstraint?.constant = accessorySafeAreaInsets.right
            setNeedsLayout()
            updateOffsets()
        }
    }

    private(set) lazy var containerView = CellLayoutContainerView<LeadingAccessory, BezierMaskedView<CustomView>, TrailingAccessory>()

    private weak var accessoryOffsetConstraint: NSLayoutConstraint?

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupSubviews()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupSubviews()
    }

    private func setupSubviews() {
        translatesAutoresizingMaskIntoConstraints = false
        insetsLayoutMarginsFromSafeArea = false
        layoutMargins = .zero
        clipsToBounds = false
        addSubview(containerView)
        containerView.leadingAnchor.constraint(equalTo: layoutMarginsGuide.leadingAnchor).isActive = true
        containerView.trailingAnchor.constraint(equalTo: layoutMarginsGuide.trailingAnchor).isActive = true
        containerView.topAnchor.constraint(equalTo: layoutMarginsGuide.topAnchor).isActive = true
        containerView.bottomAnchor.constraint(equalTo: layoutMarginsGuide.bottomAnchor).isActive = true

        accessoryView.translatesAutoresizingMaskIntoConstraints = false

        updateOffsets()
    }

    private func updateAccessoryView() {
        accessoryView.removeFromSuperview()
        guard let avatarConnectingView = accessoryConnectingView,
              let avatarConnectingSuperview = avatarConnectingView.superview else {
            return
        }
        avatarConnectingSuperview.addSubview(accessoryView)
        accessoryOffsetConstraint = accessoryView.leadingAnchor.constraint(equalTo: avatarConnectingView.trailingAnchor, constant: accessorySafeAreaInsets.right)
        accessoryOffsetConstraint?.isActive = true
        accessoryView.centerYAnchor.constraint(equalTo: avatarConnectingView.centerYAnchor).isActive = true
    }

    private func updateOffsets() {
        if let avatarView = avatarView,
           !avatarView.isHidden {
            avatarView.transform = CGAffineTransform(translationX: -((avatarView.bounds.width + accessorySafeAreaInsets.left) * swipeCompletionRate), y: 0)
        }
        switch containerView.customView.messageType {
        case .incoming:
            customView.transform = .identity
            customView.transform = CGAffineTransform(translationX: -(customView.frame.origin.x * swipeCompletionRate), y: 0)
        case .outgoing:
            let maxOffset = min(frame.origin.x, accessoryView.frame.width)
            customView.transform = .identity
            customView.transform = CGAffineTransform(translationX: -(maxOffset * swipeCompletionRate), y: 0)
            if let statusView = statusView,
               !statusView.isHidden {
                statusView.transform = CGAffineTransform(translationX: -(maxOffset * swipeCompletionRate), y: 0)
            }
        }

        accessoryView.transform = CGAffineTransform(translationX: -((accessoryView.bounds.width + accessorySafeAreaInsets.right) * swipeCompletionRate), y: 0)
    }

}
