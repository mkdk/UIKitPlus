public protocol Supplementable: AnyObject {}

extension Supplementable {
    public static var reuseIdentifier: String { String(describing: self) }
}

public protocol Cellable: AnyObject {}

extension Cellable {
    public static var reuseIdentifier: String { String(describing: self) }
}
