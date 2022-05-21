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
    let dimension = UIScreen.main.bounds.width - 80
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
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
            
            if useTemplate {
                VStack {
                    Text("Let's give that playlist a name.")
                        .foregroundColor(Color.white)
                        .font(.system(size: 20))
                        .fontWeight(.bold)
                        .opacity(0.7)
                    
                    TextEditor(text: $newName)
                        .onChange(of: newName) { _ in
                                    if !newName.filter({ $0.isNewline }).isEmpty {
                                        // handle submission
                                        print(newName)
                                    }
                                }
                        .foregroundColor(Color.green)
                        .font(.system(size: 18))
                        .frame(width: dimension, height: 50)
                        .padding([.bottom], 100)
                        .disableAutocorrection(true)
                    
                    Button(action: {
    //                    handle submission
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
                        })
                }
                .frame(width: dimension)
                .onAppear {
                    newName = (apiCaller.authManager.user?.sourcePlaylist.name ?? "") + " (Timber's Version)"
                }
            }
            
            else {
                VStack {
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
                            Image(systemName: "xmark.octagon")
                                .aspectRatio(contentMode: .fill)
                                .frame(width: dimension, height: dimension)
                                .clipped()
                        @unknown default:
                            Image(systemName: "xmark.octagon")
                                .aspectRatio(contentMode: .fill)
                                .frame(width: dimension, height: dimension)
                                .clipped()
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
                        print(Int(UIScreen.main.bounds.width))
    //                    showingSheet.toggle()
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
}

