#if !os(macOS)
import UIKit

public extension UIView {
	@discardableResult
	func zPosition(_ value: CGFloat) -> Self {
		self.layer.zPosition = value
		return self
	}
}

#endif
