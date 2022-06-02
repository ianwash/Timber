//
//  PlaybackState.swift
//  OITU
//
//  Created by Ian Washabaugh on 6/1/22.
//

import Foundation

struct PlaybackState: Codable {
    let progress_ms: Int
    let is_playing: Bool
    let item: Item
}

struct Item: Codable {
    let uri: String
}
