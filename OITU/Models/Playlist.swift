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
    let tracks: Tracks
    let owner: Owner
    let uri: String
}

struct Tracks: Codable, Equatable {
    let href: String
}

struct Owner: Codable, Equatable {
    let id: String
}
