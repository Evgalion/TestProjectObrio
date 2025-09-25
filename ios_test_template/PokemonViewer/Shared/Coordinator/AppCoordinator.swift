//
//  AppCoordinator.swift
//  PokemonViewer
//
//  Created by Yevhen Serhatyi on 25.09.2025.
//

import Foundation
import UIKit


class AppCoordinator {
    private let window: UIWindow
    private let rootNav: UINavigationController = UINavigationController()
    private let serviceHolder =  ServiceHolder.shared
    private var pokemonListCoord: PokemonListCoord?
    private var pokemonDetailsCoord: PokemonDetailsCoord?
    
    init(window: UIWindow) {
        self.window = window
        start()
    }
    
    private func start(){
        startInitialService()
        window.rootViewController = rootNav
        startPokemonListFlow()
    }
    
    private func startPokemonListFlow() {
           let coord = PokemonListCoord(
               navigationController: rootNav,
               transitions: self,
               serviceHolder: serviceHolder
           )
           pokemonListCoord = coord
           coord.start()
       }
}

extension AppCoordinator{
    private func startInitialService(){
        let pokemonService = PokemonsServiceImpl()
        let favorites = FavoritesStore()
        serviceHolder.add(PokemonsService.self, for: pokemonService)
        serviceHolder.add(FavoritesStoreType.self, for: favorites)
    }
}

extension AppCoordinator: PokemonListCoordTransitions {
    func showDetails(pokemon: Pokemon) {
        let details = PokemonDetailsCoord(
            navigationController: rootNav,
            transitions: self,
            serviceHolder: serviceHolder,
            pokemon: pokemon
        )
        pokemonDetailsCoord = details
        details.start()
    }
}
extension AppCoordinator: PokemonDetailsCoordTransitions {
    func detailsDidClose() {
    }
}
