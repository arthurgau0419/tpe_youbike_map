//
//  UBikeServiceModel.swift
//  UbikeMap
//
//  Created by Kao Ming-Hsiu on 2019/11/25.
//  Copyright © 2019 ObiCat. All rights reserved.
//

import Foundation

struct UbikeStation: Decodable {
    var id: String!
    let aren: String
    let ar: String
    let sna: String
    let mday: Date
    let tot: Int
    let lat: Double
    let lng: Double
    let sbi: Int
    let sareaen: String
    let bemp: Int
    let sno: String
    let sarea: String
    let snaen: String
    let act: Int
    
    enum CodingKeys: String, CodingKey {
        case id = "id"
        case aren = "aren"
        case ar = "ar"
        case sna = "sna"
        case mday = "mday"
        case tot = "tot"
        case lat = "lat"
        case lng = "lng"
        case sbi = "sbi"
        case sareaen = "sareaen"
        case bemp = "bemp"
        case sno = "sno"
        case sarea = "sarea"
        case snaen = "snaen"
        case act = "act"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        aren = try container.decode(String.self, forKey: .aren)
        ar = try container.decode(String.self, forKey: .ar)
        sna = try container.decode(String.self, forKey: .sna)
        mday = try container.decode(Date.self, forKey: .mday)
        tot = Int(try container.decode(String.self, forKey: .tot)) ?? 0        
        lat = Double(try container.decode(String.self, forKey: .lat).replacingOccurrences(of: " ", with: "")) ?? 0
        lng = Double(try container.decode(String.self, forKey: .lng).replacingOccurrences(of: " ", with: "")) ?? 0
        sbi = Int(try container.decode(String.self, forKey: .sbi) ) ?? 0
        sareaen = try container.decode(String.self, forKey: .sareaen)
        bemp = Int(try container.decode(String.self, forKey: .bemp)) ?? 0
        sno = try container.decode(String.self, forKey: .sno)
        sarea = try container.decode(String.self, forKey: .sarea)
        snaen = try container.decode(String.self, forKey: .snaen)
        act = Int(try container.decode(String.self, forKey: .act)) ?? 0
    }
}

extension UbikeStation: Identifiable {
    typealias Id = String
    
    mutating func setId(_ rawValue: String) throws {
        self.id = rawValue
    }
}
