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
    @State private var playlists = [Playlist]()
    @State private var searchText = ""
    @State private var filteredPlaylists = [Playlist]()
    @State private var menuSheet = false
    @State private var searchSheet = false
    @State private var showingAlert = false
    @State private var goHome = false
    @State private var goPlayer = false
    @State private var newPlaylistSheet = false
    @State private var selectedPlaylist: Playlist?
    var step: LibrarySteps
    
    var userForPlaylists: String?
    let dimension = (UIScreen.main.bounds.width / 2) - 30
    
    var twoColumnGrid = [GridItem(.flexible()), GridItem(.flexible())]
    
    @State private var text = ""

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            Text(text)
            NavigationView {
                ScrollView(.vertical, showsIndicators: false) {
                            LazyVGrid(columns: twoColumnGrid, spacing: 8) {
                                if filteredPlaylists.count == playlists.count {
                                    switch step {
                                    // show the search
                                    case .userSource:
                                        Button(action: {
                                            searchSheet.toggle()
                                            }, label: {
                                                PlaylistCard(button: NavigationButtons.search)
                                            })
                                            .sheet(isPresented: $searchSheet) {
                                                SearchSheet()
                                            }
                                    // show the home
                                    case .searchSource:
                                        Button(action: {
                                            goHome.toggle()
                                            }, label: {
                                                PlaylistCard(button: NavigationButtons.home)
                                            })
                                            .fullScreenCover(isPresented: $goHome) {
                                                withAnimation {
                                                    LibraryView(step: LibrarySteps.userSource)
                                                }
                                            }
                                    case .destination:
                                        Button(action: {
                                            // new playlist
                                            newPlaylistSheet.toggle()
                                            }, label: {
                                                PlaylistCard(button: NavigationButtons.new)
                                            })
                                            .sheet(isPresented: $newPlaylistSheet) {
                                                NewPlaylist()
                                            }
                                        if user.sourcePlaylist.owner.id == user.userId {
                                            Button(action: {
                                                // edit directly
                                                user.destinationPlaylist = user.sourcePlaylist
                                                goPlayer.toggle()
                                                }, label: {
                                                    PlaylistCard(button: NavigationButtons.edit)
                                                })
                                                .fullScreenCover(isPresented: $goPlayer) {
                                                    withAnimation {
                                                        InAppPlayView()
                                                    }
                                                }
                                        }
                                    }
                                }
                                
                                ForEach(filteredPlaylists, id: \.id) { playlist in
                                    Button(action: {
                                        if step == .destination {
                                            user.destinationPlaylist = playlist
                                        }
                                        else {
                                            user.sourcePlaylist = playlist
                                        }
                                        menuSheet.toggle()
                                        }, label: {
                                            PlaylistCard(playlist: playlist)
                                        })
                                        .sheet(isPresented: $menuSheet) {
                                            if step == .destination {
                                                PlaylistMenu(destination: true)
                                            }
                                            else {
                                                PlaylistMenu(destination: false)
                                            }
                                        }
                                }
                            }
                            .padding(.horizontal)
                }
                    .background(Color.black)
                    .navigationTitle(
                        Text(text)
                    )
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
        .alert(isPresented: $showingAlert) {
                Alert(
                    title: Text("Sorry!"),
                    message: Text("We were unable to fetch the playlists.")
                )
            }
    }
    
    func loadData() {
        switch step {
        case .userSource:
            text = "Select a Playlist"
            apiCaller.getUserPlaylists(with: user.userId) {result in
                DispatchQueue.main.async {
                    switch result {
                    case .success(let model):
                        self.playlists = model
                    case .failure(let error):
                        print(error.localizedDescription)
                    }
                }
            }
        case .searchSource:
            text = "\(user.searchedUser)'s Playlists"
            if let userForPlaylists = userForPlaylists {
                apiCaller.getUserPlaylists(with: userForPlaylists) {result in
                    DispatchQueue.main.async {
                        switch result {
                        case .success(let model):
                            self.playlists = model
                        case .failure(let error):
                            print(error.localizedDescription)
                        }
                    }
                }
            }
        case .destination:
            text = "Choose a Destination"
            apiCaller.getUserPlaylists(with: user.userId) {result in
                DispatchQueue.main.async {
                    print("here is the user id: \(user.userId)")
                    switch result {
                    case .success(let model):
                        self.playlists = model.filter {$0.owner.id == user.userId}
                        print(playlists)
                    case .failure(let error):
                        print(error.localizedDescription)
                    }
                }
            }
        }
    }
    
    func setUser() {
        switch step {
        case .userSource:
            apiCaller.getCurrentUserProfile {result in
                DispatchQueue.main.async {
                    switch result {
                    case .success(let model):
                        user.userId = model.id
                        loadData()
                        return
                    case .failure(let error):
                        print(error.localizedDescription)
                    }
                }
            }
        default:
            loadData()
        }
    }
}
