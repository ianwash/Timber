//
//  UserProfile.swift
//  OITU
//
//  Created by Ian Washabaugh on 5/16/22.
//

import Foundation

struct UserProfile: Codable {
    let display_name: String
    let id: String
    let images: [APIImage]
}
