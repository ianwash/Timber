//
//  Playlist.swift
//  OITU
//
//  Created by Ian Washabaugh on 5/16/22.
//

import Foundation

struct Playlist: Codable, Equatable {
    let id: String
    let images: [APIImage]
    let name: String
    
}
