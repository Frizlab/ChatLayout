//
// STableLayout
// DefaultChatCollectionDataSource.swift
// https://github.com/ekazaev/ChatLayout
//
// Created by Eugene Kazaev in 2020-2022.
// Distributed under the MIT license.
//

import STableLayout
import Foundation
import UIKit

typealias TextMessageCollectionCell = ContainerCollectionViewCell<MessageContainerView<EditingAccessoryView, MainContainerView<AvatarView, TextMessageView, StatusView>>>
@available(iOS 13, *)
typealias URLCollectionCell = ContainerCollectionViewCell<MessageContainerView<EditingAccessoryView, MainContainerView<AvatarView, URLView, StatusView>>>
typealias ImageCollectionCell = ContainerCollectionViewCell<MessageContainerView<EditingAccessoryView, MainContainerView<AvatarView, ImageView, StatusView>>>
typealias TitleCollectionCell = ContainerCollectionViewCell<UILabel>
typealias DateTitleCollectionCell = ContainerCollectionViewCell<RoundedCornersContainerView<UILabel>>
typealias TypingIndicatorCollectionCell = ContainerCollectionViewCell<MessageContainerView<EditingAccessoryView, MainContainerView<AvatarPlaceholderView, TextMessageView, VoidViewFactory>>>

typealias TextTitleView = ContainerCollectionReusableView<UILabel>

final class DefaultChatCollectionDataSource: NSObject, ChatCollectionDataSource {

    private unowned var reloadDelegate: any ReloadDelegate

    private unowned var editingDelegate: any EditingAccessoryControllerDelegate

    private let editNotifier: EditNotifier

    private let swipeNotifier: SwipeNotifier

    var sections: [Section] = [] {
        didSet {
            oldSections = oldValue
        }
    }

    private var oldSections: [Section] = []

    init(editNotifier: EditNotifier,
         swipeNotifier: SwipeNotifier,
         reloadDelegate: any ReloadDelegate,
         editingDelegate: any EditingAccessoryControllerDelegate) {
        self.reloadDelegate = reloadDelegate
        self.editingDelegate = editingDelegate
        self.editNotifier = editNotifier
        self.swipeNotifier = swipeNotifier
    }

