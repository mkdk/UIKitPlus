//
//  Created by Антон Лобанов on 13.03.2021.
//

import UIKit

protocol SegmentVerticalCollectionAdapter: AnyObject {
    func segmentVerticalCollection(headerView collectionView: UICollectionView) -> UIView?
    func segmentVerticalCollection(navigationBarView collectionView: UICollectionView) -> UIView?
    func segmentVerticalCollection(pageCollectionView collectionView: UICollectionView) -> UIView
    func segmentVerticalCollection(didScroll collectionView: UICollectionView)
}

final class SegmentVerticalCollectionView: UIView {
    private final class ControlContainableCollectionView: UICollectionView
    {
        override func touchesShouldCancel(in view: UIView) -> Bool {
            return view.isKind(of: UIControl.self) ? true : super.touchesShouldCancel(in: view)
        }
    }

    var lastContentOffsetY: CGFloat = 0

    var contentOffsetY: CGFloat {
        get { self.verticalCollectionView.contentOffset.y }
        set { self.verticalCollectionView.contentOffset.y = newValue }
    }

    private lazy var flowLayout: UICollectionViewFlowLayout = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        layout.sectionInset = .zero
        return layout
    }()

    private lazy var verticalCollectionView: UICollectionView = {
        let collectionView = ControlContainableCollectionView(
            frame: .zero,
            collectionViewLayout: self.flowLayout
        )
        collectionView.backgroundColor = .clear
        collectionView.alwaysBounceVertical = true
		collectionView.bounces = true
        collectionView.showsVerticalScrollIndicator = false
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.delegate = self
        collectionView.dataSource = self

		if #available(iOS 11.0, *) {
            collectionView.contentInsetAdjustmentBehavior = .never
        }

		collectionView.register(
            UICollectionViewCell.self,
            forCellWithReuseIdentifier: String(describing: UICollectionViewCell.self)
        )

		if let refreshControl = self.refreshControl {
            if #available(iOS 10.0, *) {
                collectionView.refreshControl = refreshControl
            }
            else {
                collectionView.addSubview(refreshControl)
            }
        }

		return collectionView
    }()

    private weak var adapter: SegmentVerticalCollectionAdapter!
    private let refreshControl: UIRefreshControl?

    init(
        adapter: SegmentVerticalCollectionAdapter,
        refreshControl: UIRefreshControl?
    ) {
        self.adapter = adapter
        self.refreshControl = refreshControl

		super.init(frame: .zero)

		self.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(self.verticalCollectionView)
        NSLayoutConstraint.activate([
            self.verticalCollectionView.topAnchor.constraint(equalTo: self.topAnchor),
            self.verticalCollectionView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            self.verticalCollectionView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            self.verticalCollectionView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func reloadItem(at indexPath: IndexPath) {
        self.verticalCollectionView.performBatchUpdates({
            self.verticalCollectionView.reloadItems(at: [indexPath])
        }, completion: { _ in })
    }

    func sizeForHeader() -> CGSize {
        self.collectionView(
            self.verticalCollectionView,
            layout: self.flowLayout,
            sizeForItemAt: IndexPath(item: 0, section: 0)
        )
    }
}

extension SegmentVerticalCollectionView: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    func collectionView(
        _ collectionView: UICollectionView,
        numberOfItemsInSection section: Int
    ) -> Int {
        4
    }

    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: String(describing: UICollectionViewCell.self),
            for: indexPath
        )

        let contentView: UIView

        switch true {
        case indexPath.item == 0:
            let headerView = self.adapter.segmentVerticalCollection(headerView: collectionView)
            contentView = headerView ?? UIView()
        case indexPath.item == 1:
            let navigationBarView = self.adapter.segmentVerticalCollection(navigationBarView: collectionView)
            contentView = navigationBarView ?? UIView()
        case indexPath.item == 2:
            let pageCollectionView = self.adapter.segmentVerticalCollection(pageCollectionView: collectionView)
            contentView = pageCollectionView
        default:
            contentView = UIView()
        }

        contentView.translatesAutoresizingMaskIntoConstraints = false
        cell.contentView.subviews.forEach { $0.removeFromSuperview() }
        cell.contentView.addSubview(contentView)
        cell.contentView.clipsToBounds = true

        let bottomConstraint = NSLayoutConstraint(item: contentView,
                                                  attribute: .bottom,
                                                  relatedBy: .equal,
                                                  toItem: cell.contentView,
                                                  attribute: .bottom,
                                                  multiplier: 1,
                                                  constant: 0)
        bottomConstraint.priority = .init(999)

        NSLayoutConstraint.activate([
            contentView.topAnchor.constraint(equalTo: cell.contentView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: cell.contentView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: cell.contentView.trailingAnchor),
            bottomConstraint,
        ])

        return cell
    }

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        switch true {
        case indexPath.item == 0:
            let headerView = self.adapter.segmentVerticalCollection(headerView: collectionView)
            return headerView?.systemLayoutSizeFitting(
                .init(width: self.frame.width, height: 0),
                withHorizontalFittingPriority: .required,
                verticalFittingPriority: .fittingSizeLevel
            ) ?? .zero
        case indexPath.item == 1:
            let navigationBarView = self.adapter.segmentVerticalCollection(navigationBarView: collectionView)
            return navigationBarView?.systemLayoutSizeFitting(
                .init(width: self.frame.width, height: 0),
                withHorizontalFittingPriority: .required,
                verticalFittingPriority: .fittingSizeLevel
            ) ?? .zero
        case indexPath.item == 2:
            let navigationBarHeight = self.collectionView(
                collectionView,
                layout: collectionViewLayout,
                sizeForItemAt: IndexPath(item: 1, section: 0)
            ).height
            return .init(
                width: collectionView.frame.width,
                height: collectionView.frame.size.height - navigationBarHeight
            )
        default:
            return .zero
        }
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
		guard scrollView.isDragging || scrollView.isTracking else { return }
        self.adapter.segmentVerticalCollection(didScroll: self.verticalCollectionView)
    }
}
