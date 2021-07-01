//
//  Favorites.swift
//  SeatGeekCodingExercise
//
//  Created by endOfLine on 6/26/21.
//

import Foundation

struct Favorites {
    
    // key for storing favorites array in user defaults
    let favoritesKey = "favorites"
    let defaults = UserDefaults.standard
    
    // check if event id is stored in user defaults
    func isFavorite(_ id: Int) -> Bool {
        if ((defaults.object(forKey: favoritesKey) as? [Int])?.contains(id) ?? false) {
            return true
        } else {
            return false
        }
    }
    
    // add or remove event id from user defaults
    func toggle(_ id: Int) {
        if var favsArray = defaults.object(forKey: favoritesKey) as? [Int] {
            var favsSet = Set(favsArray)
            if isFavorite(id) {
                favsSet.remove(id)
            } else {
                favsSet.insert(id)
            }
            favsArray = Array(favsSet)
            defaults.setValue(favsArray, forKey: favoritesKey)
        } else {
            defaults.set([id], forKey: favoritesKey)
        }
    }
    
    func reset() {
        defaults.removeObject(forKey: favoritesKey)
    }
    
}
