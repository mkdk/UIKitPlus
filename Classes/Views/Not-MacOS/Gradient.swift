//
//  Created by Антон Лобанов on 01.09.2021.
//

#if !os(macOS)
import UIKit

public struct UGradientConfiguration {
	public var locations: [NSNumber]
	public var colors: [UIColor]
	public var startPoint: CGPoint?
	public var endPoint: CGPoint?
	/// Entry bounds
	public var boundsMakeHandler: (CGRect) -> CGRect
	/// Entry frame
	public var positionMakeHandler: ((CGRect) -> CGPoint)?
	public var transform: CATransform3D?

	public let uuid = UUID()

	public init(
		locations: [NSNumber],
		colors: [UIColor],
		startPoint: CGPoint? = nil,
		endPoint: CGPoint? = nil,
		boundsMakeHandler: @escaping (CGRect) -> CGRect = { $0 },
		positionMakeHandler: ((CGRect) -> CGPoint)? = nil,
		transform: CATransform3D? = nil
	) {
		self.locations = locations
		self.colors = colors
		self.startPoint = startPoint
		self.endPoint = endPoint
		self.boundsMakeHandler = boundsMakeHandler
		self.positionMakeHandler = positionMakeHandler
		self.transform = transform
	}
}

extension UGradientConfiguration: Hashable {
	public static func == (lhs: UGradientConfiguration, rhs: UGradientConfiguration) -> Bool {
		lhs.uuid == rhs.uuid
	}

	public func hash(into hasher: inout Hasher) {
		hasher.combine(self.uuid)
	}
}

public final class UGradient<T: UIView>: UWrapperView<T> {
	private var config = UGradientConfiguration(locations: [], colors: [])

	public override func layoutSubviews() {
		super.layoutSubviews()
		self.updateGradient()
	}

	@discardableResult
	public func config(_ value: UGradientConfiguration) -> Self {
		self.config = value
		self.updateGradient()
		return self
	}

	@discardableResult
	public func config(_ value: State<UGradientConfiguration>) -> Self {
		value.listen { [weak self] in self?.config($0) }
		return self
	}

	@discardableResult
	public func locations(_ value: [NSNumber]) -> Self {
		self.config.locations = value
		return self
	}

	@discardableResult
	public func colors(_ value: [UIColor]) -> Self {
		self.config.colors = value
		return self
	}

	@discardableResult
	public func points(_ start: CGPoint, end: CGPoint) -> Self {
		self.config.startPoint = start
		self.config.endPoint = end
		return self
	}

	@discardableResult
	public func bounds(_ handler: @escaping (CGRect) -> CGRect) -> Self {
		self.config.boundsMakeHandler = handler
		return self
	}

	@discardableResult
	public func position(_ handler: @escaping (CGRect) -> CGPoint) -> Self {
		self.config.positionMakeHandler = handler
		return self
	}

	@discardableResult
	public func transform(_ value: CATransform3D) -> Self {
		self.config.transform = value
		return self
	}

	private func updateGradient() {
		self.backgroundColor = .clear
		self.layer.sublayers?.filter { $0.name == "gradient_layer" }.forEach { $0.removeFromSuperlayer() }

		let gradientLayer = CAGradientLayer()
		gradientLayer.locations = self.config.locations

		if let startPoint = self.config.startPoint, let endPoint = self.config.endPoint {
			gradientLayer.startPoint = startPoint
			gradientLayer.endPoint = endPoint
		}

		gradientLayer.colors = self.config.colors.map { $0.cgColor }

		if let transform = self.config.transform {
			gradientLayer.transform = transform
		}

		gradientLayer.frame = self.config.boundsMakeHandler(self.bounds)

		if let positionMakeHandler = self.config.positionMakeHandler {
			gradientLayer.position = positionMakeHandler(self.frame)
		}

		gradientLayer.name = "gradient_layer"

		self.layer.masksToBounds = false
		self.layer.insertSublayer(gradientLayer, at: 0)
	}
}
#endif
