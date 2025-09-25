//
//  PokemonViewCell.swift
//  PokemonViewer
//
//  Created by Yevhen Serhatyi on 26.09.2025.
//

import Foundation
import UIKit

struct VM {
    let title: String
    let subtitle: String
    let isFavorite: Bool
    let image: UIImage?
    let isLoadingImage: Bool
}

class PokemonCell: UITableViewCell {
    
    static let reuseId = "PokemonCell"

    private let icon = UIImageView()
    private let nameLabel = UILabel()
    private let idLabel = UILabel()
    private let spinner = UIActivityIndicatorView(style: .medium)

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        icon.contentMode = .scaleAspectFit
        nameLabel.font = .systemFont(ofSize: 16, weight: .medium)
        idLabel.font = .systemFont(ofSize: 12)
        idLabel.textColor = .secondaryLabel
        spinner.hidesWhenStopped = true

        [icon, nameLabel, idLabel, spinner].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview($0)
        }

        NSLayoutConstraint.activate([
            icon.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            icon.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            icon.widthAnchor.constraint(equalToConstant: 48),
            icon.heightAnchor.constraint(equalToConstant: 48),

            nameLabel.leadingAnchor.constraint(equalTo: icon.trailingAnchor, constant: 12),
            nameLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            nameLabel.trailingAnchor.constraint(lessThanOrEqualTo: contentView.trailingAnchor, constant: -12),

            idLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            idLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 4),
            idLabel.trailingAnchor.constraint(lessThanOrEqualTo: contentView.trailingAnchor, constant: -12),

            spinner.centerXAnchor.constraint(equalTo: icon.centerXAnchor),
            spinner.centerYAnchor.constraint(equalTo: icon.centerYAnchor),
        ])
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    func configure(_ vm: VM) {
        nameLabel.text = vm.title
        idLabel.text = vm.subtitle
        icon.image = vm.image
        vm.isLoadingImage ? spinner.startAnimating() : spinner.stopAnimating()
    }
}
