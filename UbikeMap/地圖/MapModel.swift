//
//  MapModels.swift
//  UbikeMap
//
//  Created by Kao Ming-Hsiu on 2019/11/25.
//  Copyright © 2019 ObiCat. All rights reserved.
//

import Foundation
import MapKit

protocol MapItemType where Self: MKAnnotation {
    var id: String {get}
    var 我的最愛: Bool { get set }
}

class MapItem: NSObject ,MapItemType {
    
    let station: UbikeStation
    
    var id: String {
        return station.id
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
    
    let coordinate: CLLocationCoordinate2D
    
    var title: String? {
        return "🚴‍♀️ \(station.sna)"
    }
    
    var subtitle: String? {
        return "🚴‍♀️ \(station.snaen)"
    }
    
    var 總停車格: Int {
        return station.tot
    }
    var 目前車輛數量: Int {
        return station.sbi
    }
    var 空位數量: Int {
        return station.tot - station.sbi
    }        
    
    init(station: UbikeStation) {
        self.station = station
        let coordinate = CLLocationCoordinate2D(latitude: station.lat, longitude: station.lng)
        self.coordinate = coordinate
    }
}
