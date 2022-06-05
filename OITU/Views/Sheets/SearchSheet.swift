//
//  SearchSheet.swift
//  OITU
//
//  Created by Ian Washabaugh on 6/4/22.
//

import SwiftUI

struct SearchSheet: View {
    @EnvironmentObject var user: User
    @EnvironmentObject var apiCaller: APICaller
    let dimension = UIScreen.main.bounds.width - 80
    @State private var searchString = ""
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
                Image(systemName: "person.2.fill")
                    .foregroundColor(Color.green)
                    .font(.system(size: 50))
                    .padding([.bottom], 10)
                
                Text("Go on, enter their user ID.")
                    .foregroundColor(Color.white)
                    .font(.system(size: 23))
                    .fontWeight(.bold)
                    .scaledToFill()
                    .lineLimit(1)
                    .frame(width: dimension)
                    .minimumScaleFactor(0.5)
                    .padding(3)
                Text("\(currentUser)")
                    .foregroundColor(Color.white)
                    .font(.system(size: 17))
                    .fontWeight(.bold)
                    .scaledToFill()
                    .lineLimit(1)
                    .frame(width: dimension)
                    .minimumScaleFactor(0.5)
                    .opacity(0.5)
                    .padding([.bottom], 20)
                VStack {
                    TextEditor(text: $searchString)
                        .onChange(of: searchString) { _ in
                            if !searchString.filter({ $0.isNewline }).isEmpty {
                                searchForUser()
                            }
                        }
                        .alert(isPresented: $showingAlert) {
                            Alert(
                                title: Text("Sorry!"),
                                message: Text("We were unable to find a user with that ID.")
                            )
                        }
                        .fullScreenCover(isPresented: $moveOn) {
                            withAnimation {
                                // show searched library
                                LibraryView(step: LibrarySteps.searchSource, userForPlaylists: searchString)
                            }
                        }
//                        .foregroundColor(Color.green)
                        .font(.system(size: 18))
                        .frame(minWidth: dimension, idealWidth: dimension, maxWidth: dimension, minHeight: 35, idealHeight: 35, maxHeight: 35)
                        .disableAutocorrection(true)
                        .autocapitalization(.none)
                        .padding(5)
                }
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.green, lineWidth: 1)
                )
                .padding([.bottom], 30)
                
                Button(action: {
                    // to do
                    searchForUser()
                }, label: {
                    HStack {
                        Text("Enter")
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
                            LibraryView(step: LibrarySteps.searchSource, userForPlaylists: searchString)
                        }
                    }
                })
            }
            .frame(width: dimension)
            .onAppear {
                // to do
                currentUser = "ex: '\(user.userId)'"
            }
        }
    }
    
    func searchForUser() {
        apiCaller.getOtherUserProfile(with: searchString) {result in
            DispatchQueue.main.async {
                switch result {
                case .success(let model):
                    user.searchedUser = model.display_name
                    moveOn = true
                case .failure(let error):
                    print("failed")
                    print(error.localizedDescription)
                    showingAlert = true
                }
            }
        }
    }
}
