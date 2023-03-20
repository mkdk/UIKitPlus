#if !os(macOS)
import UIKit

public extension State where Value == CGFloat {
	static var zero: UState<CGFloat> {
		.init(wrappedValue: 0)
	}

	static func value(_ value: CGFloat) -> UState<CGFloat> {
		.init(wrappedValue: value)
	}
}

#endif
