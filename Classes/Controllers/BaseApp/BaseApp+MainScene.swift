//
//  BaseApp+MainScene.swift
//  UIKit-Plus
//
//  Created by Mihael Isaev on 11.09.2020.
//

#if !os(macOS)
import UIKit

extension UIViewController {
    public func attach(to window: UIWindow?) {
        window?.rootViewController = self
        window?.makeKeyAndVisible()
    }
    
    @available(iOS 13.0, *)
    @discardableResult
    public func attach(to scene: UIScene) -> UIWindow? {
        guard let windowScene = scene as? UIWindowScene else { return nil }
        let window = UIWindow(windowScene: windowScene)
        window.rootViewController = self
        window.makeKeyAndVisible()
        return window
    }
}

extension BaseApp {
    public typealias RootSimpleCompletion = () -> Void
    public typealias RootBeforeTransition = (UIViewController) -> Void
    
    public class MainScene: _AnyScene, AppBuilderContent {
		public var topViewController: UIViewController {
			self.current.topViewController
		}

        public var appBuilderContent: AppBuilderItem { .mainScene(self) }
        
        public var persistentIdentifier: String = UUID().uuidString
        public var stateRestorationActivity: NSUserActivity?
        public var userInfo: [String : Any]?
        
        var _onConnect: ((UIWindow?, Set<NSUserActivity>) -> Void)?
        var _onDisconnect: ((UIWindow?) -> Void)?
        var _onDestroy: ((UIWindow?) -> Void)?
        var _onBecomeActive: ((UIWindow?) -> Void)?
        var _onWillResignActive: ((UIWindow?) -> Void)?
        var _onWillEnterForeground: ((UIWindow?) -> Void)?
        var _onDidEnterBackground: ((UIWindow?) -> Void)?
        
        class MainSceneViewController: ViewController {
            #if !os(tvOS)
            open override var preferredStatusBarStyle: UIStatusBarStyle { currentHandler().preferredStatusBarStyle }
            #endif
            
            let currentHandler: () -> UIViewController
            
            init (_ handler: @escaping () -> UIViewController) {
                currentHandler = handler
                super.init()
            }
            
            public required init?(coder aDecoder: NSCoder) {
                fatalError("init(coder:) has not been implemented")
            }
        }
        
        public lazy var viewController: ViewController = MainSceneViewController { self.current }
        
        @UState public internal(set) var currentScreen: SceneScreenType = .splash
        public internal(set) lazy var current: UIViewController = NotImplementedViewController("nothing")

        var screens: [SceneScreenType: () -> UIViewController] = [:] // NotImplementedViewController("splashScreen")
        
        /// By default shows `splashScreen`
        public init (_ initialScreen: SceneScreenType = .splash) {
            currentScreen = initialScreen
        }
        
        public init (_ handler: () -> SceneScreenType) {
            currentScreen = handler()
        }
        
        public init (_ viewController: UIViewController) {
            let type: SceneScreenType = "custom"
            currentScreen = type
            screens[type] = { viewController }
        }
        
        public init (_ handler: @escaping () -> UIViewController) {
            let type: SceneScreenType = "custom"
            currentScreen = type
            screens[type] = handler
        }
        
        /// should be called from BaseApp on didFinishLaunching
        func initialize() {
            current = screens[currentScreen]?() ?? NotImplementedViewController(currentScreen.description)
            viewController.addChild(current)
            current.view.frame = viewController.view.bounds
            viewController.view.body { current.view }
            current.didMove(toParent: viewController)
        }
        
        public func splashScreen(_ handler: @escaping () -> UIViewController) -> Self {
            screens[.splash] = handler
            return self
        }
        
        public func loginScreen(_ handler: @escaping () -> UIViewController) -> Self {
            screens[.login] = handler
            return self
        }
        
        public func mainScreen(_ handler: @escaping () -> UIViewController) -> Self {
            screens[.main] = handler
            return self
        }
        
        public func onboardingScreen(_ handler: @escaping () -> UIViewController) -> Self {
            screens[.onboarding] = handler
            return self
        }
        
        public func custom(_ type: SceneScreenType, _ handler: @escaping () -> UIViewController) -> Self {
            screens[type] = handler
            return self
        }
        
        open func `switch`(
			to type: SceneScreenType,
			animation: RootTransitionAnimation,
			beforeTransition: RootBeforeTransition? = nil,
			completion: RootSimpleCompletion? = nil
		) {
            if currentScreen == type {
                print("⚠️ Don't show \(type) twice")
                return
            }
			let vc = nextViewController(for: type)
            currentScreen = type
            beforeTransition?(vc)
            switch animation {
            case .none:
                replaceWithoutAnimation(vc)
                completion?()
            case .dismiss:
				animateDismissTransition(to: vc, completion: completion)
            case .fade:
                animateFadeTransition(to: vc, completion: completion)
            }
        }
        
        public func `switch`(
			to: UIViewController,
			as: SceneScreenType,
			animation: RootTransitionAnimation,
			beforeTransition: RootBeforeTransition? = nil,
			completion: RootSimpleCompletion? = nil
		) {
            currentScreen = `as`
            switch animation {
            case .none:
                beforeTransition?(to)
                replaceWithoutAnimation(to)
                completion?()
            case .dismiss:
                beforeTransition?(to)
                animateDismissTransition(to: to) {
                    completion?()
                }
            case .fade:
                beforeTransition?(to)
                animateFadeTransition(to: to) {
                    completion?()
                }
            }
        }

		public func perform(
			_ transitions: [RootTransition],
			animated: Bool = true,
			completion: @escaping () -> Void = {}
		) {
			guard transitions.isEmpty == false else { return completion() }

			var transitions = transitions

			self.perform(transitions.removeFirst(), animated: animated) { [weak self] in
				self?.perform(transitions, animated: animated, completion: completion)
			}
		}

