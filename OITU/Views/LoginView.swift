//
//  LoginView.swift
//  OITU
//
//  Created by Ian Washabaugh on 5/16/22.
//

import SwiftUI

struct LoginView: View {
    @EnvironmentObject var apiCaller: APICaller
    // controls whether we show the login sheet or not
    @State private var showingSheet = false
    
    var body: some View {
        if let user = apiCaller.authManager.user {
            LibraryView()
                .environmentObject(user)
        }
        
        else {
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
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}
