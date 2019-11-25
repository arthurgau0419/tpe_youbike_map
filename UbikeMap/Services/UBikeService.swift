//
//  UBikeService.swift
//  UbikeMap
//
//  Created by Kao Ming-Hsiu on 2019/11/25.
//  Copyright © 2019 ObiCat. All rights reserved.
//

import Moya

class UBikeService: TargetType {
    
    var baseURL: URL {
        guard let url = URL.init(string: "https://tcgbusfs.blob.core.windows.net/blobyoubike") else { fatalError() }
        return url
    }
    
    var path: String = "/YouBikeTP.gz"
    
    var method: Method = .get
    
    var sampleData: Data {
        guard let filePath = Bundle.main.path(forResource: "YouBikeTP", ofType: nil) else {
            fatalError()
        }
        let fileURL = URL(fileURLWithPath: filePath)
        do {
            let fileData = try Data(contentsOf: fileURL)
            return fileData
        } catch {
            fatalError()
        }
    }
    
    var task: Task = .requestPlain
    
    var headers: [String : String]? = nil
    
    
}

extension UBikeService {
    static var dateFormatter: DateFormatter {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyyMMddHHmmss"
        return dateFormatter
    }
    
    static var decoder: JSONDecoder {
        let jsonDecoder = JSONDecoder()
        jsonDecoder.dateDecodingStrategy = .formatted(dateFormatter)
        return jsonDecoder
    }
}

