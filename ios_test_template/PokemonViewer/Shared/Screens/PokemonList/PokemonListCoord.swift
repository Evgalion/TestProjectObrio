//
//  PokemonCoord.swift
//  PokemonViewer
//
//  Created by Yevhen Serhatyi on 25.09.2025.
//

import Foundation
import UIKit


protocol PokemonListCoordTransitions : AnyObject {
    func showDetails(pokemon: Pokemon)
}

protocol PokemonListCoordType {
    func showDetails(pokemon: Pokemon)
}


class PokemonListCoord: PokemonListCoordType{
    private weak var navigationController: UINavigationController?
    private weak var transitions: PokemonListCoordTransitions?
    private var serviceHolder: ServiceHolder
    private var pokemonService: PokemonsService
    private var favorites: FavoritesStoreType
    
    private var viewController: PokemonListVC!
    
    init(navigationController: UINavigationController, transitions: PokemonListCoordTransitions, serviceHolder: ServiceHolder) {
        self.navigationController = navigationController
        self.transitions = transitions
        self.serviceHolder = serviceHolder
        self.pokemonService = serviceHolder.get(by: PokemonsService.self)
        self.favorites = serviceHolder.get(by: FavoritesStoreType.self)
    }
    
    func start(){
        let viewModel = PokemonListVM(coordinator: self , service: pokemonService, favorites: favorites)
        viewController = PokemonListVC(viewModel: viewModel)
        guard let viewController else {return}
        navigationController?.pushViewController(viewController, animated: true)
    }
    
    func showDetails(pokemon: Pokemon) {
            transitions?.showDetails(pokemon: pokemon)
    }
}
