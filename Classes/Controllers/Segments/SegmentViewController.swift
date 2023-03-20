//
//  Created by Антон Лобанов on 20.02.2021.
//

import UIKit

open class SegmentViewController: ViewController {
    public private(set) var headerView: SegmentHeaderView?
	public private(set) var navigationBarView: SegmentNavigationBarView
    public private(set) var refreshControl: UIRefreshControl?
    public private(set) var viewControllers: [SegmentContentViewController] = []

    // MARK: - UI

    private lazy var verticalCollectionView = SegmentVerticalCollectionView(
        adapter: self,
        refreshControl: self.refreshControl
    )

    private lazy var pageCollectionView = SegmentPageCollectionView(
        adapter: self
    )

    // MARK: - Variables

    private var visibleCollaborativeScrollView: UIScrollView {
        return self.viewControllers[self.pageCollectionView.selectedIndex].segmentScrollView()
    }

    private var lastCollaborativeScrollView: UIScrollView?

    // MARK: - UIKit

    public init(
        headerView: SegmentHeaderView? = nil,
		navigationBarView: SegmentNavigationBarView,
        viewControllers: [SegmentContentViewController],
        refreshControl: UIRefreshControl? = nil
    ) {
		self.headerView = headerView
		self.viewControllers = viewControllers
		self.refreshControl = refreshControl
		self.navigationBarView = navigationBarView

		super.init(nibName: nil, bundle: nil)

		self.headerView?.delegate = self
		self.navigationBarView.delegate = self
    }

    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    open override func viewDidLoad() {
        super.viewDidLoad()
        self.viewControllers.forEach {
			$0.delegate = self
			$0.segmentScrollView().bounces = false
		}

        self.view.addSubview(self.verticalCollectionView)
        NSLayoutConstraint.activate([
            self.verticalCollectionView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor),
            self.verticalCollectionView.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor),
            self.verticalCollectionView.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor),
            self.verticalCollectionView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
        ])

		self.pageCollectionView.scrollToItem(at: 0, animated: false)
		DispatchQueue.main.async {
			UIView.setAnimationsEnabled(false)
			self.navigationBarView.segment(didScroll: CGFloat(0))
			UIView.setAnimationsEnabled(true)
		}
    }

	open func segmentDidScroll() {}
}

extension SegmentViewController: SegmentHeaderDelegate {
	func segmentHeaderReload() {
		self.verticalCollectionView.reloadItem(at: IndexPath(item: 0, section: 0))
	}
}

extension SegmentViewController: SegmentNavigationBarDelegate
{
    func segmentNavigationBar(didSelect item: Int) {
        self.pageCollectionView.scrollToItem(at: item, animated: true)
        self.syncCollaborativeScrollIfNeeded()
    }
}

extension SegmentViewController: SegmentVerticalCollectionAdapter
{
    func segmentVerticalCollection(headerView collectionView: UICollectionView) -> UIView? {
        self.headerView
    }

    func segmentVerticalCollection(navigationBarView collectionView: UICollectionView) -> UIView? {
        guard self.viewControllers.count > 1 else { return nil }
        return self.navigationBarView
    }

    func segmentVerticalCollection(pageCollectionView collectionView: UICollectionView) -> UIView {
        self.pageCollectionView
    }

    func segmentVerticalCollection(didScroll collectionView: UICollectionView) {
        self.syncVerticalScrollIfNeeded()
		self.segmentDidScroll()
    }
}

extension SegmentViewController: SegmentPageCollectionAdapter
{
    func segmentPageCollection(shouldShow index: Int) -> Bool {
        self.viewControllers[index].segmentShouldBeShowed()
    }

    func segmentPageCollectionViewControllers() -> [UIViewController] {
        self.viewControllers
    }

    func segmentPageCollectionWillBeginDragging() {
        self.viewControllers.forEach {
            $0.segmentScrollView().isScrollEnabled = false
        }
        self.syncCollaborativeScrollIfNeeded()
    }

    func segmentPageCollectionDidEndDragging() {
        self.viewControllers.forEach {
            $0.segmentScrollView().isScrollEnabled = true
        }
    }

    func segmentPageCollection(didScroll point: CGPoint) {
        self.navigationBarView.segment(didScroll: (point.x / self.view.frame.width) - 1)
		self.segmentDidScroll()
    }
}

extension SegmentViewController: SegmentContentDelegate
{
    public func segmentContent(didScroll scrollView: UIScrollView) {
        self.syncVerticalScrollIfNeeded()
		self.segmentDidScroll()
    }
}

// MARK: - Private

private extension SegmentViewController
{
    func syncVerticalScrollIfNeeded() {
        guard self.headerView != nil else {
            self.verticalCollectionView.contentOffsetY = 0
            return
        }

        let ctx = (
            headerH: self.verticalCollectionView.sizeForHeader().height,
            verticalY: self.verticalCollectionView.contentOffsetY,
            lastVerticalY: self.verticalCollectionView.lastContentOffsetY,
            collaborativeY: self.visibleCollaborativeScrollView.contentOffset.y
        )

        let collaborativeY = ctx.verticalY >= ctx.headerH
            ? ctx.collaborativeY
            : ctx.collaborativeY > 0 && ctx.lastVerticalY >= ctx.headerH
            ? ctx.collaborativeY
            : 0

        let verticalY = collaborativeY > 0
            ? ctx.headerH
            : ctx.verticalY

		let contentOffsetY = max(0, collaborativeY)

        self.visibleCollaborativeScrollView.contentOffset.y = contentOffsetY
		self.visibleCollaborativeScrollView.bounces = contentOffsetY > 100
        self.verticalCollectionView.contentOffsetY = min(ctx.headerH, verticalY)
        self.verticalCollectionView.lastContentOffsetY = min(ctx.headerH, verticalY)
        self.lastCollaborativeScrollView = self.visibleCollaborativeScrollView
    }

    func syncCollaborativeScrollIfNeeded() {
        guard let collaborativeScrollView = self.lastCollaborativeScrollView,
              self.headerView != nil
        else {
            return
        }

        let ctx = (
            collaborativeY: collaborativeScrollView.contentOffset.y,
			navBarHeight: self.navigationBarView.segmentHeight()
        )

        self.viewControllers
            .map { $0.segmentScrollView() }
            .filter { $0 != collaborativeScrollView }
            .forEach {
                if ctx.collaborativeY == 0 && $0.contentOffset.y > 0 { $0.contentOffset.y = 0 }
            }
    }
}
