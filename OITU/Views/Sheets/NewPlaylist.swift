//
//  NewPlaylist.swift
//  OITU
//
//  Created by Ian Washabaugh on 6/5/22.
//

import Foundation
import SwiftUI

struct NewPlaylist: View {
    @EnvironmentObject var user: User
    @EnvironmentObject var apiCaller: APICaller
    let dimension = UIScreen.main.bounds.width - 80
    @State private var newName = ""
    @State private var currentUser = ""
    @State private var showingAlert = false
    @State private var moveOn = false
    
    
    init() {
        UITextView.appearance().backgroundColor = .clear
        UITextView.appearance().textDragInteraction?.isEnabled = false
        UITextView.appearance().isScrollEnabled  = false
    }
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            VStack {
                Image(systemName: "rectangle.and.pencil.and.ellipsis")
                    .foregroundColor(Color.green)
                    .font(.system(size: 50))
                    .padding([.bottom], 10)
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
                        .keyboardType(.twitter)
                        .onChange(of: newName) { _ in
                            if !newName.filter({ $0.isNewline }).isEmpty {
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
                            withAnimation {
                                InAppPlayView()
                            }
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
                .padding([.bottom], 30)
                
                Button(action: {
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
                        withAnimation {
                            InAppPlayView()
                        }
                    }
                })
            }
            .frame(width: dimension)
            .onAppear {
                newName = (user.sourcePlaylist.name) + " (Timber's Version)"
            }
            .onAppear {
                print("on appear: \(moveOn)")
            }
        }
    }
    
    func create() {
        apiCaller.createPlaylist(with: newName) {result in
            DispatchQueue.main.async {
                switch result {
                case .success(let model):
                    // set the destination playlist
                    user.destinationPlaylist = model
                    print(user.destinationPlaylist)
                    moveOn.toggle()
                case .failure(let error):
                    print(error.localizedDescription)
                    showingAlert = true
                }
            }
        }
    }
}
