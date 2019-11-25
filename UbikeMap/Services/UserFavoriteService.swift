//
//  UserFavoriteService.swift
//  UbikeMap
//
//  Created by Kao Ming-Hsiu on 2019/11/25.
//  Copyright © 2019 ObiCat. All rights reserved.
//

import Foundation

class UserFavoriteService {
    
    private static let favoriteKey = "favorite"
    
    static private func favorites() -> [String] {
        return UserDefaults.standard.array(forKey: favoriteKey) as? [String] ?? []
    }
    
    static func isFavorite(_ id: String) -> Bool {
        return favorites().contains(where: { $0 == id })
    }
    
    static func addFavorite(_ id: String) {
        var favorites = self.favorites()
        guard favorites.first(where: { $0 == id }) == nil else { return }
        favorites.append(id)
        favorites.sort()
        UserDefaults.standard.set(favorites, forKey: favoriteKey)
    }
    
    static func removeFavorite(_ id: String) {
        var favorites = self.favorites()
        favorites.removeAll(where: { $0 == id })
        UserDefaults.standard.set(favorites, forKey: favoriteKey)
    }
}
