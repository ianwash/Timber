//
//  InAppPlayView.swift
//  OITU
//
//  Created by Ian Washabaugh on 5/21/22.
//

import Foundation
import SwiftUI

struct InAppPlayView: View {
    @EnvironmentObject var apiCaller: APICaller
    @EnvironmentObject var user: User
    @State private var showInfo = false
    @State private var device: Device?
    @State private var moveOn = false
    var oneColumnGrid = [GridItem(.flexible())]
    let dimension = UIScreen.main.bounds.width - 80
    
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            if user.sourcePlaylist.images.count == 0 {
                EmptyView()
            }
            
            else {
                AsyncImage(url: URL(string: user.sourcePlaylist.images[0].url)) { phase in
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
                Text("Select a playback device.")
                    .foregroundColor(Color.green)
                    .font(.system(size: 28))
                    .fontWeight(.bold)
                    .scaledToFill()
                    .lineLimit(1)
                    .frame(width: dimension)
                    .minimumScaleFactor(0.5)
                    .padding([.bottom], 15)
                
                Group {
                    if let device = device {
                        Button(action: {
                            user.playbackDevice = device
                            moveOn = true
                            }, label: {
                                HStack {
                                    Text(device.name)
                                        .foregroundColor(Color.white)
                                        .font(.system(size: 18))
                                    Spacer()
                                }
                            })
                            .padding(10)
                            .fullScreenCover(isPresented: $moveOn) {
                                withAnimation {
                                    SwiperView()
                                }
                            }
                    }
                    
                    else {
                        Spacer()
                    }
                }
                    .frame(width: dimension, height: 50)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.white, lineWidth: 1)
                    )
                    .padding([.bottom], 10)
                
                
                HStack {
                    Button(action: {
                        loadData()
                        }, label: {
                            HStack {
                                Text("Refresh")
                                    .padding()
                                    .foregroundColor(Color.white)
                                    .cornerRadius(8)
                                    .font(.system(size: 16))
                            }
                            .frame(width: dimension / 2 - 5, height: 40)
//                            .overlay(
//                                        RoundedRectangle(cornerRadius: 10)
//                                            .stroke(Color.white, lineWidth: 1)
//                                    )
                        })
                    
                    Button(action: {
                        user.playbackDevice = Device(id: "", is_active: false, is_restricted: true, name: "", type: "")
                        moveOn = true
                        }, label: {
                            HStack {
                                Text("Skip")
                                    .padding()
                                    .foregroundColor(Color.white)
                                    .cornerRadius(8)
                                    .font(.system(size: 16))
                            }
                            .frame(width: dimension / 2 - 5, height: 40)
//                            .overlay(
//                                        RoundedRectangle(cornerRadius: 10)
//                                            .stroke(Color.white, lineWidth: 1)
//                                    )
                        })
                        .fullScreenCover(isPresented: $moveOn) {
                            withAnimation {
                                SwiperView()
                            }
                        }
                }
                
                HStack {
                    Spacer()
                    Button(action: {
                        withAnimation {
                            showInfo.toggle()
                        }
                        }, label: {
                            HStack {
                                Image(systemName: "questionmark.circle")
                                    .foregroundColor(Color.white)
                                    .font(.system(size: 13))
                                if (showInfo) {
                                    Text("Open Spotify, play something, refresh page.")
                                        .foregroundColor(Color.white)
                                        .font(.system(size: 13))
                                        .lineLimit(2)
                                        .frame(width: dimension, alignment: .leading)
                                }
                                else {
                                    Text("Device not listed?")
                                        .foregroundColor(Color.white)
                                        .font(.system(size: 13))
                                        .lineLimit(2)
                                        .frame(width: dimension, alignment: .leading)
                                }
                            }
                        })
                    Spacer()
                }
                .padding([.top], 40)
            }
        }
        .preferredColorScheme(.dark)
        .onAppear(perform: loadData)
    }
    
    func loadData() {
        apiCaller.getAvailablePlayers {result in
            DispatchQueue.main.async {
                switch result {
                case .success(let model):
                    device = model
                case .failure(let error):
                    print(error.localizedDescription)
                }
            }
        }
    }
}
