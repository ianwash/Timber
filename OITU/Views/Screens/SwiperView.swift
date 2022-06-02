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
                Text("timber")
                    .fontWeight(.bold)
                    .foregroundColor(Color.green)
                    .font(.system(size: 30))
                    .multilineTextAlignment(.center)
                    .padding(.vertical, 18.0)
                // card for the track
                ZStack {
                    VStack {
                        Text("You've reached the end!")
                            .foregroundColor(Color.green)
                            .font(.system(size: 20))
                            .fontWeight(.bold)
                        Button(action: {
                            backHome = true
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
                                    LibraryView()
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
                                    queue()
                                }
                                // update current URI for playback
    //                                self.tracks.removeAll {$0 == removedTrack}
                            })
                        }
                    }
                }
                
                // if the stack is empty, show success and button to go back home
                
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
                    tracks = model.reversed()
                    currentURI = tracks.last?.track.uri
                    queue()
                case .failure(let error):
                    print(error.localizedDescription)
                }
            }
        }
    }
    
    //play the current song
    func playCurrentSong() {
        skip()
    }
    
    func skip() {
        apiCaller.skipToNext(with: user.playbackDevice) {result in
            DispatchQueue.main.async {
                switch result {
                case .success( _):
                    // to do
                    print("skipped track")
                    // check to see if it is what we want
                    songCheck()
                case .failure(let error):
                    print(error.localizedDescription)
                }
            }
        }
    }
    
    func songCheck() {
        apiCaller.getPlaybackState { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let model):
                    isPlaying = model.is_playing
                    if model.item.uri != currentURI && !tracks.isEmpty {
                        print("model uri: \(model.item.uri)")
                        print("current uri: \(String(describing: currentURI))")
                        skip()
                    }
                case .failure(let error):
                    print(error.localizedDescription)
                }
            }
        }
    }
    
    func queue() {
        if let currentURI = currentURI {
            apiCaller.addToQueue(with: user.playbackDevice, with: currentURI) {result in
                DispatchQueue.main.async {
                    switch result {
                    case .success( _):
                        // to do
                        print("added to queue")
                        skip()
                    case .failure(let error):
                        print(error.localizedDescription)
                    }
                }
            }
        }
    }
    
    func play() {
        apiCaller.playSong(with: user.playbackDevice) {result in
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
