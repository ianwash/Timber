//
//  AuthView.swift
//  OITU
//
//  Created by Ian Washabaugh on 5/16/22.
//

import SwiftUI
import WebKit

struct AuthView: UIViewRepresentable {
    @EnvironmentObject var apiCaller: APICaller
    class Coordinator: NSObject, WKNavigationDelegate {
        var parent: AuthView
        
        init(parent: AuthView) {
            self.parent = parent
        }
        
        func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
            guard let url = webView.url else {
                return
            }
            // swap code for access token
            guard let code = URLComponents(string: url.absoluteString)?.queryItems?.first(where: { $0.name == "code" })?.value else {
                return
            }
            
            // hides redirect page
            webView.isHidden = true
            
            Task {
                do {
                    try await parent.apiCaller.authManager.exchangeCodeForToken(code: code)
                    await MainActor.run(body: {
                        parent.showingSheet = false
                    })
                } catch {
                    print(error.localizedDescription)
                }
            }
        }
    }
    @Binding var showingSheet: Bool
    @EnvironmentObject var authManager: AuthManager
    var url: URL
     
        func makeUIView(context: Context) -> WKWebView {
            let webView = WKWebView()
            webView.navigationDelegate = context.coordinator
            return webView
        }
     
        func updateUIView(_ webView: WKWebView, context: Context) {
            let request = URLRequest(url: url)
            webView.load(request)
        }
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(parent: self)
    }
}
