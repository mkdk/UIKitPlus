//
//  Created by Антон Лобанов on 22.02.2021.
//

import UIKit

protocol SegmentHeaderDelegate: AnyObject {
	func segmentHeaderReload()
}

open class SegmentHeaderView: UView {
	weak var delegate: SegmentHeaderDelegate?

	open override func layoutSubviews() {
		super.layoutSubviews()
		self.delegate?.segmentHeaderReload()
	}
}
