//
//  MovieDataModel.swift
//  DiagnalMovies
//
//  Created by Abhishek on 29/04/20.
//  Copyright © 2020 Abhishek. All rights reserved.
//

import Foundation
struct MovieApiResponse {
    let responseDetails : PageResponse
}
extension MovieApiResponse:Decodable{
    enum ResponseCodingKeys: String, CodingKey {
        case responseDetails = "page"
    }
    
    init(from decoder: Decoder) throws {
        let movieContainer = try decoder.container(keyedBy: ResponseCodingKeys.self)
        responseDetails = try movieContainer.decode(PageResponse.self, forKey: .responseDetails)
    }
}
struct PageResponse {
    let title: String
    let totalItems: String
    let currentPage: String
    let pageSize: String
    let contentItem : Content
}

extension PageResponse: Decodable {
    
    private enum MoviePageResponseCodingKeys: String, CodingKey {
        case title
        case totalItems = "total-content-items"
        case currentPage = "page-num"
        case pageSize = "page-size"
        case conentItem = "content-items"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: MoviePageResponseCodingKeys.self)
        
        title = try container.decode(String.self, forKey: .title)
        totalItems = try container.decode(String.self, forKey: .totalItems)
        currentPage = try container.decode(String.self, forKey: .currentPage)
        pageSize = try container.decode(String.self, forKey: .pageSize)
       contentItem = try container.decode(Content.self, forKey: .conentItem)
        
    }
}

struct Content {
    let content: [Movie]
    
}
extension Content: Decodable{
    enum ContentCodingKeys: String, CodingKey {
        case content
    }
    init(from decoder: Decoder) throws {
        let contentContainer = try decoder.container(keyedBy: ContentCodingKeys.self)
        content = try contentContainer.decode([Movie].self, forKey: .content)
    }
}
struct Movie {
    let name: String
    let posterImage: String
}

extension Movie: Decodable {
    
    enum MovieCodingKeys: String, CodingKey {
        case name
        case posterImage = "poster-image"
    }
    
    init(from decoder: Decoder) throws {
        let movieContainer = try decoder.container(keyedBy: MovieCodingKeys.self)
        posterImage = try movieContainer.decode(String.self, forKey: .posterImage)
        name = try movieContainer.decode(String.self, forKey: .name)
    }
}
