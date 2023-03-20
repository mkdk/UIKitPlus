//
//  Created by Антон Лобанов on 21.02.2021.
//

import UIKit

public protocol SegmentContentDelegate: AnyObject
{
    func segmentContent(didScroll scrollView: UIScrollView)
}

open class SegmentContentViewController: ViewController {
	weak var delegate: SegmentContentDelegate?

	open func segmentShouldBeShowed() -> Bool {
		return true
	}

	open func segmentScrollView() -> CollaborativeScroll {
		fatalError("Must be overriden")
	}
}
