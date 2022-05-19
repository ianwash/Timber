//
//  AuthManager.swift
//  OITU
//
//  Created by Ian Washabaugh on 5/16/22.
//

import Foundation

@MainActor
final class AuthManager: ObservableObject {

    private var refreshingToken = false
    
    @Published var user: User?

    struct Constants {
        static let clientID = ""
        static let clientSecret = ""
        static let tokenAPIURL = "https://accounts.spotify.com/api/token"
    }

    init() {
//      handle if the stored token is expired, show loading state eventually
        if let accessToken = accessToken, let refreshToken = refreshToken, let tokenExpirationDate = tokenExpirationDate {
            user = User()
        }
    }

    public var signInURL: URL? {
        let scopes = "user-read-private%20playlist-modify-public%20playlist-modify-private"
        let redirectURI = "https://www.spotify.com/us/"
        let base = "https://accounts.spotify.com/authorize"
        let string = "\(base)?response_type=code&client_id=\(Constants.clientID)&scope=\(scopes)&redirect_uri=\(redirectURI)&show_dialog=TRUE"
        return URL(string: string)
    }

    var isSignedIn: Bool {
        return accessToken != nil
    }

    private var accessToken: String? {
        get{
            return UserDefaults.standard.string(forKey: "access_token")
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "access_token")
        }
    }

    private var refreshToken: String? {
        get {
            return UserDefaults.standard.string(forKey: "refresh_token")
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "refresh_token")
        }
    }

    private var tokenExpirationDate: Date? {
        get {
            return UserDefaults.standard.object(forKey: "expirationDate") as? Date
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "expirationDate")
        }
    }

    private var shouldRefreshToken: Bool {
        guard let expirationDate = tokenExpirationDate else {
            return false
        }
        let currentDate = Date()
        let fiveMinutes: TimeInterval = 300
        // checks to see if there is less than five minutes left on token
        return currentDate.addingTimeInterval(fiveMinutes) >= expirationDate
    }

    public func exchangeCodeForToken(
        code: String
    ) async throws {
        guard let url = URL(string: Constants.tokenAPIURL) else {
            return
        }

        var components = URLComponents()
        components.queryItems = [
            URLQueryItem(name: "grant_type", value: "authorization_code"),
            URLQueryItem(name: "code", value: code),
            URLQueryItem(name: "redirect_uri", value: "https://www.spotify.com/us/")
        ]

        var request = URLRequest(url: url)

        request.httpMethod = "POST"

        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")

        request.httpBody = components.query?.data(using: .utf8)

        let basicToken = Constants.clientID + ":" + Constants.clientSecret
        // convert to data
        let dataFromToken = basicToken.data(using: .utf8)
        // make it base 64
        guard let base64String = dataFromToken?.base64EncodedString() else {
            // failed
            print("Failure to get the base 64")
            return
        }

        request.setValue("Basic \(base64String)", forHTTPHeaderField: "Authorization")
        
        let (data, _) = try await URLSession.shared.data(for: request, delegate: nil)
        let result = try JSONDecoder().decode(AuthResponse.self, from: data)
        cacheToken(result: result)
        user = User()
    }

    public func cacheToken(result: AuthResponse){
        UserDefaults.standard.setValue(result.access_token, forKey: "access_token")
        if let refresh_token = result.refresh_token {
            UserDefaults.standard.setValue(refresh_token, forKey: "refresh_token")
        }
        // calculates the date in which the token is no longer valid
        UserDefaults.standard.setValue(Date().addingTimeInterval(TimeInterval(result.expires_in)), forKey: "expirationDate")
    }

    private var onRefreshBlocks = [((String) -> Void)]()

    // gives us the access token to be used with API calls
    public func withValidToken(completion: @escaping (String) -> Void) {
        guard !refreshingToken else {
            // append completion once the refresh is done
            onRefreshBlocks.append(completion)
            return
        }
        if shouldRefreshToken {
            // refresh
            refreshIfNeeded { [weak self] success in
                if let token = self?.accessToken, success {
                    completion(token)
                }
            }
        }
        else if let token = accessToken {
            completion(token)
        }
    }

    public func refreshIfNeeded(completion: @escaping (Bool) -> Void){
        // makes sure we aren't already refreshing
        guard !refreshingToken else {
            return
        }

        guard shouldRefreshToken else {
            completion(true)
            return
        }

        guard let refreshToken = self.refreshToken else {
            return
        }

        guard let url = URL(string: Constants.tokenAPIURL) else {
            return
        }

        refreshingToken = true

        var components = URLComponents()
        components.queryItems = [
            URLQueryItem(name: "grant_type", value: "refresh_token"),
            URLQueryItem(name: "refresh_token", value: refreshToken)
        ]

        var request = URLRequest(url: url)

        request.httpMethod = "POST"

        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")

        request.httpBody = components.query?.data(using: .utf8)

        let basicToken = Constants.clientID + ":" + Constants.clientSecret
        // convert to data
        let data = basicToken.data(using: .utf8)
        // make it base 64
        guard let base64String = data?.base64EncodedString() else {
            // failed
            completion(false)
            print("Failure to get the base 64")
            return
        }

        request.setValue("Basic \(base64String)", forHTTPHeaderField: "Authorization")

        let task = URLSession.shared.dataTask(with: request) {[weak self] data, _, error in
            self?.refreshingToken = false
            // handles if something goes wrong
            guard let data = data,
                    error == nil else {
                completion(false)
                return
            }
            do {
                // decode the response
                let result = try JSONDecoder().decode(AuthResponse.self, from: data)
                self?.onRefreshBlocks.forEach { $0(result.access_token) }
                self?.onRefreshBlocks.removeAll()
                self?.cacheToken(result: result)
                completion(true)
            } catch {
                // failed
                print(error.localizedDescription)
                completion(false)
            }
        }
        // starts off API call
        task.resume()

    }
}
