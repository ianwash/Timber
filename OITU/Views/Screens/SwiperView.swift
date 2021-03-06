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
    @State private var tracks = [Track]()
    @State private var currentURI: String?
    @State private var backHome = false
    @State private var isPlaying = true
    let dimensionX = UIScreen.main.bounds.width - 60
    let dimensionY = UIScreen.main.bounds.height - 300
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            VStack {
                // timber at the top with leave and help
                HStack {
                    Spacer()
                    Button(action: {
                        backHome.toggle()
                        }, label: {
                            Image(systemName: "xmark")
                                .foregroundColor(Color.green)
                                .font(.system(size: 25))
                                .padding([.trailing], 14)
                        })
                }
                Text("timber")
                    .fontWeight(.bold)
                    .foregroundColor(Color.green)
                    .font(.system(size: 30))
                    .multilineTextAlignment(.center)
//                    .padding(.vertical, 18.0)
                // card for the track
                ZStack {
                    VStack {
                        Text("You've reached the end!")
                            .foregroundColor(Color.green)
                            .font(.system(size: 20))
                            .fontWeight(.bold)
                        Button(action: {
//                            user.sourcePlaylist = Playlist(id: "", images: [], name: "", tracks: "", owner: <#T##Owner#>, uri: <#T##String#>)
//                            user.destinationPlaylist = ""
//                            user.playbackDevice = ""
                            backHome.toggle()
                            }, label: {
                                Text("Back to Library")
                                    .foregroundColor(Color.white)
                                    .font(.system(size: 18))
                            })
                            .frame(width: dimensionX - 100, height: 50)
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color.white, lineWidth: 1)
                            )
                            .fullScreenCover(isPresented: $backHome) {
                                withAnimation {
                                    LibraryView(step: LibrarySteps.userSource)
                                }
                            }
                    }
                    .frame(width: dimensionX, height: dimensionY)
                    .clipped()
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.green, lineWidth: 1)
                    )
                    .shadow(radius: 5)
                    
                    if !tracks.isEmpty {
                        ForEach(tracks, id: \.self.track.name) { track in
                            TrackCardSwipeable(track: track, onRemove: { removedTrack in
                                // remove track from array
                                self.tracks.removeLast()
                                if tracks.isEmpty {
                                    pause()
                                }
                                else {
                                    currentURI = tracks.last?.track.uri
                                    play()
                                }
                                // update current URI for playback
    //                                self.tracks.removeAll {$0 == removedTrack}
                            })
                        }
                    }
                }
                
                // rwd, play/pause, ffwd
                if user.playbackDevice.id != "" {
                    HStack {
                        // display rwd
                        Button(action: {
                            seek(with: false)
                            }, label: {
                                Image(systemName: "gobackward.10")
                                    .foregroundColor(Color.white)
                                    .font(.system(size: 25))
                            })
                        Spacer()
                        
                        // toggles playback
                        Button(action: {
                            if isPlaying {
                                pause()
                            }
                            else {
                                play()
                            }
                            }, label: {
                                // display pause
                                if isPlaying {
                                    Image(systemName: "pause.circle.fill")
                                        .foregroundColor(Color.green)
                                        .font(.system(size: 65))
                                }
                                // display play
                                else {
                                    Image(systemName: "play.circle.fill")
                                        .foregroundColor(Color.green)
                                        .font(.system(size: 65))
                                }
                            })
                       
                        
                        Spacer()
                        // display ffwd
                        Button(action: {
                            seek(with: true)
                            }, label: {
                                Image(systemName: "goforward.10")
                                    .foregroundColor(Color.white)
                                    .font(.system(size: 25))
                            })
                    }
                    .frame(width: dimensionX - 120, height: 100)
                }
            }
        }
        .onAppear(perform: loadData)
    }
    
    func loadData() {
        apiCaller.getPlaylistTracks(with: user.sourcePlaylist) {result in
            DispatchQueue.main.async {
                switch result {
                case .success(let model):
                    tracks = model.shuffled()
                    currentURI = tracks.last?.track.uri
                    play()
                case .failure(let error):
                    print(error.localizedDescription)
                }
            }
        }
    }
    
    func play() {
        if let currentURI = currentURI {
            apiCaller.playSong(with: user.playbackDevice, with: currentURI) {result in
                DispatchQueue.main.async {
                    switch result {
                    case .success( _):
                        isPlaying = true
                    case .failure(let error):
                        print(error.localizedDescription)
                    }
                }
            }
        }
    }
    
    func pause() {
        apiCaller.pauseSong(with: user.playbackDevice) {result in
            DispatchQueue.main.async {
                switch result {
                case .success( _):
                    isPlaying = false
                case .failure(let error):
                    print(error.localizedDescription)
                }
            }
        }
    }
    
    func seek(with forward: Bool) {
        apiCaller.getPlaybackState { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let model):
                    if forward {
                        seekWithPosition(with: model.progress_ms + 10000)
                    }
                    else {
                        seekWithPosition(with: model.progress_ms - 10000)
                    }
                case .failure(let error):
                    print(error.localizedDescription)
                }
            }
        }
    }
    
    func seekWithPosition(with newPosition: Int) {
        apiCaller.seekToPosition(with: user.playbackDevice, with: newPosition) { result in
            DispatchQueue.main.async {
                switch result {
                case .success( _):
                    print("went to new place")
                    print(user.playbackDevice.id)
                case .failure(let error):
                    print(error.localizedDescription)
                }
            }
        }
    }
}
