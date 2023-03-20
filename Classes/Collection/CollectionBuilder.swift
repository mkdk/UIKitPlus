//
//  Created by Антон Лобанов on 23.05.2021.
//

@_functionBuilder public enum CollectionBuilder<Element> {
    public typealias Expression = Element
    public typealias Component = [Element]

    public static func buildBlock(_ children: Component...) -> Component { children.flatMap { $0 } }
    public static func buildBlock(_ component: Component) -> Component { component }

    public static func buildExpression(_ expression: Expression) -> Component { [expression] }
    public static func buildExpression(_ expression: Expression?) -> Component { expression.map { [$0] } ?? [] }

    public static func buildEither(first component: Component) -> Component { component }
    public static func buildEither(second component: Component) -> Component { component }

    public static func buildEither(first expression: Expression) -> Component { [expression] }
    public static func buildEither(second expression: Expression) -> Component { [expression] }

    public static func buildOptional(_ component: Component?) -> Component { component ?? [] }
}
