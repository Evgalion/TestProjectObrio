//
//  FavoriteStore.swift
//  PokemonViewer
//
//  Created by Yevhen Serhatyi on 26.09.2025.
//

import Foundation


extension Notification.Name {
    static let favoritesChanged = Notification.Name("FavoritesStore.favoritesChanged")
}


protocol FavoritesStoreType: AnyObject, Service {
    func isFavorited(_ id: Int) -> Bool
    func toggle(_ id: Int)
    var count: Int { get }
}

final class FavoritesStore: FavoritesStoreType {
    private var ids = Set<Int>()
    func isFavorited(_ id: Int) -> Bool { ids.contains(id) }
    
    func toggle(_ id: Int) {
        if ids.contains(id) { ids.remove(id) } else { ids.insert(id) }
        NotificationCenter.default.post(
            name: .favoritesChanged,
            object: self,
            userInfo: ["id": id]
        )
    }
    
    var count: Int { ids.count }
}
