//
//  PlaylistMenu.swift
//  OITU
//
//  Created by Ian Washabaugh on 5/20/22.
//

import SwiftUI

struct PlaylistMenu: View {
    @EnvironmentObject var apiCaller: APICaller
    @EnvironmentObject var user: User
    @State var useTemplate = false
    @State private var newName = ""
    @State private var moveOn = false
    @State private var showingAlert = false
    @State private var playlist: Playlist?
    let dimension = UIScreen.main.bounds.width - 80
    var destination: Bool
    
    var body: some View {
        ZStack {
            if let playlist = playlist {
                Color.black.ignoresSafeArea()
                if playlist.images.count == 0 {
                    EmptyView()
                }
                
                else {
                    AsyncImage(url: URL(string: playlist.images[0].url)) { phase in
                        switch phase {
                        case .success(let image):
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .blur(radius: 20)
                                .opacity(0.4)
                        case .empty:
                            ProgressView()
                        case .failure:
                            EmptyView()
                        @unknown default:
                            EmptyView()
                        }
                    }
                }
                VStack {
                    if playlist.images.count == 0 {
                        Image(systemName: "x.square")
                            .aspectRatio(contentMode: .fill)
                            .frame(width: dimension, height: dimension)
                    }
                    
                    else {
                        AsyncImage(url: URL(string: playlist.images[0].url), scale: 4.0) { phase in
                            switch phase {
                            case .success(let image):
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: dimension, height: dimension)
                                    .clipped()
                            case .empty:
                                ProgressView()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: dimension, height: dimension)
                                    .clipped()
                            case .failure:
                                Image(systemName: "x.square")
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: dimension, height: dimension)
                                    .clipped()
                            @unknown default:
                                Image(systemName: "x.square")
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: dimension, height: dimension)
                                    .clipped()
                            }
                        }
                    }
                    
                    HStack {
                        Text(playlist.name)
                            .foregroundColor(Color.white)
                            .font(.system(size: 25))
                            .fontWeight(.bold)
                        Spacer()
                    }
                    .frame(width: dimension, height: 50)
                    .padding(.bottom)
                    
                    Button(action: {
                        withAnimation {
                            if destination {
                                user.destinationPlaylist = playlist
                            }
                            else {
                                user.sourcePlaylist = playlist
                            }
                            moveOn.toggle()
                        }
                    }, label: {
                        HStack {
                            Text("Select")
                                .padding()
                                .foregroundColor(Color.green)
                                .cornerRadius(8)
                                .font(.system(size: 16))
                        }
                        .frame(width: 150, height: 40)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.green, lineWidth: 1)
                        )
                        .fullScreenCover(isPresented: $moveOn) {
    //                        withAnimation {
                                if destination {
                                    InAppPlayView()
                                }
                                else {
                                    LibraryView(step: LibrarySteps.destination)
                                }
    //                        }
                        }
                    })
                }
            }
        }
        .preferredColorScheme(.dark)
        .onAppear {
            if destination {
                playlist = user.destinationPlaylist
            }
            else {
                playlist = user.sourcePlaylist
            }
        }
    }
}

