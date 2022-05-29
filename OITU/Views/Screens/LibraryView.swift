//
//  LibraryView.swift
//  OITU
//
//  Created by Ian Washabaugh on 5/16/22.
//

import SwiftUI

struct LibraryView: View {
    @EnvironmentObject var apiCaller: APICaller
    @EnvironmentObject var user: User
    @State var playlists = [Playlist]()
    @State var searchText = ""
    @State var filteredPlaylists = [Playlist]()
    @State var menuSheet = false
    
    var twoColumnGrid = [GridItem(.flexible()), GridItem(.flexible())]

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            NavigationView {
                ScrollView(.vertical, showsIndicators: false) {
                            LazyVGrid(columns: twoColumnGrid, spacing: 8) {
                                ForEach(filteredPlaylists, id: \.id) { playlist in
                                    Button(action: {
                                        // set the source playlist
                                        user.sourcePlaylist = playlist
//                                        test()
                                        menuSheet.toggle()
                                        }, label: {
                                            PlaylistCard(playlist: playlist)
                                        })
                                        .sheet(isPresented: $menuSheet) {
                                            PlaylistMenu()
                                        }
                                }
                            }
                            .padding(.horizontal)
                }.onAppear(perform: loadData)
                    .background(Color.black)
                    .navigationTitle(Text("Your Playlists"))
            }
            .searchable(text: $searchText)
            .onChange(of: playlists) { newValue in
                filteredPlaylists = newValue.filter({ playlist in
                    guard !searchText.isEmpty else {
                        return true
                    }
                    let fullPlaylistName = playlist.name.components(separatedBy: " ")
                    let lengthOfSearch = searchText.count
                    for word in fullPlaylistName {
                        if word.prefix(lengthOfSearch).lowercased() == searchText.lowercased() {
                            return true
                        }
                    }
                    return false
                })
            }
            .onChange(of: searchText) { newValue in
                filteredPlaylists = playlists.filter({ playlist in
                    guard !newValue.isEmpty else {
                        return true
                    }
                    let fullPlaylistName = playlist.name.components(separatedBy: " ")
                    let lengthOfSearch = searchText.count
                    for word in fullPlaylistName {
                        if word.prefix(lengthOfSearch).lowercased() == searchText.lowercased() {
                            return true
                        }
                    }
                    return false
                })
            }
        }
        .preferredColorScheme(.dark)
        .onAppear(perform: setUser)
    }
    
    func loadData() {
        apiCaller.getCurrentUserPlaylists {result in
            DispatchQueue.main.async {
                switch result {
                case .success(let model):
                    self.playlists = model
                    print(playlists)
                case .failure(let error):
                    print(error.localizedDescription)
                }
            }
        }
    }
    
    func setUser() {
        apiCaller.getCurrentUserProfile {result in
            DispatchQueue.main.async {
                switch result {
                case .success(let model):
                    user.userId = model.id
                case .failure(let error):
                    print(error.localizedDescription)
                }
            }
        }
    }
}


