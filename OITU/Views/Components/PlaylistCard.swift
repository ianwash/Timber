//
//  PlaylistCard.swift
//  OITU
//
//  Created by Ian Washabaugh on 5/18/22.
//

import SwiftUI
import Foundation

struct PlaylistCard: View {
    @State private var text = ""
    @State private var subtext = ""
    var playlist: Playlist?
    var button: NavigationButtons?
    let dimension = (UIScreen.main.bounds.width / 2) - 30
    
    var body: some View {
        VStack(spacing: 0) {
            if let playlist = playlist {
                if playlist.images.count == 0 {
                    Image(systemName: "x.square")
                        .aspectRatio(contentMode: .fill)
                        .frame(width: dimension, height: dimension)
                        .clipped()
                        .foregroundColor(Color.white)
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
                        case .failure:
                            AsyncImage(url: URL(string: playlist.images[0].url), scale: 4.0) { phase in
                                if let image = phase.image {
                                    image
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                        .frame(width: dimension, height: dimension)
                                        .clipped()
                                } else {
                                    Image(systemName: "x.square")
                                        .aspectRatio(contentMode: .fill)
                                        .frame(width: dimension, height: dimension)
                                        .clipped()
                                        .foregroundColor(Color.white)
                                }
                            }
                        @unknown default:
                            Image(systemName: "x.square")
                                .aspectRatio(contentMode: .fill)
                                .frame(width: dimension, height: dimension)
                                .clipped()
                                .foregroundColor(Color.white)
                        }
                    }
                }
            }
            
            // showing the search
            else {
                Group {
                    switch button {
                    case .search:
                        Image(systemName: "magnifyingglass")
                    case .home:
                        Image(systemName: "music.note.house")
                    case .new:
                        Image(systemName: "plus.square")
                    case .edit:
                        Image(systemName: "pencil")
                    default:
                        EmptyView()
                    }
                }
                .foregroundColor(Color.green)
                .font(.system(size: 30))
                .frame(width: dimension, height: dimension)
                .background(Color.white)
                .clipped()
            }
            Group {
                if let playlist = playlist {
                    VStack {
                        HStack {
                            Text("\(playlist.name)")
                                .lineLimit(1)
                                .foregroundColor(Color.white)
                                .font(.system(size: 15))
                                .padding([.top], 8)
                            Spacer()
                        }
                        HStack {
                            Text("\(playlist.owner.id)")
                                .lineLimit(1)
                                .foregroundColor(Color.white)
                                .font(.system(size: 13))
                                .opacity(0.7)
                                .padding([.bottom], 8)
                            Spacer()
                        }
                    }
                    .background(Color.black)
                    .frame(width: dimension)
//                    .padding([.top], 8)
                }
                
                else {
                    VStack {
                        HStack {
//                            Spacer()
                            Text(text)
                                .lineLimit(1)
                                .foregroundColor(Color.white)
                                .font(.system(size: 15))
                                .padding([.top], 8)
                                .padding([.leading], 3)
                            Spacer()
                        }
                        HStack {
                            Text(subtext)
                                .lineLimit(1)
                                .foregroundColor(Color.white)
                                .font(.system(size: 13))
                                .opacity(0.7)
                                .padding([.bottom], 8)
                                .padding([.leading], 3)
                            Spacer()
                        }
                    }
                    .onAppear(perform: makeButtonText)
                    .background(Color.green)
                    .frame(width: dimension)
//                    .padding([.top], 8)
                }
            }
        }
        .clipped()
        .padding(10)
    }
    
    func makeButtonText() {
        switch button {
        case .search:
            text = "Find a Friend's"
            subtext = "not stealing, inspiration"
        case .home:
            text = "Back to Home"
            subtext = "yours were better"
        case .edit:
            text = "Edit Directly"
            subtext = "just a trim"
        case .new:
            text = "Create New Playlist"
            subtext = "love a fresh start"
        default:
            text = ""
            subtext = ""
        }
    }
}

