//
//  DynamicKeyContainer.swift
//  UbikeMap
//
//  Created by Kao Ming-Hsiu on 2019/11/25.
//  Copyright © 2019 ObiCat. All rights reserved.
//

import Foundation

/// 使用時實作 setId 方法
public protocol Identifiable {
    associatedtype Id
    mutating func setId(_ rawValue: String) throws
}


extension KeyedDecodingContainer {
    fileprivate func decodeWithIdKey<T>(_ type: T.Type, forKey key: KeyedDecodingContainer<K>.Key) throws -> T where T : Decodable & Identifiable {
        var item = try decode(T.self, forKey: key)
        try item.setId(key.stringValue)
        return item
    }
}


/// 轉換 "{"id_1": {...}, "id_2": {...}}" 結構為 [{"id": "id_1", ...}, {"id": "id_2", ...}]
public struct DynamicKeyContainer<E: Decodable & Identifiable>: Decodable {
    public let items: [E]
    private struct CustomCodingKeys: CodingKey {
        var stringValue: String
        init?(stringValue: String) {
            self.stringValue = stringValue
        }
        var intValue: Int?
        init?(intValue: Int) {
            return nil
        }
    }
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CustomCodingKeys.self)
        self.items = try container.allKeys.compactMap {
            try container.decodeWithIdKey(E.self, forKey: $0)
        }
    }
}
