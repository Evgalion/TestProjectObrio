//
//  PokemonDetailsVM.swift
//  PokemonViewer
//
//  Created by Yevhen Serhatyi on 26.09.2025.
//

import Foundation


protocol PokemonDetailsVMType: AnyObject {
    var onChange: (() -> Void)? { get set }
    var title: String { get }
    var subtitle: String { get }
    var imageURLString: String? { get }
    var isFavorite: Bool { get }
    
    func toggleFavorite()
}

final class PokemonDetailsVM: PokemonDetailsVMType {
    private let pokemon: Pokemon
    private let favorites: FavoritesStoreType
    private var notification: NSObjectProtocol?
    
    var onChange: (() -> Void)?
    var title: String { pokemon.name }
    var subtitle: String { "H: \(pokemon.height)  W: \(pokemon.weight)" }
    var imageURLString: String? { pokemon.imageURLString }
    var isFavorite: Bool { favorites.isFavorited(pokemon.id) }
    
    init(pokemon: Pokemon, favorites: FavoritesStoreType) {
        self.pokemon = pokemon
        self.favorites = favorites
        notification = NotificationCenter.default.addObserver(
            forName: .favoritesChanged, object: favorites, queue: .main
        ) { [weak self] note in
            guard let self = self else { return }
            if let changed = note.userInfo?["id"] as? Int, changed == self.pokemon.id {
                self.onChange?()
            }
        }
    }
    
    deinit {
            if let t = notification { NotificationCenter.default.removeObserver(t) }
        }
    
    func toggleFavorite() {
        favorites.toggle(pokemon.id)
        onChange?()
    }
}
