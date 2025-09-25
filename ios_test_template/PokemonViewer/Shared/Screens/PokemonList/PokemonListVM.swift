//
//  PokemonListVM.swift
//  PokemonViewer
//
//  Created by Yevhen Serhatyi on 25.09.2025.
//

import Foundation


protocol PokemonListVMType: AnyObject {
    var onChange: ((_ isInitial: Bool) -> Void)? { get set }
    func load(initial: Bool)
    func loadNextPageIfNeeded(visibleIndex: Int)
    func toggleFavorite(_ id: Int)
    func isFavorited(_ id: Int) -> Bool
    func delete(at index: Int)
    func select(at index: Int)
}

class PokemonListVM: PokemonListVMType {
    private let coordinator: PokemonListCoordType
    private let pokenomsService: PokemonsService
    private let favorites: FavoritesStoreType
    private(set) var items: [Pokemon] = []
    var onChange: ((_ isInitial: Bool) -> Void)?
    private var isLoading = false
    private var offset = 0
    private let pageSize = 30
    private var hasMore = true
    private var notification: NSObjectProtocol?

    
    init(coordinator: PokemonListCoordType, service: PokemonsService, favorites: FavoritesStoreType) {
        self.coordinator = coordinator
        self.pokenomsService = service
        self.favorites = favorites
        notification = NotificationCenter.default.addObserver(
                    forName: .favoritesChanged, object: favorites, queue: .main
                ) { [weak self] _ in
                    self?.onChange?(false)
        }
    }
    
    deinit {
            if let t = notification { NotificationCenter.default.removeObserver(t) }
    }
    
    func load(initial: Bool) {
        guard !isLoading else { return }
        isLoading = true
        Task{ [weak self] in
            guard let self = self else { return }
            defer { self.isLoading = false }
            do {
                let page = try await self.pokenomsService.fetchPokemons(offset: self.offset, limit: self.pageSize)
                self.items.append(contentsOf: page)
                self.offset += page.count
                self.hasMore = page.count == self.pageSize
                await MainActor.run { self.onChange?(initial) }
            } catch {
                await MainActor.run { self.onChange?(initial) }
            }
        }
    }
    
    func loadNextPageIfNeeded(visibleIndex: Int) {
        guard visibleIndex >= items.count - 10 else { return }
        load(initial: false)
    }
    func toggleFavorite(_ id: Int) { favorites.toggle(id) }
    
    func isFavorited(_ id: Int) -> Bool { favorites.isFavorited(id) }
    
    func delete(at index: Int) {
        guard items.indices.contains(index) else { return }
        items.remove(at: index)
        onChange?(false)
    }
    
    func select(at index: Int) {
        guard items.indices.contains(index) else { return }
        coordinator.showDetails(pokemon: items[index])
    }
}
