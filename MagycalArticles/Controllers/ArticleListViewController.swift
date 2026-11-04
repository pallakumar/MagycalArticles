//
//  ArticleListViewController.swift
//  MagycalArticles
//
//  Created by Palla Kumar on 04/12/26.
//

import UIKit
import SwiftUI
import Network

final class ArticleListViewController: UIViewController {

    // MARK: - Dependencies

    private let manager = AppContainer.shared.container
        .resolve(ArticleManager.self)!

    private let pathMonitor = NWPathMonitor()
    private let networkQueue = DispatchQueue(
        label: "com.magycal.articles.network"
    )

    // MARK: - Properties

    private var articles: [Article] = []
    private var isGridLayout = false
    private var isNetworkAvailable = false
    private var isLoading = false

    private var headerTopConstraint: NSLayoutConstraint?

    // MARK: - Views

    private var collectionView: UICollectionView!
    private var headerHost: UIHostingController<ArticleHeaderView>?

    private let refreshControl = UIRefreshControl()

    // MARK: - Offline Views

    private let offlineIcon: UIImageView = {
        let imageView = UIImageView(
            image: UIImage(systemName: "wifi.slash")
        )

        imageView.tintColor = .darkGray
        imageView.contentMode = .scaleAspectFit
        imageView.preferredSymbolConfiguration =
            UIImage.SymbolConfiguration(pointSize: 40)

        return imageView
    }()

    private let offlineTitle: UILabel = {
        let label = UILabel()

        label.text = "You're offline"
        label.font = .systemFont(ofSize: 17, weight: .semibold)
        label.textColor = .black
        label.textAlignment = .center

        return label
    }()

    private let offlineMessage: UILabel = {
        let label = UILabel()

        label.text = "Please connect to the internet and try again."
        label.font = .systemFont(ofSize: 13)
        label.textColor = .gray
        label.textAlignment = .center
        label.numberOfLines = 0

        return label
    }()

    private lazy var retryButton: UIButton = {
        let button = UIButton(type: .system)

        button.setTitle("↻  Retry", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.titleLabel?.font = .systemFont(
            ofSize: 13,
            weight: .semibold
        )

        button.backgroundColor = .white
        button.layer.cornerRadius = 14

        button.contentEdgeInsets = UIEdgeInsets(
            top: 7,
            left: 16,
            bottom: 7,
            right: 16
        )

        button.addTarget(
            self,
            action: #selector(retryConnection),
            for: .touchUpInside
        )

        return button
    }()

    private lazy var offlineStack: UIStackView = {
        let stack = UIStackView(
            arrangedSubviews: [
                offlineIcon,
                offlineTitle,
                offlineMessage,
                retryButton
            ]
        )

        stack.axis = .vertical
        stack.alignment = .center
        stack.spacing = 14
        stack.isHidden = true

        return stack
    }()

    // MARK: - View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        configureView()
        setupHeader()
        setupCollectionView()
        setupOfflineView()
        startNetworkMonitoring()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        navigationController?.setNavigationBarHidden(
            true,
            animated: false
        )
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        // Position the custom header immediately below
        // the status bar without an additional safe-area gap.

        let statusBarHeight = view.window?.windowScene?
            .statusBarManager?.statusBarFrame.height
            ?? view.safeAreaInsets.top

        headerTopConstraint?.constant = statusBarHeight
    }

    deinit {
        pathMonitor.cancel()
    }

    // MARK: - Initial Configuration

    private func configureView() {
        edgesForExtendedLayout = [.top, .bottom]
        extendedLayoutIncludesOpaqueBars = true
        additionalSafeAreaInsets = .zero

        view.backgroundColor = UIColor(
            white: 0.94,
            alpha: 1
        )

        navigationController?.setNavigationBarHidden(
            true,
            animated: false
        )
    }

    // MARK: - Header Setup