    func prepare(with collectionView: UICollectionView) {
        collectionView.register(TextMessageCollectionCell.self, forCellWithReuseIdentifier: TextMessageCollectionCell.reuseIdentifier)
        collectionView.register(ImageCollectionCell.self, forCellWithReuseIdentifier: ImageCollectionCell.reuseIdentifier)
        collectionView.register(TitleCollectionCell.self, forCellWithReuseIdentifier: TitleCollectionCell.reuseIdentifier)
        collectionView.register(DateTitleCollectionCell.self, forCellWithReuseIdentifier: DateTitleCollectionCell.reuseIdentifier)
        collectionView.register(TypingIndicatorCollectionCell.self, forCellWithReuseIdentifier: TypingIndicatorCollectionCell.reuseIdentifier)
        collectionView.register(TextTitleView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: TextTitleView.reuseIdentifier)
        collectionView.register(TextTitleView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: TextTitleView.reuseIdentifier)
        if #available(iOS 13.0, *) {
            collectionView.register(URLCollectionCell.self, forCellWithReuseIdentifier: URLCollectionCell.reuseIdentifier)
        }
    }

    private func createTextCell(collectionView: UICollectionView, messageId: UUID, indexPath: IndexPath, text: String, date: Date, alignment: STableItemAlignment, user: User, bubbleType: Cell.BubbleType, status: MessageStatus, messageType: MessageType) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TextMessageCollectionCell.reuseIdentifier, for: indexPath) as! TextMessageCollectionCell
        setupMessageContainerView(cell.customView, messageId: messageId, alignment: alignment)
        setupMainMessageView(cell.customView.customView, user: user, alignment: alignment, bubble: bubbleType, status: status)

        setupSwipeHandlingAccessory(cell.customView.customView, date: date, accessoryConnectingView: cell.customView)

        let bubbleView = cell.customView.customView.customView
        let controller = TextMessageController(text: text,
                                               type: messageType,
                                               bubbleController: buildTextBubbleController(bubbleView: bubbleView, messageType: messageType, bubbleType: bubbleType))
        bubbleView.customView.setup(with: controller)
        controller.view = bubbleView.customView
        cell.delegate = bubbleView.customView

        return cell
    }

    @available(iOS 13, *)
    private func createURLCell(collectionView: UICollectionView, messageId: UUID, indexPath: IndexPath, url: URL, date: Date, alignment: STableItemAlignment, user: User, bubbleType: Cell.BubbleType, status: MessageStatus, messageType: MessageType) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: URLCollectionCell.reuseIdentifier, for: indexPath) as! URLCollectionCell
        setupMessageContainerView(cell.customView, messageId: messageId, alignment: alignment)
        setupMainMessageView(cell.customView.customView, user: user, alignment: alignment, bubble: bubbleType, status: status)

        setupSwipeHandlingAccessory(cell.customView.customView, date: date, accessoryConnectingView: cell.customView)

        let bubbleView = cell.customView.customView.customView
        let controller = URLController(url: url,
                                       messageId: messageId,
                                       bubbleController: buildBezierBubbleController(for: bubbleView, messageType: messageType, bubbleType: bubbleType))

        bubbleView.customView.setup(with: controller)
        controller.view = bubbleView.customView
        controller.delegate = reloadDelegate
        cell.delegate = bubbleView.customView

        return cell
    }

    private func createImageCell(collectionView: UICollectionView, messageId: UUID, indexPath: IndexPath, alignment: STableItemAlignment, user: User, source: ImageMessageSource, date: Date, bubbleType: Cell.BubbleType, status: MessageStatus, messageType: MessageType) -> ImageCollectionCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ImageCollectionCell.reuseIdentifier, for: indexPath) as! ImageCollectionCell

        setupMessageContainerView(cell.customView, messageId: messageId, alignment: alignment)
        setupMainMessageView(cell.customView.customView, user: user, alignment: alignment, bubble: bubbleType, status: status)

        setupSwipeHandlingAccessory(cell.customView.customView, date: date, accessoryConnectingView: cell.customView)

        let bubbleView = cell.customView.customView.customView
        let controller = ImageController(source: source,
                                         messageId: messageId,
                                         bubbleController: buildBezierBubbleController(for: bubbleView, messageType: messageType, bubbleType: bubbleType))

        controller.delegate = reloadDelegate
        bubbleView.customView.setup(with: controller)
        controller.view = bubbleView.customView
        cell.delegate = bubbleView.customView

        return cell
    }

    private func createTypingIndicatorCell(collectionView: UICollectionView, indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TypingIndicatorCollectionCell.reuseIdentifier, for: indexPath) as! TypingIndicatorCollectionCell
        let alignment = STableItemAlignment.leading
        cell.customView.alignment = alignment
        let bubbleView = cell.customView.customView.customView
        let controller = TextMessageController(text: "Typing...",
                                               type: .incoming,
                                               bubbleController: buildTextBubbleController(bubbleView: bubbleView, messageType: .incoming, bubbleType: .tailed))
        bubbleView.customView.setup(with: controller)
        controller.view = bubbleView.customView
        cell.customView.accessoryView?.isHiddenSafe = true
        cell.delegate = bubbleView.customView

        return cell
    }

    private func createGroupTitle(collectionView: UICollectionView, indexPath: IndexPath, alignment: STableItemAlignment, title: String) -> TitleCollectionCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TitleCollectionCell.reuseIdentifier, for: indexPath) as! TitleCollectionCell
        cell.customView.text = title
        cell.customView.preferredMaxLayoutWidth = (collectionView.collectionViewLayout as? STableLayout)?.layoutFrame.width ?? collectionView.frame.width
        cell.customView.textColor = .gray
        cell.customView.numberOfLines = 0
        cell.customView.font = .preferredFont(forTextStyle: .caption2)
        cell.contentView.layoutMargins = UIEdgeInsets(top: 2, left: 40, bottom: 2, right: 40)
        return cell
    }

    private func createDateTitle(collectionView: UICollectionView, indexPath: IndexPath, alignment: STableItemAlignment, title: String) -> DateTitleCollectionCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: DateTitleCollectionCell.reuseIdentifier, for: indexPath) as! DateTitleCollectionCell
		 cell.customView.layoutMargins = UIEdgeInsets(top: 6, left: 8, bottom: 6, right: 8)
		 cell.customView.backgroundColor = .init(white: 0.95, alpha: 1)
        cell.customView.customView.preferredMaxLayoutWidth = (collectionView.collectionViewLayout as? STableLayout)?.layoutFrame.width ?? collectionView.frame.width
        cell.customView.customView.text = title
        cell.customView.customView.textColor = .gray
        cell.customView.customView.numberOfLines = 0
        cell.customView.customView.font = .preferredFont(forTextStyle: .caption2)
        cell.contentView.layoutMargins = UIEdgeInsets(top: 4, left: 0, bottom: 4, right: 0)
		 cell.layer.zPosition = 42
        return cell
    }

    private func setupMessageContainerView<CustomView>(_ messageContainerView: MessageContainerView<EditingAccessoryView, CustomView>, messageId: UUID, alignment: STableItemAlignment) {
        messageContainerView.alignment = alignment
        if let accessoryView = messageContainerView.accessoryView {
            editNotifier.add(delegate: accessoryView)
            accessoryView.setIsEditing(editNotifier.isEditing)

            let controller = EditingAccessoryController(messageId: messageId)
            controller.view = accessoryView
            controller.delegate = editingDelegate
            accessoryView.setup(with: controller)
        }
    }

    private func setupCellLayoutView<CustomView>(_ cellView: CellLayoutContainerView<AvatarView, CustomView, StatusView>,
                                                 user: User,
                                                 alignment: STableItemAlignment,
                                                 bubble: Cell.BubbleType,
                                                 status: MessageStatus) {
        cellView.alignment = .bottom
        cellView.leadingView?.isHiddenSafe = !alignment.isIncoming
        cellView.leadingView?.alpha = alignment.isIncoming ? 1 : 0
        cellView.trailingView?.isHiddenSafe = alignment.isIncoming
        cellView.trailingView?.alpha = alignment.isIncoming ? 0 : 1
        cellView.trailingView?.setup(with: status)

        if let avatarView = cellView.leadingView {
            let avatarViewController = AvatarViewController(user: user, bubble: bubble)
            avatarView.setup(with: avatarViewController)
            avatarViewController.view = avatarView
        }
    }

    private func setupMainMessageView<CustomView>(_ cellView: MainContainerView<AvatarView, CustomView, StatusView>,
                                                  user: User,
                                                  alignment: STableItemAlignment,
                                                  bubble: Cell.BubbleType,
                                                  status: MessageStatus) {
        cellView.containerView.alignment = .bottom
        cellView.containerView.leadingView?.isHiddenSafe = !alignment.isIncoming
        cellView.containerView.leadingView?.alpha = alignment.isIncoming ? 1 : 0
        cellView.containerView.trailingView?.isHiddenSafe = alignment.isIncoming
        cellView.containerView.trailingView?.alpha = alignment.isIncoming ? 0 : 1
        cellView.containerView.trailingView?.setup(with: status)
        if let avatarView = cellView.containerView.leadingView {
            let avatarViewController = AvatarViewController(user: user, bubble: bubble)
            avatarView.setup(with: avatarViewController)
            avatarViewController.view = avatarView
        }
    }

    private func setupSwipeHandlingAccessory<CustomView>(_ cellView: MainContainerView<AvatarView, CustomView, StatusView>,
                                                         date: Date,
                                                         accessoryConnectingView: UIView) {
        cellView.accessoryConnectingView = accessoryConnectingView
        cellView.accessoryView.setup(with: DateAccessoryController(date: date))
        cellView.accessorySafeAreaInsets = swipeNotifier.accessorySafeAreaInsets
        cellView.swipeCompletionRate = swipeNotifier.swipeCompletionRate
        swipeNotifier.add(delegate: cellView)
    }

    private func buildTextBubbleController<CustomView>(bubbleView: BezierMaskedView<CustomView>, messageType: MessageType, bubbleType: Cell.BubbleType) -> any BubbleController {
        let textBubbleController = TextBubbleController(bubbleView: bubbleView, type: messageType, bubbleType: bubbleType)
        let bubbleController = BezierBubbleController(bubbleView: bubbleView, controllerProxy: textBubbleController, type: messageType, bubbleType: bubbleType)
        return bubbleController
    }

    private func buildBezierBubbleController<CustomView>(for bubbleView: BezierMaskedView<CustomView>, messageType: MessageType, bubbleType: Cell.BubbleType) -> any BubbleController {
        let contentBubbleController = FullCellContentBubbleController(bubbleView: bubbleView)
        let bubbleController = BezierBubbleController(bubbleView: bubbleView, controllerProxy: contentBubbleController, type: messageType, bubbleType: bubbleType)
        return bubbleController
    }

}

