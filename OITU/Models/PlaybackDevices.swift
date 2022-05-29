//
//  PlaybackDevices.swift
//  OITU
//
//  Created by Ian Washabaugh on 5/23/22.
//

import Foundation

struct PlaybackDevices: Codable {
    let devices: [Device]
}

struct Device: Codable {
    let id: String
    let is_active: Bool
    let is_restricted: Bool
    let name: String
    let type: String
}
