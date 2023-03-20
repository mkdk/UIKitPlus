//
//  Created by Антон Лобанов on 23.05.2021.
//

public protocol AnySectionMap {
    var count: Int { get }
    func allItems() -> [USectionItemable]
    func subscribeToChanges(_ handler: @escaping () -> Void)
}

public final class USectionMap<Item: Hashable> {
    public typealias BuildHandler = (Int, Item) -> [USectionItemable]
    public typealias BuildSimpleHandler = () -> [USectionItemable]
    
    let items: State<[Item]>
    let block: BuildHandler
    
    public init (_ items: [Item], @CollectionBuilder<USectionItemable> block: @escaping BuildHandler) {
        self.items = State(wrappedValue: items)
        self.block = block
    }
    
    public init (_ items: State<[Item]>, @CollectionBuilder<USectionItemable> block: @escaping BuildHandler) {
        self.items = items
        self.block = block
    }

    // ...

    public init (_ items: [Item], @CollectionBuilder<USectionItemable> block: @escaping BuildSimpleHandler) {
        self.items = State(wrappedValue: items)
        self.block = { _, _ in
            block()
        }
    }

    public init (_ items: State<[Item]>, @CollectionBuilder<USectionItemable> block: @escaping BuildSimpleHandler) {
        self.items = items
        self.block = { _, _ in
            block()
        }
    }

    // ...
    
    public init<T>(
        _ first: State<T>,
        @CollectionBuilder<USectionItemable> block: @escaping (T) -> [USectionItemable]
    ) where Item == Int {
        let states: [AnyState] = [first]
        self.items = states.map { [0] }
        self.block = { _, _ in
            block(first.wrappedValue)
        }
    }

    public init<T, V>(
        _ first: State<T>,
        _ second: State<V>,
        @CollectionBuilder<USectionItemable> block: @escaping (T, V) -> [USectionItemable]
    ) where Item == Int {
        let states: [AnyState] = [first, second]
        self.items = states.map { [0] }
        self.block = { _, _ in
            block(first.wrappedValue, second.wrappedValue)
        }
    }

    public init<T, V, A>(
        _ first: State<T>,
        _ second: State<V>,
        _ third: State<A>,
        @CollectionBuilder<USectionItemable> block: @escaping (T, V, A) -> [USectionItemable]
    ) where Item == Int {
        let states: [AnyState] = [first, second, third]
        self.items = states.map { [0] }
        self.block = { _, _ in
            block(first.wrappedValue, second.wrappedValue, third.wrappedValue)
        }
    }
}

extension USectionMap: AnySectionMap {
    public var count: Int {
        self.items.wrappedValue.count
    }
    
    public func allItems() -> [USectionItemable] {
        self.items.wrappedValue.enumerated().map {
            MultipleSectionItem(self.block($0.offset, $0.element))
        }
    }
    
    public func subscribeToChanges(_ handler: @escaping () -> Void) {
        self.items.removeAllListeners()
        self.items.listen { handler() }
    }
}

extension USectionMap: USectionItemable {
    public var sectionItem: USectionItem { .map(self) }
}
