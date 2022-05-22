//
//  PlaylistTrack.swift
//  OITU
//
//  Created by Ian Washabaugh on 5/22/22.
//

import Foundation

struct PlaylistTrack: Codable {
    let items: [Track]
    let total: Int
}
