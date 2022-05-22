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
    @State private var showInfo = false
    let dimension = UIScreen.main.bounds.width - 80
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            VStack {
                Text("Select a playback device.")
                    .foregroundColor(Color.green)
                    .font(.system(size: 28))
                    .fontWeight(.bold)
                    .scaledToFill()
                    .lineLimit(1)
                    .frame(width: dimension)
                    .minimumScaleFactor(0.5)
                    .padding([.bottom], 10)
                
                HStack {
                    Button(action: {
                        withAnimation {
                            showInfo.toggle()
                        }
                        }, label: {
                            HStack {
                                Image(systemName: "questionmark.circle")
                                    .foregroundColor(Color.white)
                                    .font(.system(size: 14))
                                if (showInfo) {
                                    Text("Open Spotify, play something, refresh page.")
                                        .foregroundColor(Color.white)
                                        .font(.system(size: 14))
                                        .lineLimit(2)
                                        .frame(width: dimension, alignment: .leading)
                                }
                                else {
                                    Text("Device not listed?")
                                        .foregroundColor(Color.white)
                                        .font(.system(size: 14))
                                        .lineLimit(2)
                                        .frame(width: dimension, alignment: .leading)
                                }
                            }
                            .padding([.leading], 20)
                        })
                    Spacer()
                }
                
                Button(action: {
//                    handle submission
                    }, label: {
                        HStack {
                            Image(systemName: "arrow.counterclockwise")
                                .foregroundColor(Color.white)
                                .font(.system(size: 16))
                            Text("Refresh")
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
                
                Button(action: {
//                    handle submission
                    }, label: {
                        HStack {
                            Image(systemName: "arrow.right")
                                .foregroundColor(Color.white)
                                .font(.system(size: 16))
                            Text("Skip")
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
        }
        .preferredColorScheme(.dark)
    }
    
    func loadData() {
    }
}
