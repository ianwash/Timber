//
//  LoginView.swift
//  OITU
//
//  Created by Ian Washabaugh on 5/16/22.
//

import SwiftUI

struct LoginView: View {
    @EnvironmentObject var apiCaller: APICaller
    // controls whether we show the auth sheet or not
    @State private var showingSheet = false
    
    var body: some View {
        if let user = apiCaller.authManager.user {
            LibraryView(step: .userSource)
                .environmentObject(user)
        }
        
        else {
            ZStack {
                Color.black.ignoresSafeArea()
                VStack {
                    Text("timber")
                        .fontWeight(.bold)
                        .foregroundColor(Color.green)
                        .font(.system(size: 56))
                        .multilineTextAlignment(.center)
                        .padding(.vertical, 18.0)
                    Button(action: {
                        showingSheet.toggle()
                        }, label: {
                            Text("Log in with Spotify")
                                .fontWeight(.bold)
                                .padding()
                                .background(Color.green)
                                .foregroundColor(Color.white)
                                .cornerRadius(8)
                                .font(.system(size: 18))
                        })
                        .sheet(isPresented: $showingSheet) {
                            AuthView(showingSheet: $showingSheet, url: apiCaller.authManager.signInURL!)
                        }
                }
            }
            .preferredColorScheme(.dark)
        }
    }
    
}

