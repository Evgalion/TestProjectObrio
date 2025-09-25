//
//  PokemonDetailsCoord.swift
//  PokemonViewer
//
//  Created by Yevhen Serhatyi on 26.09.2025.
//

import Foundation
import UIKit

protocol PokemonDetailsCoordType: AnyObject { }

protocol PokemonDetailsCoordTransitions: AnyObject {
    
}

class PokemonDetailsCoord: PokemonDetailsCoordType {
    private weak var navigationController: UINavigationController?
    private weak var transitions: PokemonDetailsCoordTransitions?
    private let serviceHolder: ServiceHolder
    private let pokemon: Pokemon

    private let favorites: FavoritesStoreType
    private var viewController: PokemonDetailsVC!

    init(navigationController: UINavigationController,
         transitions: PokemonDetailsCoordTransitions?,
         serviceHolder: ServiceHolder,
         pokemon: Pokemon) {
        self.navigationController = navigationController
        self.transitions = transitions
        self.serviceHolder = serviceHolder
        self.pokemon = pokemon

        self.favorites = serviceHolder.get(by: FavoritesStoreType.self)
    }

    func start() {
        let vm = PokemonDetailsVM(pokemon: pokemon, favorites: favorites)
        viewController = PokemonDetailsVC(viewModel: vm)
        navigationController?.pushViewController(viewController, animated: true)
    }
}
