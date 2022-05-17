//
//  LibraryView.swift
//  OITU
//
//  Created by Ian Washabaugh on 5/16/22.
//

import SwiftUI

struct LibraryView: View {
    @EnvironmentObject var authManager: AuthManager
    var body: some View {
        Button(/*@START_MENU_TOKEN@*/"Button"/*@END_MENU_TOKEN@*/) {
            authManager.apiCaller?.getCurrentUserPlaylists {result in
                DispatchQueue.main.async {
                    print(result)
                }
            }
        }
    }
    
}

struct LibraryView_Previews: PreviewProvider {
    static var previews: some View {
        LibraryView()
    }
}