		public func perform(
			_ transition: RootTransition,
			animated: Bool = true,
			completion: @escaping () -> Void = {}
		) {
			switch transition {
			case let .setRoot(presetable, screen, animation):
				self.switch(
					to: presetable.viewControllerToPresent,
					as: SceneScreenType(type: screen),
					animation: animation,
					beforeTransition: nil,
					completion: completion
				)
			case let .setTab(item):
				guard let tabBarController = self.current as? UITabBarController else {
					print("⚠️ Can't select \(item) current controller must be UITabBarController")
					return
				}
				tabBarController.selectedIndex = item
				completion()
			case let .push(presentable):
				self.topViewController.navigationController?.pushViewController(
					presentable.viewControllerToPresent,
					animated: animated,
					completion: completion
				)
			case .pop:
				self.topViewController.navigationController?.popViewController(
					animated: animated,
					completion: completion
				)
			case .popToRoot:
				self.topViewController.navigationController?.popToRootViewController(
					animated: animated,
					completion: completion
				)
			case let .present(presentable):
				self.topViewController.present(
					presentable.viewControllerToPresent,
					animated: animated,
					completion: completion
				)
			case .dismiss:
				self.topViewController.dismiss(
					animated: animated,
					completion: completion
				)
			case .dismissOnRoot:
				self.viewController.dismiss(animated: animated, completion: completion)
			}
		}
        
        private func replaceWithoutAnimation(_ new: UIViewController) {
            viewController.addChild(new)
            new.view.frame = viewController.view.bounds
            viewController.view.addSubview(new.view)
            new.didMove(toParent: viewController)

            current.willMove(toParent: nil)
            current.view.removeFromSuperview()
            current.removeFromParent()

            current = new
            #if !os(tvOS)
            viewController.setNeedsStatusBarAppearanceUpdate()
            #endif
        }
        
        private func animateFadeTransition(to new: UIViewController, completion: RootSimpleCompletion? = nil) {
            current.willMove(toParent: nil)
            new.view.frame = viewController.view.bounds
            viewController.addChild(new)
            new.willMove(toParent: viewController)
            viewController.transition(from: current, to: new, duration: 0.3, options: [.transitionCrossDissolve, .curveEaseOut], animations: {}) { completed in
                self.current.removeFromParent()
                new.didMove(toParent: self.viewController)
                self.current = new
                completion?()
                #if !os(tvOS)
                self.viewController.setNeedsStatusBarAppearanceUpdate()
                #endif
            }
        }
        
        private func animateDismissTransition(to new: UIViewController, completion: RootSimpleCompletion? = nil) {
            let initialFrame = CGRect(x: -viewController.view.bounds.width, y: 0, width: viewController.view.bounds.width, height: viewController.view.bounds.height)
            current.willMove(toParent: nil)
            viewController.addChild(new)
            new.view.frame = initialFrame
            viewController.transition(from: current, to: new, duration: 0.3, options: [], animations: {
                new.view.frame = self.viewController.view.bounds
            }) { completed in
                self.current.removeFromParent()
                new.didMove(toParent: self.viewController)
                self.current = new
                completion?()
                #if !os(tvOS)
                self.viewController.setNeedsStatusBarAppearanceUpdate()
                #endif
            }
        }
        
        func nextViewController(for type: SceneScreenType) -> UIViewController {
			return screens[type]?() ?? NotImplementedViewController(type.description)
        }
    }
}

private extension UIViewController {
	var topViewController: UIViewController {
		self.findTopViewController(self)
	}

	private func findTopViewController(_ controller: UIViewController) -> UIViewController {
		if let presented = controller.presentedViewController {
			return self.findTopViewController(presented)
		}

		if let tabController = controller as? UITabBarController, let selected = tabController.selectedViewController {
			return self.findTopViewController(selected)
		}

		if let navigationController = controller as? UINavigationController,
		   let lastViewController = navigationController.visibleViewController
		{
			return self.findTopViewController(lastViewController)
		}

		if let pageController = controller as? UIPageViewController,
		   let lastViewController = pageController.viewControllers?.first
		{
			return self.findTopViewController(lastViewController)
		}

		return controller
	}
}

private extension UINavigationController {
	func pushViewController(_ viewController: UIViewController, animated: Bool, completion: @escaping () -> Void) {
		self.pushViewController(viewController, animated: animated)

		guard animated, let coordinator = self.transitionCoordinator else {
			DispatchQueue.main.async { completion() }
			return
		}

		coordinator.animate(alongsideTransition: nil) { _ in completion() }
	}

	func popViewController(animated: Bool, completion: @escaping () -> Void) {
		self.popViewController(animated: animated)

		guard animated, let coordinator = self.transitionCoordinator else {
			DispatchQueue.main.async { completion() }
			return
		}

		coordinator.animate(alongsideTransition: nil) { _ in completion() }
	}

	func popToViewController(_ viewController: UIViewController, animated: Bool, completion: @escaping () -> Void) {
		self.popToViewController(viewController, animated: animated)

		guard animated, let coordinator = self.transitionCoordinator else {
			DispatchQueue.main.async { completion() }
			return
		}

		coordinator.animate(alongsideTransition: nil) { _ in completion() }
	}

	func popToRootViewController(animated: Bool, completion: @escaping () -> Void) {
		self.popToRootViewController(animated: animated)

		guard animated, let coordinator = self.transitionCoordinator else {
			DispatchQueue.main.async { completion() }
			return
		}

		coordinator.animate(alongsideTransition: nil) { _ in completion() }
	}
}
#endif
