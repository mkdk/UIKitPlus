public protocol Supplementable: class {}

extension Supplementable {
    public static var reuseIdentifier: String { String(describing: self) }
}

public protocol Cellable: class {}

extension Cellable {
    public static var reuseIdentifier: String { String(describing: self) }
}