    private func setupHeader() {
        
        let headerView = ArticleHeaderView(
            isGrid: isGridLayout,
            onToggleLayout: { [weak self] in
                self?.toggleLayout()
            },
            onSearch: { [weak self] in
                self?.showSearchAlert()
            }
        )

        let host = UIHostingController(rootView: headerView)

        headerHost = host
        addChild(host)

        view.addSubview(host.view)

        host.view.translatesAutoresizingMaskIntoConstraints = false
        host.view.backgroundColor = .white

        host.didMove(toParent: self)

        NSLayoutConstraint.activate([
            host.view.topAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.topAnchor
            ),
            host.view.leadingAnchor.constraint(
                equalTo: view.leadingAnchor
            ),
            host.view.trailingAnchor.constraint(
                equalTo: view.trailingAnchor
            ),
            host.view.heightAnchor.constraint(equalToConstant: 64)
        ])
    }
    
    private func showSearchAlert() {

        let alert = UIAlertController(
            title: "Search Articles",
            message: "Enter an article keyword",
            preferredStyle: .alert
        )

        alert.addTextField { textField in
            textField.placeholder = "Search articles"
            textField.autocapitalizationType = .none
        }

        alert.addAction(
            UIAlertAction(title: "Cancel", style: .cancel)
        )

        alert.addAction(
            UIAlertAction(title: "Search", style: .default) {
                [weak self, weak alert] _ in

                guard let self = self else { return }

                let keyword = alert?.textFields?.first?.text?
                    .trimmingCharacters(in: .whitespacesAndNewlines)
                    .lowercased() ?? ""

                guard !keyword.isEmpty else { return }

                self.articles = self.manager.cached().filter {
                    $0.title.lowercased().contains(keyword)
                    || $0.summary.lowercased().contains(keyword)
                }

                self.collectionView.reloadData()
            }
        )

        present(alert, animated: true)
    }

    // MARK: - Collection View Setup

    private func setupCollectionView() {

        let layout = UICollectionViewFlowLayout()

        layout.minimumInteritemSpacing = 8
        layout.minimumLineSpacing = 10

        layout.sectionInset = UIEdgeInsets(
            top: 10,
            left: 10,
            bottom: 16,
            right: 10
        )

        collectionView = UICollectionView(
            frame: .zero,
            collectionViewLayout: layout
        )

        collectionView.backgroundColor = UIColor(
            white: 0.94,
            alpha: 1
        )

        collectionView.dataSource = self
        collectionView.delegate = self

        collectionView.register(
            ArticleCardCell.self,
            forCellWithReuseIdentifier: ArticleCardCell.id
        )

        collectionView.refreshControl = refreshControl

        refreshControl.addTarget(
            self,
            action: #selector(refreshFeed),
            for: .valueChanged
        )

        view.addSubview(collectionView)

        collectionView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([

            collectionView.topAnchor.constraint(
                equalTo: headerHost!.view.bottomAnchor
            ),

            collectionView.leadingAnchor.constraint(
                equalTo: view.leadingAnchor
            ),

            collectionView.trailingAnchor.constraint(
                equalTo: view.trailingAnchor
            ),

            collectionView.bottomAnchor.constraint(
                equalTo: view.bottomAnchor
            )
        ])
    }

    // MARK: - Offline View Setup

    private func setupOfflineView() {

        view.addSubview(offlineStack)

        offlineStack.translatesAutoresizingMaskIntoConstraints = false
        offlineIcon.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([

            offlineIcon.widthAnchor.constraint(
                equalToConstant: 50
            ),

            offlineIcon.heightAnchor.constraint(
                equalToConstant: 45
            ),

            offlineStack.centerXAnchor.constraint(
                equalTo: view.centerXAnchor
            ),

            offlineStack.centerYAnchor.constraint(
                equalTo: view.centerYAnchor,
                constant: -10
            ),

            offlineStack.leadingAnchor.constraint(
                greaterThanOrEqualTo: view.leadingAnchor,
                constant: 24
            ),

            offlineStack.trailingAnchor.constraint(
                lessThanOrEqualTo: view.trailingAnchor,
                constant: -24
            )
        ])
    }

    // MARK: - Network Monitoring

    private func startNetworkMonitoring() {

        pathMonitor.pathUpdateHandler = { [weak self] path in

            guard let self = self else { return }

            let connected = path.status == .satisfied

            DispatchQueue.main.async {

                let wasConnected = self.isNetworkAvailable

                self.isNetworkAvailable = connected

                if connected {

                    self.showOfflineView(false)

                    if !wasConnected {
                        self.loadArticles()
                    }

                } else {

                    // Do not display cached articles while offline.

                    self.articles.removeAll()

                    self.collectionView.reloadData()

                    self.refreshControl.endRefreshing()

                    self.showOfflineView(true)
                }
            }
        }

        pathMonitor.start(queue: networkQueue)
    }

    private func showOfflineView(_ show: Bool) {

        offlineStack.isHidden = !show
        collectionView.isHidden = show
    }

    // MARK: - Layout Actions

    private func toggleLayout() {

        isGridLayout.toggle()

        collectionView.collectionViewLayout.invalidateLayout()

        collectionView.reloadData()

        // Refresh the custom SwiftUI header button icon.

        headerHost?.rootView = ArticleHeaderView(
            isGrid: isGridLayout,
            onToggleLayout: { [weak self] in
                self?.toggleLayout()
            },
            onSearch: { [weak self] in
                self?.presentSearch()
            }
        )
    }

    // MARK: - Search

    private func presentSearch() {

        let alert = UIAlertController(
            title: "Search articles",
            message: nil,
            preferredStyle: .alert
        )

        alert.addTextField { textField in
            textField.placeholder = "Enter a keyword"
            textField.autocapitalizationType = .none
        }

        alert.addAction(
            UIAlertAction(
                title: "Cancel",
                style: .cancel
            )
        )

        alert.addAction(
            UIAlertAction(
                title: "Search",
                style: .default
            ) { [weak self, weak alert] _ in

                guard let self = self else { return }

                let query = alert?.textFields?.first?.text?
                    .trimmingCharacters(
                        in: .whitespacesAndNewlines
                    )
                    .lowercased() ?? ""

                let allArticles = self.articles

                if query.isEmpty {
                    self.articles = allArticles
                } else {
                    self.articles = allArticles.filter { article in
                        article.title.lowercased().contains(query)
                        || article.summary.lowercased().contains(query)
                    }
                }

                self.collectionView.reloadData()
            }
        )

        present(alert, animated: true)
    }

    // MARK: - Retry

    @objc private func retryConnection() {

        guard isNetworkAvailable else {
            showOfflineView(true)
            return
        }

        loadArticles()
    }

    // MARK: - Refresh

    @objc private func refreshFeed() {
        loadArticles()
    }

    // MARK: - API Loading

    private func loadArticles() {

        guard isNetworkAvailable else {

            articles.removeAll()

            collectionView.reloadData()

            refreshControl.endRefreshing()

            showOfflineView(true)

            return
        }

        guard !isLoading else {
            return
        }

        isLoading = true

        manager.load { [weak self] result in

            DispatchQueue.main.async {

                guard let self = self else { return }

                self.isLoading = false

                self.refreshControl.endRefreshing()

                switch result {

                case .success(let response):

                    // response.0 = articles
                    // response.1 = whether cached data was used

                    if response.1 {
                        self.articles.removeAll()
                        self.collectionView.reloadData()
                        self.showOfflineView(true)
                        return
                    }

                    self.articles = response.0

                    self.collectionView.reloadData()

                    self.showOfflineView(false)

                case .failure(let error):

                    self.articles.removeAll()

                    self.collectionView.reloadData()

                    self.showOfflineView(false)

                    self.showLoadError(error)
                }
            }
        }
    }

    // MARK: - Error Handling

    private func showLoadError(_ error: Error) {

        let alert = UIAlertController(
            title: "Unable to load articles",
            message: error.localizedDescription,
            preferredStyle: .alert
        )

        alert.addAction(
            UIAlertAction(
                title: "Retry",
                style: .default
            ) { [weak self] _ in
                self?.loadArticles()
            }
        )

        alert.addAction(
            UIAlertAction(
                title: "OK",
                style: .cancel
            )
        )

        present(alert, animated: true)
    }

    // MARK: - Article Navigation

    private func showArticle(_ article: Article) {

        let detailViewController = ArticleDetailViewController()

        detailViewController.article = article

        navigationController?.pushViewController(
            detailViewController,
            animated: true
        )
    }
}

// MARK: - UICollectionViewDataSource

extension ArticleListViewController: UICollectionViewDataSource {

    func collectionView(
        _ collectionView: UICollectionView,
        numberOfItemsInSection section: Int
    ) -> Int {

        return articles.count
    }

    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {

        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: ArticleCardCell.id,
            for: indexPath
        ) as! ArticleCardCell

        let article = articles[indexPath.item]

        cell.configure(article)

        cell.onRead = { [weak self] in
            self?.showArticle(article)
        }

        return cell
    }
}

// MARK: - UICollectionViewDelegate

extension ArticleListViewController: UICollectionViewDelegate {

    func collectionView(
        _ collectionView: UICollectionView,
        didSelectItemAt indexPath: IndexPath
    ) {

        showArticle(articles[indexPath.item])
    }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension ArticleListViewController:
    UICollectionViewDelegateFlowLayout {

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {

        let columns: CGFloat = isGridLayout ? 2 : 1

        let spacing: CGFloat = 8

        let availableWidth = collectionView.bounds.width
            - 20
            - ((columns - 1) * spacing)

        let itemWidth = floor(
            availableWidth / columns
        )

        return CGSize(
            width: itemWidth,
            height: isGridLayout ? 190 : 220
        )
    }
}
