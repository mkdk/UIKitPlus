//
//  Created by Антон Лобанов on 25.02.2021.
//

import UIKit

public struct UShadowConfiguration {
	public var shadowColor: UIColor
	public var offset: CGSize
	public var opacity: Float
	public var shadowRadius: CGFloat
	public var cornerRadius: CGFloat
	public var corners: UIRectCorner
	public var fillColor: UIColor

	public init(
		shadowColor: UIColor = UIColor.black.withAlphaComponent(0.15),
		offset: CGSize = .init(width: 0, height: 2),
		opacity: Float = 1,
		shadowRadius: CGFloat = 20,
		cornerRadius: CGFloat = 0,
		corners: UIRectCorner = .allCorners,
		fillColor: UIColor = .clear
	) {
		self.shadowColor = shadowColor
		self.offset = offset
		self.opacity = opacity
		self.shadowRadius = shadowRadius
		self.cornerRadius = cornerRadius
		self.corners = corners
		self.fillColor = fillColor
	}
}

public final class UShadow<T: UIView>: UWrapperView<T> {
	public private(set) var config: UShadowConfiguration = .init()

	public override func layoutSubviews() {
		super.layoutSubviews()
		self.updateShadow()
	}

	@discardableResult
	public func configure(_ config: UShadowConfiguration) -> Self {
		self.config = config
		return self
	}

	@discardableResult
	public func shadowColor(_ value: UIColor) -> Self {
		self.config.shadowColor = value
		return self
	}

	@discardableResult
	public func offset(_ value: CGSize) -> Self {
		self.config.offset = value
		return self
	}

	@discardableResult
	public func opacity(_ value: Float) -> Self {
		self.config.opacity = value
		return self
	}

	@discardableResult
	public func shadowRadius(_ value: CGFloat) -> Self {
		self.config.shadowRadius = value
		return self
	}

	@discardableResult
	public func cornerRadius(_ value: CGFloat) -> Self {
		self.config.cornerRadius = value
		return self
	}

	@discardableResult
	public func corners(_ value: UIRectCorner) -> Self {
		self.config.corners = value
		return self
	}

	@discardableResult
	public func fillColor(_ value: UIColor) -> Self {
		self.config.fillColor = value
		return self
	}

	private func updateShadow() {
		self.backgroundColor = .clear
		self.layer.sublayers?.filter { $0.name == "shadow_layer" }.forEach { $0.removeFromSuperlayer() }
		let shadowLayer = CAShapeLayer()
		let size = CGSize(width: self.config.cornerRadius, height: self.config.cornerRadius)
		let cgPath = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: self.config.corners, cornerRadii: size).cgPath
		shadowLayer.path = cgPath
		shadowLayer.fillColor = self.config.fillColor.cgColor
		shadowLayer.shadowColor = self.config.shadowColor.cgColor
		shadowLayer.shadowPath = cgPath
		shadowLayer.shadowOffset = self.config.offset
		shadowLayer.shadowOpacity = self.config.opacity
		shadowLayer.shadowRadius = self.config.shadowRadius
		shadowLayer.name = "shadow_layer"
		self.layer.masksToBounds = false
		self.layer.insertSublayer(shadowLayer, at: 0)
	}
}
