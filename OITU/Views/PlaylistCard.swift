//
//  PlaylistCard.swift
//  OITU
//
//  Created by Ian Washabaugh on 5/18/22.
//

import SwiftUI

struct PlaylistCard: View {
    var playlist: Playlist
    
    var body: some View {
        VStack(spacing: 0) {
            AsyncImage(url: URL(string: playlist.images[0].url), scale: 4.0) { phase in
                switch phase {
                case .success(let image):
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 175, height: 175)
                case .empty:
                    ProgressView()
                case .failure(let error):
                    let _ = print(error.localizedDescription)
                    EmptyView()
                @unknown default:
                    EmptyView()
                }
            }
            
            HStack {
                Spacer()
                Text("\(playlist.name) \n")
                    .lineLimit(2)
                    .foregroundColor(Color.black)
                    .font(.system(size: 18))
                Spacer()
            }
            .background(Color(.systemGray4))
        }
        .cornerRadius(15)
        .clipped()
    }
}