//[OITU.Playlist(id: "7jyKPb59reRqRNTUg8nBnX", images: [OITU.APIImage(url: "https://i.scdn.co/image/ab67706c0000bebbece3a181e417852bfa0c388f")], name: "january // february 2022"),
// OITU.Playlist(id: "2g8nmUOcHwHVsGhvElKTIi", images: [OITU.APIImage(url: "https://i.scdn.co/image/ab67706c0000bebb63f080d4f5f6a54591736f54")], name: "november // december 2021"),
// OITU.Playlist(id: "28EMMQy26ez3cs1e95vv7v", images: [OITU.APIImage(url: "https://i.scdn.co/image/ab67706c0000bebb9ff5cca7569189f8672ed31c")], name: "september // october 2021"),
// OITU.Playlist(id: "4s8qlr8GKTuXgSDvIs87eu", images: [OITU.APIImage(url: "https://i.scdn.co/image/ab67706c0000bebbfe90940b7ef4f72ad8343316")], name: "july // august 2021"),
// OITU.Playlist(id: "07thT9MSERoV2nO7paFpNT", images: [OITU.APIImage(url: "https://i.scdn.co/image/ab67706c0000bebbdd87bb1e4f0036c1917a1263")], name: "pov: we become farmers w no social media"),
// OITU.Playlist(id: "4fFoh9HcBLCysSEmHdxCmC", images: [OITU.APIImage(url: "https://i.scdn.co/image/ab67706c0000bebb8a4ab34285ddac9ba130bf28")], name: "pov: we’re scar jo dancing in a club"),
// OITU.Playlist(id: "3YJQaIAZhNMRAIq0oIet4k", images: [OITU.APIImage(url: "https://i.scdn.co/image/ab67706c0000bebb23a3406dc6e4540489119b32")], name: "may // june 2021"),
// OITU.Playlist(id: "05mcmt4HvMIAdV2RNFsWE1", images: [OITU.APIImage(url: "https://i.scdn.co/image/ab67706c0000bebb8379a3152db29cc40703b84f")], name: "march // april 2021"),
// OITU.Playlist(id: "0cHzF7GCqg57oP3HY5jvWL", images: [OITU.APIImage(url: "https://i.scdn.co/image/ab67706c0000bebb5a080c7c920e085631e495bd")], name: "january // february 2021 "),
// OITU.Playlist(id: "2wX0brsNx8zAsCGCMcoYfG", images: [OITU.APIImage(url: "https://i.scdn.co/image/ab67706c0000bebb3f1eb4d5806b6e1ca83c3efb")], name: "november // december 2020"),
// OITU.Playlist(id: "4m5wYJqeCOXBducUjYaqQJ", images: [OITU.APIImage(url: "https://mosaic.scdn.co/640/ab67616d0000b27301e0c6acdbc306e800fc3673ab67616d0000b2734500ea0b600b522c275ff116ab67616d0000b273b1d40f40ef2d158ce51b9235ab67616d0000b273fee5f7b500e33768601719bb"), OITU.APIImage(url: "https://mosaic.scdn.co/300/ab67616d0000b27301e0c6acdbc306e800fc3673ab67616d0000b2734500ea0b600b522c275ff116ab67616d0000b273b1d40f40ef2d158ce51b9235ab67616d0000b273fee5f7b500e33768601719bb"), OITU.APIImage(url: "https://mosaic.scdn.co/60/ab67616d0000b27301e0c6acdbc306e800fc3673ab67616d0000b2734500ea0b600b522c275ff116ab67616d0000b273b1d40f40ef2d158ce51b9235ab67616d0000b273fee5f7b500e33768601719bb")], name: "september // october 2020"),
// OITU.Playlist(id: "7AbfoAjJc2kMrmtA4w5uap", images: [OITU.APIImage(url: "https://i.scdn.co/image/ab67706c0000bebbde5291016cb3b8d1fa66ca17")], name: "july // august 2020"),
//OITU.Playlist(id: "3qW289mVxdC23xDYBOTEsu", images: [OITU.APIImage(url: "https://i.scdn.co/image/ab67706c0000bebb0fa6b54462d20c710e4b4f4e")], name: "may // june 2020"),
//OITU.Playlist(id: "56zEnAFtoceVFXRg2iUka2", images: [OITU.APIImage(url: "https://i.scdn.co/image/ab67706c0000bebb57947101e2fc9fe4303dccea")], name: "march // april 2020"),
//OITU.Playlist(id: "4gOFYuC9gsCjkdGDdizFVj", images: [OITU.APIImage(url: "https://i.scdn.co/image/ab67706c0000bebbca1a87a191ff828247dc0d72")], name: "january // february 2020"),
//OITU.Playlist(id: "6I8rhDL79gJ7XYobu9YgHW", images: [OITU.APIImage(url: "https://i.scdn.co/image/ab67706c0000bebb9410abfd6a946476c44049c5")], name: "Get Pitted Bro "),
//OITU.Playlist(id: "5vxiaTIF2uT3kX0TxGkSzU", images: [OITU.APIImage(url: "https://i.scdn.co/image/ab67706c0000bebbb27e91a342aa4d2ab7f8389b")], name: "Alt Rebooted"),
//OITU.Playlist(id: "5yikhbyrx1a1rYIFjZPRX2", images: [OITU.APIImage(url: "https://i.scdn.co/image/ab67706c0000bebb60d0541f4efb4c18c2c5e3cc")], name: "Life’s Greatest Hits"),
//OITU.Playlist(id: "7qcKKy4xemSMJBBSHAcp1r", images: [OITU.APIImage(url: "https://i.scdn.co/image/ab67706c0000bebb63091997e5c718ce3a2e85cc")], name: "Studying Anime Girl"),
//OITU.Playlist(id: "6hhlusjdeAUVH9LMhoqg6N", images: [OITU.APIImage(url: "https://mosaic.scdn.co/640/ab67616d0000b273039683d433f2be3bc44d903eab67616d0000b2734f5e1977bd05425f3ea1a2bfab67616d0000b273c7fd0a09950aa39556afdf05ab67616d0000b273e1851ad7ac4913fd5d2b1e83"), OITU.APIImage(url: "https://mosaic.scdn.co/300/ab67616d0000b273039683d433f2be3bc44d903eab67616d0000b2734f5e1977bd05425f3ea1a2bfab67616d0000b273c7fd0a09950aa39556afdf05ab67616d0000b273e1851ad7ac4913fd5d2b1e83"), OITU.APIImage(url: "https://mosaic.scdn.co/60/ab67616d0000b273039683d433f2be3bc44d903eab67616d0000b2734f5e1977bd05425f3ea1a2bfab67616d0000b273c7fd0a09950aa39556afdf05ab67616d0000b273e1851ad7ac4913fd5d2b1e83")], name: "alisha // ian throwbacks")]
