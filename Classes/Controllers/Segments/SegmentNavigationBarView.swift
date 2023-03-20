//
//  Created by Антон Лобанов on 22.02.2021.
//

import UIKit

protocol SegmentNavigationBarDelegate: AnyObject {
    func segmentNavigationBar(didSelect item: Int)
}

open class SegmentNavigationBarView: UView {
	weak var delegate: SegmentNavigationBarDelegate?

	open func segmentHeight() -> CGFloat {
		return 0
	}

	open func segment(didScroll percentage: CGFloat) {}

	public func segment(didSelect index: Int) {
		self.delegate?.segmentNavigationBar(didSelect: index)
	}
}
