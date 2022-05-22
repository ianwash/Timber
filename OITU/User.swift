//
//  User.swift
//  OITU
//
//  Created by Ian Washabaugh on 5/16/22.
//

import Foundation

class User: ObservableObject {
    var sourcePlaylist: Playlist
    var destinationPlaylist: Playlist
    var userId: String
    
    
    init() {
        self.sourcePlaylist = Playlist(id: "", images: [APIImage(url: "")], name: "", tracks: Tracks(href: ""))
        self.destinationPlaylist = Playlist(id: "", images: [], name: "", tracks: Tracks(href: ""))
        self.userId = ""
    }
    
}
