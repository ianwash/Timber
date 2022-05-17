//
//  APICaller.swift
//  OITU
//
//  Created by Ian Washabaugh on 5/16/22.
//

import Foundation

final class APICaller: ObservableObject {
    var authManager: AuthManager

    init(authManager: AuthManager) {
        self.authManager = authManager
    }

    struct Constants {
        static let baseAPIURL = "https://api.spotify.com/v1"
    }

    enum APIError: Error {
        case failedToGetData
    }

    @MainActor public func getCurrentUserProfile(completion: @escaping (Result<UserProfile, Error>) -> Void) {
        createRequest(
            with: URL(string: Constants.baseAPIURL + "/me"),
            type: .GET)
        { baseRequest in
            let task = URLSession.shared.dataTask(with: baseRequest) { data,
                _,
                error in
                guard let data = data, error == nil else {
                    completion(.failure(APIError.failedToGetData))
                    return
                }

                do {
                    let result = try JSONDecoder().decode(UserProfile.self, from: data)
//                    let result = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
                    print("trying to print user profile")
                    print(result)
                    completion(.success(result))
                }
                catch {
                    completion(.failure(error))
                }
            }
            task.resume()
        }
    }

    // gets current user playlists
    @MainActor public func getCurrentUserPlaylists(completion: @escaping (Result<[Playlist], Error>) -> Void) {
            createRequest(
                with: URL(string: Constants.baseAPIURL + "/me/playlists"),
                type: .GET)
            { baseRequest in
                let task = URLSession.shared.dataTask(with: baseRequest) { data,
                    _,
                    error in
                    guard let data = data, error == nil else {
                        completion(.failure(APIError.failedToGetData))
                        return
                    }

                    do {
//                        let result = try JSONDecoder().decode(UserProfile.self, from: data)
                        let result = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
                        print("trying to print user playlists")
                        print(result)
//                        completion(.success(result))
                    }
                    catch {
//                        completion(.failure(error))
                    }
                }
                task.resume()
            }
    }

    // creates a new playlist
    public func createPlaylist(with name: String) {

    }

    // adds track to playlist
//    public func addTrackToPlaylist(track: AudioTrack) {
//
//    }


    // basis for requests

    enum HTTPMethod: String {
        case GET
        case POST
    }
    
    @MainActor private func createRequest( with url: URL?, type: HTTPMethod, completion: @escaping (URLRequest) -> Void) {
        self.authManager.withValidToken { token in
            guard let apiURL = url else {
                return
            }
            var request = URLRequest(url: apiURL)
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            request.httpMethod = type.rawValue
            request.timeoutInterval = 30
            completion(request)
        }
    }
}
