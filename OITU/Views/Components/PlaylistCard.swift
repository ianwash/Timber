//
//  PlaylistCard.swift
//  OITU
//
//  Created by Ian Washabaugh on 5/18/22.
//

import SwiftUI
import Foundation

struct PlaylistCard: View {
    var playlist: Playlist
    let dimension = (UIScreen.main.bounds.width / 2) - 30
    
    var body: some View {
        VStack(spacing: 0) {
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
            
            VStack {
                HStack {
                    Text("\(playlist.name)")
                        .lineLimit(1)
                        .foregroundColor(Color.white)
                        .font(.system(size: 15))
                    Spacer()
//                    Text("\n")
                }
                HStack {
                    Text("\(playlist.owner.id)")
                        .lineLimit(1)
                        .foregroundColor(Color.white)
                        .font(.system(size: 13))
                        .opacity(0.7)
                    Spacer()
//                    Text("\n")
                }
            }
            .background(Color.black)
            .frame(width: dimension)
            .padding([.top], 8)
        }
        .clipped()
        .padding(10)
    }
}

