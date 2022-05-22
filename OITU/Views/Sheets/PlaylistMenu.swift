//
//  PlaylistMenu.swift
//  OITU
//
//  Created by Ian Washabaugh on 5/20/22.
//

import SwiftUI

struct PlaylistMenu: View {
    init() {
            UITextView.appearance().backgroundColor = .clear
        }
    
    @EnvironmentObject var apiCaller: APICaller
    @State var useTemplate = false
    @State private var newName = ""
    @State private var moveOn = false
    @State private var showingAlert = false
    let dimension = UIScreen.main.bounds.width - 80
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            if apiCaller.authManager.user?.sourcePlaylist.images.count == 0 {
                EmptyView()
            }
            
            else {
                AsyncImage(url: URL(string: apiCaller.authManager.user?.sourcePlaylist.images[0].url ?? "")) { phase in
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
            
            if useTemplate {
                VStack {
                    Text("Let's give that playlist a name.")
                        .foregroundColor(Color.white)
                        .font(.system(size: 23))
                        .fontWeight(.bold)
                        .scaledToFill()
                        .lineLimit(1)
                        .frame(width: dimension)
                        .minimumScaleFactor(0.5)
                    VStack {
                        TextEditor(text: $newName)
                            .onChange(of: newName) { _ in
                                        if !newName.filter({ $0.isNewline }).isEmpty {
                                            // TO DO
                                            create()
                                        }
                                    }
                            .alert(isPresented: $showingAlert) {
                                    Alert(
                                        title: Text("Sorry!"),
                                        message: Text("We were unable to make a playlist with that name.")
                                    )
                                }
                            .fullScreenCover(isPresented: $moveOn) {
                                InAppPlayView()
                            }
                            .foregroundColor(Color.green)
                            .font(.system(size: 18))
                            .frame(minWidth: dimension, idealWidth: dimension, maxWidth: dimension, minHeight: 30, idealHeight: 30, maxHeight: 60)
                            .disableAutocorrection(true)
                            .padding(5)
                    }
                    .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color.green, lineWidth: 1)
                            )
                    .opacity(0.7)
                    .padding([.bottom], 30)
                    
                    Button(action: {
    //                    TO DO
                        create()
                        }, label: {
                            HStack {
                                Text("Done")
                                    .padding()
                                    .foregroundColor(Color.white)
                                    .cornerRadius(8)
                                    .font(.system(size: 16))
                            }
                            .frame(width: 150, height: 40)
                            .overlay(
                                        RoundedRectangle(cornerRadius: 10)
                                            .stroke(Color.white, lineWidth: 1)
                                    )
                            .fullScreenCover(isPresented: $moveOn) {
                                InAppPlayView()
                            }
                        })
                }
                .frame(width: dimension)
                .onAppear {
                    newName = (apiCaller.authManager.user?.sourcePlaylist.name ?? "") + " (Timber's Version)"
                }
            }
            
            else {
                VStack {
                    if apiCaller.authManager.user?.sourcePlaylist.images.count == 0 {
                        Image(systemName: "x.square")
                            .aspectRatio(contentMode: .fill)
                            .frame(width: dimension, height: dimension)
                    }
                    
                    else {
                        AsyncImage(url: URL(string: apiCaller.authManager.user?.sourcePlaylist.images[0].url ?? ""), scale: 4.0) { phase in
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
                        Text(apiCaller.authManager.user?.sourcePlaylist.name ?? "")
                            .foregroundColor(Color.white)
                            .font(.system(size: 20))
                            .fontWeight(.bold)
                        Spacer()
                    }
                        .frame(width: dimension, height: 50)
                        .padding(.bottom)
                    
                    Button(action: {
                        // set the destination playlist
                        apiCaller.authManager.user?.destinationPlaylist = apiCaller.authManager.user?.sourcePlaylist ?? Playlist(id: "", images: [], name: "", tracks: Tracks(href: ""))
                        // move on to nect page
                        moveOn = true
                        }, label: {
                            HStack {
                                Image(systemName: "square.and.pencil")
                                    .foregroundColor(Color.green)
                                    .font(.system(size: 20))
                                Text("Edit directly")
                                    .padding()
                                    .foregroundColor(Color.white)
                                    .cornerRadius(8)
                                    .font(.system(size: 18))
                                Spacer()
                            }
                            .frame(width: dimension, height: 40)
                        })
                        .fullScreenCover(isPresented: $moveOn) {
                            InAppPlayView()
                        }
                    
                    Button(action: {
                        withAnimation {
                            useTemplate.toggle()
                        }
                        }, label: {
                            HStack {
                                Image(systemName: "plus.square")
                                    .foregroundColor(Color.green)
                                    .font(.system(size: 20))
                                Text("Use as template")
                                    .padding()
                                    .foregroundColor(Color.white)
                                    .cornerRadius(8)
                                    .font(.system(size: 18))
                                Spacer()
                            }
                            .frame(width: dimension, height: 40)
                        })
                    
                }
            }
        }
        .preferredColorScheme(.dark)
    }
    
    func create() {
        apiCaller.createPlaylist(with: newName) {result in
                       DispatchQueue.main.async {
                           switch result {
                           case .success(let model):
                               apiCaller.authManager.user?.destinationPlaylist = model
                               print(apiCaller.authManager.user?.destinationPlaylist ?? "none found")
                               moveOn = true
                           case .failure(let error):
                               print(error.localizedDescription)
                               showingAlert = true
                           }
                       }
                   }
    }
}
