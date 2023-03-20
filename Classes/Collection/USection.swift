//
//  Created by Антон Лобанов on 23.05.2021.
//

import UIKit

public enum USectionItem {
    case single(USection)
    case map(AnySectionMap)
    case multiple([USectionItemable])
}

public protocol USectionItemable {
    var sectionItem: USectionItem { get }
}

public struct MultipleSectionItem: USectionItemable {
    public var sectionItem: USectionItem { .multiple(self.items) }
    public let items: [USectionItemable]

    public init(_ items: [USectionItemable]) {
        self.items = items
    }
}

extension Array: USectionItemable where Element == USection {
    public var sectionItem: USectionItem { .multiple(self) }
}

// MARK: - USectionBodyItem

public enum USectionBodyItem {
    case supplementary(USupplementable)
    case item(UItemable)
    case map(AnyItemMap)
    case multiple([USectionBodyItemable])
}

public protocol USectionBodyItemable {
    var identifier: AnyHashable { get }
    var sectionBodyItem: USectionBodyItem { get }
}

public struct MultipleSectionBodyItem: USectionBodyItemable {
    public var identifier: AnyHashable { self.items.map { $0.identifier } }
    public var sectionBodyItem: USectionBodyItem { .multiple(self.items) }
    public let items: [USectionBodyItemable]

    public init(_ items: [USectionBodyItemable]) {
        self.items = items
    }
}

// MARK: - USupplementable

public protocol USupplementable: USectionBodyItemable {
    var viewClass: Supplementable.Type { get }
    func generate(collectionView: UICollectionView, kind: String, for indexPath: IndexPath) -> UICollectionReusableView
    func size(by original: CGSize, direction: UICollectionView.ScrollDirection) -> CGSize
}

extension USupplementable {
    public var sectionBodyItem: USectionBodyItem { .supplementary(self) }
}

public protocol USupplementableBuilder {
    associatedtype View: UICollectionReusableView & Supplementable
    func build(_ view: View)
}

public extension USupplementable where Self: USupplementableBuilder {
    var viewClass: Supplementable.Type {
        View.self
    }

	func size(by original: CGSize, direction: UICollectionView.ScrollDirection) -> CGSize {
		self.systemLayoutSize(by: original, direction: direction)
	}

    func generate(collectionView: UICollectionView, kind: String, for indexPath: IndexPath) -> UICollectionReusableView {
        let view = collectionView.dequeueReusableSupplementaryView(View.self, ofKind: kind, for: indexPath)
        self.build(view)
        return view
    }

	func systemLayoutSize(by original: CGSize, direction: UICollectionView.ScrollDirection) -> CGSize {
		if let cachedSize = UItemSizeCache.shared.size(self.viewClass.reuseIdentifier, identifier: self.identifier) {
			return cachedSize
		}

		let isDynamicHeight = (direction == .vertical)
		let width = isDynamicHeight ? original.width : .greatestFiniteMagnitude
		let height = isDynamicHeight ? .greatestFiniteMagnitude : original.height

		let view: View
		if let cachedView = UItemSizeCache.shared.supplementables[self.viewClass.reuseIdentifier] as? View {
			view = cachedView
		}
		else {
			let newView = View(frame: .init(origin: .zero, size: .init(width: width, height: height)))
			UItemSizeCache.shared.supplementables[self.viewClass.reuseIdentifier] = newView
			view = newView
		}

		self.build(view)

		let size = view.systemLayoutSizeFitting(
			.init(width: isDynamicHeight ? width : 0, height: isDynamicHeight ? 0 : height),
			withHorizontalFittingPriority: isDynamicHeight ? .required : .fittingSizeLevel,
			verticalFittingPriority: isDynamicHeight ? .fittingSizeLevel : .required
		)

		UItemSizeCache.shared.update(self.viewClass.reuseIdentifier, identifier: self.identifier, size: size)

		return size
	}
}

// MARK: - UItemable

public final class UItemSizeCache {
	public static let shared = UItemSizeCache()

	var cells: [String: UICollectionViewCell] = [:]
	var supplementables: [String: UIView] = [:]

	private var sizes: [String: [AnyHashable: CGSize]] = [:]

	public func size<Identifier: Hashable>(_ type: String, identifier: Identifier) -> CGSize? {
		self.sizes[type]?[identifier]
	}

	public func update<Identifier: Hashable>(_ type: String, identifier: Identifier, size: CGSize) {
		if self.sizes[type] == nil {
			self.sizes[type] = [identifier: size]
		}
		else {
			self.sizes[type]?[identifier] = size
		}
	}

