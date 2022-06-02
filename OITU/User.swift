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
    var playbackDevice: Device
    
    init() {
        self.sourcePlaylist = Playlist(id: "", images: [APIImage(url: "")], name: "", tracks: Tracks(href: ""), owner: Owner(id: ""), uri: "")
        self.destinationPlaylist = Playlist(id: "", images: [], name: "", tracks: Tracks(href: ""), owner: Owner(id: ""), uri: "")
        self.userId = ""
        self.playbackDevice = Device(id: "", is_active: false, is_restricted: true, name: "", type: "")
    }
    
}
