//
//  TrackCardSwipeable.swift
//  OITU
//
//  Created by Ian Washabaugh on 5/29/22.
//

import Foundation
import SwiftUI

struct TrackCardSwipeable: View {
    @EnvironmentObject var apiCaller: APICaller
    @EnvironmentObject var user: User
    @State private var translation: CGSize = .zero
    var track: Track
    private var onRemove: (_ track: Track) -> Void
    let dimensionX = UIScreen.main.bounds.width - 60
    let dimensionY = UIScreen.main.bounds.height - 300
    
    init(track: Track, onRemove: @escaping (_ track: Track) -> Void) {
            self.track = track
            self.onRemove = onRemove
        }
    
    enum SwipeHVDirection: String {
        case left, right, none
    }
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            if track.track.album.images.count == 0 {
                Image(systemName: "x.square")
                    .aspectRatio(contentMode: .fill)
                    .blur(radius: 50)
                    .opacity(0.6)
            }
            
            else {
                AsyncImage(url: URL(string: track.track.album.images[0].url), scale: 4.0) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .clipped()
                            .blur(radius: 50)
                            .opacity(0.6)
                    case .empty:
                        ProgressView()
                            .aspectRatio(contentMode: .fill)
                            .clipped()
                    case .failure:
                        Image(systemName: "x.square")
                            .aspectRatio(contentMode: .fill)
                            .clipped()
                            .blur(radius: 50)
                            .opacity(0.6)
                    @unknown default:
                        Image(systemName: "x.square")
                            .aspectRatio(contentMode: .fill)
                            .clipped()
                            .blur(radius: 50)
                            .opacity(0.6)
                    }
                }
            }
            VStack {
                if track.track.album.images.count == 0 {
                    Image(systemName: "x.square")
                        .aspectRatio(contentMode: .fill)
                        .frame(width: dimensionX - 50, height: dimensionX - 50)
                        .clipped()
                        .padding([.top, .bottom], 20)
                }
                
                else {
                    AsyncImage(url: URL(string: track.track.album.images[0].url), scale: 4.0) { phase in
                        switch phase {
                        case .success(let image):
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: dimensionX - 50, height: dimensionX - 50)
                                .clipped()
                                .padding([.top, .bottom], 20)
                        case .empty:
                            ProgressView()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: dimensionX - 50, height: dimensionX - 50)
                                .clipped()
                                .padding([.top, .bottom], 20)
                        case .failure:
                            Image(systemName: "x.square")
                                .aspectRatio(contentMode: .fill)
                                .frame(width: dimensionX - 50, height: dimensionX - 50)
                                .clipped()
                                .padding([.top, .bottom], 20)
                        @unknown default:
                            Image(systemName: "x.square")
                                .aspectRatio(contentMode: .fill)
                                .frame(width: dimensionX - 50, height: dimensionX - 50)
                                .clipped()
                                .padding([.top, .bottom], 20)
                        }
                    }
                }
                
                HStack {
                    Text(track.track.name)
                        .foregroundColor(Color.green)
                        .font(.system(size: 20))
                        .fontWeight(.bold)
                        .lineLimit(1)
                    Spacer()
                }
                .frame(width: dimensionX - 50, alignment: .leading)
                
                HStack {
                    Text(track.track.artists[0].name)
                        .foregroundColor(Color.white)
                        .font(.system(size: 17))
                        .fontWeight(.bold)
                        .lineLimit(1)
                    Spacer()
                }
                .frame(width: dimensionX - 50, alignment: .leading)
                
            }
        }
        .preferredColorScheme(.dark)
        .frame(width: dimensionX, height: dimensionY)
        .clipped()
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color.green, lineWidth: 1)
        )
        .shadow(radius: 5)
        .animation(.interactiveSpring())
        .offset(x: self.translation.width, y: 0)
        .rotationEffect(.degrees(Double(self.translation.width / dimensionX) * 25), anchor: .bottom)
        .gesture(
            DragGesture()
                .onChanged { value in
                    self.translation = value.translation
                }.onEnded { value in
                    self.translation = .zero
                    let direction = self.detectDirection(value: value)
                    if direction == .left && abs(self.getGesturePercentage(UIScreen.main.bounds.width, from: value)) > 0.5 {
                        removeTrack()
                        self.onRemove(self.track)
                    }
                    if direction == .right && abs(self.getGesturePercentage(UIScreen.main.bounds.width, from: value)) > 0.5 {
                        addTrack()
                        self.onRemove(self.track)
                    }
                }
        )
    }
    
    func detectDirection(value: DragGesture.Value) -> SwipeHVDirection {
        if value.startLocation.x < value.location.x - (dimensionX/2) {
            return .right
        }
        if value.startLocation.x > value.location.x + (dimensionX/2) {
            return .left
        }
        return .none
    }
    
    private func getGesturePercentage(_ width: Double, from gesture: DragGesture.Value) -> CGFloat {
        gesture.translation.width / width
    }
    
    func removeTrack() {
        print("removing track")
        if user.sourcePlaylist != user.destinationPlaylist {
            return
        }
        else {
            apiCaller.deleteTrackFromPlaylist(with: track, with: user.destinationPlaylist) { result in
                DispatchQueue.main.async {
                    switch result {
                    case .success(_):
                        // update array of tracks?
                        return
                    case .failure(let error):
                        print(error.localizedDescription)
                        return
                    }
                }
            }
        }
    }
    
    func addTrack() {
        print("adding track")
        if user.sourcePlaylist == user.destinationPlaylist {
            return
        }
        else {
            apiCaller.addTrackToPlaylist(with: track, with: user.destinationPlaylist) { result in
                DispatchQueue.main.async {
                    switch result {
                    case .success(_):
                        // update array of tracks?
                        return
                    case .failure(let error):
                        print(error.localizedDescription)
                        return
                    }
                }
            }
        }
    }
}
