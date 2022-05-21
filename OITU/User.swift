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
    
    
    init() {
        self.sourcePlaylist = Playlist(id: "", images: [APIImage(url: "")], name: "")
        self.destinationPlaylist = Playlist(id: "", images: [], name: "")
    }
    
}