extension DefaultChatCollectionDataSource : UICollectionViewDataSource {

    public func numberOfSections(in collectionView: UICollectionView) -> Int {
        return sections.count
    }

    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return sections[section].cells.count
    }

    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = sections[indexPath.section].cells[indexPath.item]
        switch cell {
        case let .message(message, bubbleType: bubbleType):
            switch message.data {
            case let .text(text):
                let cell = createTextCell(collectionView: collectionView, messageId: message.id, indexPath: indexPath, text: text, date: message.date, alignment: cell.alignment, user: message.owner, bubbleType: bubbleType, status: message.status, messageType: message.type)
                return cell
            case let .url(url, isLocallyStored: _):
                if #available(iOS 13.0, *) {
                    return createURLCell(collectionView: collectionView, messageId: message.id, indexPath: indexPath, url: url, date: message.date, alignment: cell.alignment, user: message.owner, bubbleType: bubbleType, status: message.status, messageType: message.type)
                } else {
                    return createTextCell(collectionView: collectionView, messageId: message.id, indexPath: indexPath, text: url.absoluteString, date: message.date, alignment: cell.alignment, user: message.owner, bubbleType: bubbleType, status: message.status, messageType: message.type)
                }
            case let .image(source, isLocallyStored: _):
                let cell = createImageCell(collectionView: collectionView, messageId: message.id, indexPath: indexPath, alignment: cell.alignment, user: message.owner, source: source, date: message.date, bubbleType: bubbleType, status: message.status, messageType: message.type)
                return cell
            }
        case let .messageGroup(group):
            let cell = createGroupTitle(collectionView: collectionView, indexPath: indexPath, alignment: cell.alignment, title: group.title)
            return cell
        case let .date(group):
            let cell = createDateTitle(collectionView: collectionView, indexPath: indexPath, alignment: cell.alignment, title: group.value)
            return cell
        case .typingIndicator:
            return createTypingIndicatorCell(collectionView: collectionView, indexPath: indexPath)
        default:
            fatalError()
        }
    }

    public func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        switch kind {
        case UICollectionView.elementKindSectionHeader:
            let view = collectionView.dequeueReusableSupplementaryView(ofKind: kind,
                                                                       withReuseIdentifier: TextTitleView.reuseIdentifier,
                                                                       for: indexPath) as! TextTitleView
            view.customView.text = sections[indexPath.section].title
            view.customView.preferredMaxLayoutWidth = 300
            view.customView.textColor = .lightGray
            view.customView.numberOfLines = 0
            view.customView.font = .preferredFont(forTextStyle: .caption2)
            return view
        case UICollectionView.elementKindSectionFooter:
            let view = collectionView.dequeueReusableSupplementaryView(ofKind: kind,
                                                                       withReuseIdentifier: TextTitleView.reuseIdentifier,
                                                                       for: indexPath) as! TextTitleView
            view.customView.text = "Made with STableLayout"
            view.customView.preferredMaxLayoutWidth = 300
            view.customView.textColor = .lightGray
            view.customView.numberOfLines = 0
            view.customView.font = .preferredFont(forTextStyle: .caption2)
            return view
        default:
            fatalError()
        }
    }

}

