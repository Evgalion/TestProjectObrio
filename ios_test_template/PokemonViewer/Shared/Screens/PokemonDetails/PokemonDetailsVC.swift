//
//  PokemonDetailsVC.swift
//  PokemonViewer
//
//  Created by Yevhen Serhatyi on 26.09.2025.
//

import Foundation
import UIKit

final class PokemonDetailsVC: UIViewController {
    private let viewModel: PokemonDetailsVMType

    private let imageView = UIImageView()
    private let nameLabel = UILabel()
    private let infoLabel = UILabel()
    private lazy var favItem: UIBarButtonItem = {
        UIBarButtonItem(title: "★", style: .plain, target: self, action: #selector(tapFav))
    }()
    private let spinner = UIActivityIndicatorView(style: .large)

    private var task: URLSessionDataTask?

    init(viewModel: PokemonDetailsVMType) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        navigationItem.rightBarButtonItem = favItem

        setupUI()
        bind()
        apply()
        loadImage()
    }

    private func setupUI() {
        imageView.contentMode = .scaleAspectFit
        nameLabel.font = .systemFont(ofSize: 24, weight: .bold)
        nameLabel.textAlignment = .center
        infoLabel.font = .systemFont(ofSize: 16)
        infoLabel.textAlignment = .center
        spinner.hidesWhenStopped = true

        [imageView, nameLabel, infoLabel, spinner].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }

        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            imageView.heightAnchor.constraint(equalToConstant: 220),
            imageView.widthAnchor.constraint(equalTo: imageView.heightAnchor),

            nameLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 16),
            nameLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            nameLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),

            infoLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 8),
            infoLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            infoLabel.trailingAnchor.constraint(equalTo: nameLabel.trailingAnchor),

            spinner.centerXAnchor.constraint(equalTo: imageView.centerXAnchor),
            spinner.centerYAnchor.constraint(equalTo: imageView.centerYAnchor),
        ])
    }

    private func bind() {
        viewModel.onChange = { [weak self] in
            self?.apply()
        }
    }

    private func apply() {
        title = "Details"
        nameLabel.text = viewModel.title
        infoLabel.text = viewModel.subtitle
        favItem.tintColor = viewModel.isFavorite ? .systemYellow : .label
    }

    @objc private func tapFav() {
        viewModel.toggleFavorite()
    }

    private func loadImage() {
        imageView.image = nil
        guard let urlString = viewModel.imageURLString,
              let url = URL(string: urlString) else { return }
        spinner.startAnimating()
        task?.cancel()
        task = URLSession.shared.dataTask(with: url) { [weak self] data, _, _ in
            guard let self = self else { return }
            var img: UIImage? = nil
            if let d = data { img = UIImage(data: d) }
            DispatchQueue.main.async {
                self.spinner.stopAnimating()
                self.imageView.image = img
            }
        }
        task?.resume()
    }

    deinit { task?.cancel() }
}
