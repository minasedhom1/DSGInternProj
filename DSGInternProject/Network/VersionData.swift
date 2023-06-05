//
//  VersionData.swift
//  DSGInternProject
//
//  Created by Mina Sedhom on 6/2/23.
//

import Foundation


struct LookupResponse: Codable {
    let results: [AppDetails]
}

struct AppDetails: Codable {
    let version: String
}

// DTO
//struct Beer {
//    var id: Int
//    var name: String
//    var brewery: Brewery
//}
//
//struct Brewery {
//    var id: String
//    var name: String
//}
//
//extension Beer: DecodableFromDTO {
//    struct DTO: Decodable {
//        var id: Int
//        var name: String
//        var brewery_id: String
//        var brewery_name: String
//    }
//
//    init(from dto: DTO) {
//        id = dto.id
//        name = dto.name
//        brewery = Brewery(id: dto.brewery_id, name: dto.brewery_name)
//    }
//}
//
//protocol DecodableFromDTO {
//    associatedtype DTO: Decodable
//    init(from dto: DTO) throws
//}
//
//extension JSONDecoder {
//    func decode<T>(_ type: T.Type, from data: Data) throws -> T where T : DecodableFromDTO {
//        try T(from: decode(T.DTO.self, from: data))
//    }
//}
