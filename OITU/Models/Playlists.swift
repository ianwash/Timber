//
//  Playlists.swift
//  OITU
//
//  Created by Ian Washabaugh on 5/16/22.
//

import Foundation

struct Playlists: Codable {
    let items: [Playlist]
    let total: Int
}
