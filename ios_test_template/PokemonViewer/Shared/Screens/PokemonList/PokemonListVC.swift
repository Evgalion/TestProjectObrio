//
//  PokemonListVC.swift
//  PokemonViewer
//
//  Created by Yevhen Serhatyi on 25.09.2025.
//

import Foundation
import UIKit

class PokemonListVC: UIViewController {
    var viewModel: PokemonListVM

    private let tableView = UITableView()
    private lazy var favoritesItem: UIBarButtonItem = {
        UIBarButtonItem(title: "★ 0", style: .plain, target: self, action: #selector(tapFavorites))
    }()

    private var imageCache: [URL: UIImage] = [:]
    private var imageTasks: [URL: URLSessionDataTask] = [:]

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        fatalError("Use init(viewModel:)")
    }

    init(viewModel: PokemonListVM) {
        self.viewModel = viewModel
        super.init(nibName: .none, bundle: .none)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Pokémon"
        view.backgroundColor = .systemBackground
        navigationItem.rightBarButtonItem = favoritesItem

        setupTable()
        bind()
        viewModel.load(initial: true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateFavoritesCounter()
    }

    private func setupTable() {
        tableView.register(PokemonCell.self, forCellReuseIdentifier: PokemonCell.reuseId)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.rowHeight = 72
        tableView.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(tableView)
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
    }

    private func bind() {
        viewModel.onChange = { [weak self] _ in
            guard let self = self else { return }
            self.tableView.reloadData()
            self.updateFavoritesCounter()
        }
    }

    private func updateFavoritesCounter() {
        let count = viewModel.items.filter { viewModel.isFavorited($0.id) }.count
        favoritesItem.title = "★ \(count)"
        favoritesItem.tintColor = count > 0 ? .systemYellow : .label
    }

    @objc private func tapFavorites() {
    }
}

// MARK: - UITableViewDataSource
extension PokemonListVC: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.items.count
    }

    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let item = viewModel.items[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: PokemonCell.reuseId, for: indexPath) as! PokemonCell

        var image: UIImage? = nil
        var isLoading = false
        if let url = URL(string: item.imageURLString) {
            if let cached = imageCache[url] {
                image = cached
            } else {
                isLoading = true
                if imageTasks[url] == nil {
                    let task = URLSession.shared.dataTask(with: url) { [weak self, weak tableView] data, _, _ in
                        guard let self = self else { return }
                        if let d = data, let img = UIImage(data: d) {
                            self.imageCache[url] = img
                        }
                        DispatchQueue.main.async {
                            guard let tableView = tableView else { return }
                            if let visible = tableView.indexPathsForVisibleRows,
                               visible.contains(indexPath) {
                                tableView.reloadRows(at: [indexPath], with: .fade)
                            }
                        }
                        self.imageTasks[url] = nil
                    }
                    imageTasks[url] = task
                    task.resume()
                }
            }
        }

        cell.configure(.init(
            title: item.name,
            subtitle: "#\(item.id)",
            isFavorite: viewModel.isFavorited(item.id),
            image: image,
            isLoadingImage: isLoading
        ))
        return cell
    }
}

// MARK: - UITableViewDelegate
extension PokemonListVC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        viewModel.select(at: indexPath.row)
        tableView.deselectRow(at: indexPath, animated: true)
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let y = scrollView.contentOffset.y
        let h = scrollView.contentSize.height - scrollView.bounds.height
        if h > 0, y > h - 300, let last = tableView.indexPathsForVisibleRows?.last {
            viewModel.loadNextPageIfNeeded(visibleIndex: last.row)
        }
    }
    
    func tableView(_ tableView: UITableView,
                   trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let delete = UIContextualAction(style: .destructive, title: "Delete") { [weak self, weak tableView] _, _, completion in
            guard let self = self, let tableView = tableView else { completion(false); return }
            self.viewModel.delete(at: indexPath.row)
            tableView.performBatchUpdates({
                tableView.deleteRows(at: [indexPath], with: .automatic)
            }, completion: { _ in
                self.updateFavoritesCounter()
            })
            completion(true)
        }
        return UISwipeActionsConfiguration(actions: [delete])
    }

    func tableView(_ tableView: UITableView,
                   leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let item = viewModel.items[indexPath.row]
        let isFav = viewModel.isFavorited(item.id)
        let title = isFav ? "Unfavorite" : "Favorite"
        let favorite = UIContextualAction(style: .normal, title: title) { [weak self, weak tableView] _, _, completion in
            guard let self = self, let tableView = tableView else { completion(false); return }
            self.viewModel.toggleFavorite(item.id)
            self.updateFavoritesCounter()
            tableView.reloadRows(at: [indexPath], with: .none)
            completion(true)
        }
        favorite.backgroundColor = isFav ? .systemGray : .systemYellow
        return UISwipeActionsConfiguration(actions: [favorite])
    }

    func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard indexPath.row < viewModel.items.count else { return }
        let item = viewModel.items[indexPath.row]
        if let url = URL(string: item.imageURLString),
           let t = imageTasks[url] {
            t.cancel()
            imageTasks[url] = nil
        }
    }
}