extension DefaultChatCollectionDataSource : STableLayoutDelegate {

    public func shouldPresentHeader(_ sTableLayout: STableLayout, at sectionIndex: Int) -> Bool {
        return true
    }

    public func shouldPresentFooter(_ sTableLayout: STableLayout, at sectionIndex: Int) -> Bool {
        return true
    }
	
	func pinningForItem(_ sTableLayout: STableLayout, of kind: ItemKind, at indexPath: IndexPath) -> STableItemPinning {
		switch kind {
			case .cell:
				let item = sections[indexPath.section].cells[indexPath.item]
				switch item {
					case .message:         return .none
					case .date:            return .top
					case .typingIndicator: return .none
					case .messageGroup:    return .none
					case .deliveryStatus:  return .none
				}
				
			case .footer, .header:
				return .none
		}
	}

    public func sizeForItem(_ sTableLayout: STableLayout, of kind: ItemKind, at indexPath: IndexPath) -> ItemSize {
        switch kind {
        case .cell:
            let item = sections[indexPath.section].cells[indexPath.item]
            switch item {
            case let .message(message, bubbleType: _):
                switch message.data {
                case .text:
                    return .estimated(CGSize(width: sTableLayout.layoutFrame.width, height: 36))
                case let .image(_, isLocallyStored: isDownloaded):
                    return .estimated(CGSize(width: sTableLayout.layoutFrame.width, height: isDownloaded ? 120 : 80))
                case let .url(_, isLocallyStored: isDownloaded):
                    return .estimated(CGSize(width: sTableLayout.layoutFrame.width, height: isDownloaded ? 60 : 36))
                }
            case .date:
                return .estimated(CGSize(width: sTableLayout.layoutFrame.width, height: 18))
            case .typingIndicator:
                return .estimated(CGSize(width: 60, height: 36))
            case .messageGroup:
                return .estimated(CGSize(width: min(85, sTableLayout.layoutFrame.width / 3), height: 18))
            case .deliveryStatus:
                return .estimated(CGSize(width: sTableLayout.layoutFrame.width, height: 18))
            }
        case .footer, .header:
            return .auto
        }
    }

