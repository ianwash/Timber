//
//  SwiperView.swift
//  OITU
//
//  Created by Ian Washabaugh on 5/28/22.
//

import Foundation
import SwiftUI

struct SwiperView: View {
    @EnvironmentObject var apiCaller: APICaller
    @EnvironmentObject var user: User
    @State var tracks = [Track]()
    @State var currentURI = ""
    @State var emptyStack = false
    let dimensionX = UIScreen.main.bounds.width - 100
    let dimensionY = UIScreen.main.bounds.height - 200
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            VStack {
                // timber at the top with leave and help
                Text("timber")
                    .fontWeight(.bold)
                    .foregroundColor(Color.green)
                    .font(.system(size: 30))
                    .multilineTextAlignment(.center)
                    .padding(.vertical, 18.0)
                // card for the track
                if tracks.count != 0 {
                    ZStack {
                        ForEach(tracks, id: \.self.track.name) { track in
                            TrackCardSwipeable(track: track, onRemove: { removedTrack in
                                // remove track from array
                                self.tracks.removeLast()
                                if tracks.isEmpty {
                                    emptyStack = true
                                }
                                // update current URI for playback
                                currentURI = tracks.last?.track.uri ?? ""
//                                self.tracks.removeAll {$0 == removedTrack}
                            })
                        }
                    }
                }
                
                // if the stack is empty, show success and button to go back home
                
                // rwd, play/pause, ffwd
            }
        }
        .onAppear(perform: loadData)
    }
    
    func loadData() {
        apiCaller.getPlaylistTracks(with: user.sourcePlaylist) {result in
            DispatchQueue.main.async {
                switch result {
                case .success(let model):
                    if model.isEmpty {
                        emptyStack = true
                        return
                    }
                    else {
                        tracks = model.reversed()
                        currentURI = tracks.last?.track.uri ?? ""
                    }
                case .failure(let error):
                    print(error.localizedDescription)
                }
            }
        }
    }
}
