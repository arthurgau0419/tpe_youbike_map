//
//  Model.swift
//  UbikeMap
//
//  Created by Kao Ming-Hsiu on 2019/11/25.
//  Copyright © 2019 ObiCat. All rights reserved.
//

import Foundation

protocol ListItemType {
    var id: String {get}
    var 場站名稱: String {get}
    var 場站區域: String {get}
    var 場站總停車格: Int {get}
    var 場站目前車輛數量: Int {get}
    var 空位數量: Int {get}
    var 地址: String {get}
    var 資料更新時間: Date {get}
    var 我的最愛: Bool {get set}
}

struct ListItem: ListItemType {
    
    let station: UbikeStation
    
    var id: String { return station.id }
    
    var 場站名稱: String {
        return station.sna
    }
    
    var 場站區域: String {
        return station.sarea
    }
    
    
    var 場站總停車格: Int {
        return station.tot
    }
    
    var 場站目前車輛數量: Int {
        return station.sbi
    }
    
    var 空位數量: Int {
        return station.tot - station.sbi
    }
    
    var 地址: String {
        return station.ar
    }
    
    var 資料更新時間: Date {
        return station.mday
    }
    
    var 我的最愛: Bool {
        get {
            return UserFavoriteService.isFavorite(station.id)
        }
        set {
            if newValue {
                UserFavoriteService.addFavorite(station.id)
            } else {
                UserFavoriteService.removeFavorite(station.id)
            }
        }
    }
}

//extension ListItem: Hashable, Comparable {
//    
//    static func == (lhs: ListItem, rhs: ListItem) -> Bool {
//        return lhs.hashValue == rhs.hashValue
//    }
//    
//    func hash(into hasher: inout Hasher) {
//        hasher.combine(場站名稱)
//        hasher.combine(場站區域)
//        hasher.combine(場站總停車格)
//        hasher.combine(場站目前車輛數量)
//        hasher.combine(空位數量)
//        hasher.combine(地址)
//        hasher.combine(資料更新時間)
//        hasher.combine(我的最愛)
//    }
//    
//    static func < (lhs: ListItem, rhs: ListItem) -> Bool {
//        return lhs.場站名稱 > rhs.場站名稱
//    }
//}
