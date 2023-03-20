//
//  Created by Антон Лобанов on 23.09.2021.
//

#if !os(macOS)
public protocol IPresentable {
	var viewControllerToPresent: UIViewController { get }
}

public extension IPresentable {
	func wrap(
		_ style: NavigationControllerStyle = .default
	) -> NavigationController<UIViewController> {
		NavigationController(self.viewControllerToPresent).style(style)
	}
}

extension UIViewController: IPresentable {
	public var viewControllerToPresent: UIViewController {
		self
	}
}
#endif
