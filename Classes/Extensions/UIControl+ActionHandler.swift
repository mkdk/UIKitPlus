#if !os(macOS)
import UIKit

extension UIControl {
	struct Storage {
		static var actions: [Int: (() -> Void)] = [:]
	}

	private func actionHandler(action: (() -> Void)? = nil) {
        if let action = action {
            Storage.actions[hashValue] = action
        } else {
            Storage.actions[hashValue]?()
        }
    }
    
    @objc func triggerActionHandler() {
        actionHandler()
    }
    
    func actionHandler(controlEvents control: UIControl.Event, forAction action: @escaping () -> Void) {
        actionHandler(action: action)
        addTarget(self, action: #selector(triggerActionHandler), for: control)
    }
}
#endif