	public func clearAll() {
		self.sizes = [:]
		self.cells = [:]
		self.supplementables = [:]
	}

	public func clear<Cell: Cellable>(for type: Cell.Type) {
		self.sizes[type.reuseIdentifier] = [:]
		self.cells[type.reuseIdentifier] = nil
	}
}

public protocol UItemable: USectionBodyItemable {
    var cellClass: Cellable.Type { get }

	func generate(collectionView: UICollectionView, for indexPath: IndexPath) -> UICollectionViewCell
    func size(by original: CGSize, direction: UICollectionView.ScrollDirection) -> CGSize
}

extension UItemable {
    public var sectionBodyItem: USectionBodyItem { .item(self) }
}

public protocol UItemableBuilder {
    associatedtype Cell: UICollectionViewCell & Cellable
    func build(_ cell: Cell)
}

public extension UItemable where Self: UItemableBuilder {
    var cellClass: Cellable.Type {
        Cell.self
    }

	func size(by original: CGSize, direction: UICollectionView.ScrollDirection) -> CGSize {
		self.systemLayoutSize(by: original, direction: direction)
	}
    
    func generate(collectionView: UICollectionView, for indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(with: Cell.self, for: indexPath)
        self.build(cell)
        return cell
    }

	func systemLayoutSize(by original: CGSize, direction: UICollectionView.ScrollDirection) -> CGSize {
		if let cachedSize = UItemSizeCache.shared.size(self.cellClass.reuseIdentifier, identifier: self.identifier) {
			return cachedSize
		}

		let isDynamicHeight = (direction == .vertical)
		let width = isDynamicHeight ? original.width : .greatestFiniteMagnitude
		let height = isDynamicHeight ? .greatestFiniteMagnitude : original.height

		let cell: Cell
		if let cachedCell = UItemSizeCache.shared.cells[self.cellClass.reuseIdentifier] as? Cell {
			cell = cachedCell
		}
		else {
			let newCell = Cell(frame: .init(origin: .zero, size: .init(width: width, height: height)))
			UItemSizeCache.shared.cells[self.cellClass.reuseIdentifier] = newCell
			cell = newCell
		}

		self.build(cell)

		let size = cell.systemLayoutSizeFitting(
			.init(width: isDynamicHeight ? width : 0, height: isDynamicHeight ? 0 : height),
			withHorizontalFittingPriority: isDynamicHeight ? .required : .fittingSizeLevel,
			verticalFittingPriority: isDynamicHeight ? .fittingSizeLevel : .required
		)

		UItemSizeCache.shared.update(self.cellClass.reuseIdentifier, identifier: self.identifier, size: size)

		return size
	}
}

public protocol UItemableDelegate {
    func willDisplay()
    func didSelect()
    func didDeselect()
    func didHighlight()
    func didUnhighlight()
}

public extension UItemableDelegate {
    func willDisplay() {}
    func didSelect() {}
    func didDeselect() {}
    func didHighlight() {}
    func didUnhighlight() {}
}

// MARK: - USection

public struct USection {
	public typealias Identifier = AnyHashable

    let identifier: Identifier
    let body: [USectionBodyItemable]
}

extension USection {
    public init(_ identifier: Identifier, @CollectionBuilder<USectionBodyItemable> block: () -> [USectionBodyItemable]) {
        self.identifier = identifier
        self.body = block()
    }
    
    var header: USupplementable? {
        guard case let .supplementary(item) = self.body.first?.sectionBodyItem else { return nil }
        return item
    }
    
    var footer: USupplementable? {
        guard case let .supplementary(item) = self.body.last?.sectionBodyItem else { return nil }
        return item
    }
    
    var items: [UItemable] {
        self.body
            .map { self.unwrapItems($0) }
            .flatMap { $0 }
    }
    
    private func unwrapItems(_ item: USectionBodyItemable) -> [UItemable] {
        switch item.sectionBodyItem {
        case let .item(item): return [item]
        case let .map(mp): return mp.allItems().map { self.unwrapItems($0) }.flatMap { $0 }
        case let .multiple(items): return items.map { self.unwrapItems($0) }.flatMap { $0 }
        default: return []
        }
    }
}

extension USection: USectionItemable {
    public var sectionItem: USectionItem { .single(self) }
}

// MARK: - Empty

public struct EmptySection: USectionItemable {
    public var sectionItem: USectionItem { .single(self.section) }
    private let section = USection(UUID().uuidString, block: {})

    public init() {}
}

public struct EmptyItem: USectionBodyItemable {
    public let identifier: AnyHashable = UUID().uuidString
    public var sectionBodyItem: USectionBodyItem { .multiple([]) }

    public init() {}
}