    public func alignmentForItem(_ sTableLayout: STableLayout, of kind: ItemKind, at indexPath: IndexPath) -> STableItemAlignment {
        switch kind {
        case .header:
            return .center
        case .cell:
            let item = sections[indexPath.section].cells[indexPath.item]
            switch item {
            case .date:
                return .center
            case .message, .deliveryStatus:
                return .fullWidth
            case .messageGroup, .typingIndicator:
                return .leading
            }
        case .footer:
            return .trailing
        }
    }

    public func initialLayoutAttributesForInsertedItem(_ sTableLayout: STableLayout, of kind: ItemKind, at indexPath: IndexPath, modifying originalAttributes: STableLayoutAttributes, on state: InitialAttributesRequestType) {
        originalAttributes.alpha = 0
        guard state == .invalidation,
              kind == .cell else {
            return
        }
        switch sections[indexPath.section].cells[indexPath.item] {
        // Uncomment to see the effect
//        case .messageGroup:
//            originalAttributes.center.x -= originalAttributes.frame.width
//        case let .message(message, bubbleType: _):
//            originalAttributes.transform = .init(scaleX: 0.9, y: 0.9)
//            originalAttributes.transform = originalAttributes.transform.concatenating(.init(rotationAngle: message.type == .incoming ? -0.05 : 0.05))
//            originalAttributes.center.x += (message.type == .incoming ? -20 : 20)
        case .typingIndicator:
            originalAttributes.transform = .init(scaleX: 0.1, y: 0.1)
            originalAttributes.center.x -= originalAttributes.bounds.width / 5
        default:
            break
        }
    }

    public func finalLayoutAttributesForDeletedItem(_ sTableLayout: STableLayout, of kind: ItemKind, at indexPath: IndexPath, modifying originalAttributes: STableLayoutAttributes) {
        originalAttributes.alpha = 0
        guard kind == .cell else {
            return
        }
        switch oldSections[indexPath.section].cells[indexPath.item] {
        // Uncomment to see the effect
//        case .messageGroup:
//            originalAttributes.center.x -= originalAttributes.frame.width
//        case let .message(message, bubbleType: _):
//            originalAttributes.transform = .init(scaleX: 0.9, y: 0.9)
//            originalAttributes.transform = originalAttributes.transform.concatenating(.init(rotationAngle: message.type == .incoming ? -0.05 : 0.05))
//            originalAttributes.center.x += (message.type == .incoming ? -20 : 20)
        case .typingIndicator:
            originalAttributes.transform = .init(scaleX: 0.1, y: 0.1)
            originalAttributes.center.x -= originalAttributes.bounds.width / 5
        default:
            break
        }
    }

}
