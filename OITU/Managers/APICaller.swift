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
                with: URL(string: Constants.baseAPIURL + "/me/playlists?limit=50"),
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
                        let result = try JSONDecoder().decode(Playlists.self, from: data)
                        let resultPlaylists = result.items
                        completion(.success(resultPlaylists))
                    }
                    catch {
                        completion(.failure(error))
                    }
                }
                task.resume()
            }
    }

    // creates a new playlist
    @MainActor public func createPlaylist(with name: String, completion: @escaping (Result<Playlist, Error>) -> Void) {
        getCurrentUserProfile { [weak self] result in
            switch result {
            case .success(let profile):
                let urlString = Constants.baseAPIURL + "/users/\(profile.id)/playlists"
                
                self?.createRequest(
                    with: URL(string: urlString),
                    type: .POST)
                { baseRequest in
                    
                    var request = baseRequest
                    let json = [
                        "name": name
                    ]
                    request.httpBody = try? JSONSerialization.data(withJSONObject: json, options: .fragmentsAllowed)
                    let task = URLSession.shared.dataTask(with: request) { data,
                        _,
                        error in
                        guard let data = data, error == nil else {
                            completion(.failure(APIError.failedToGetData))
                            return
                        }

                        do {
                            let result = try JSONDecoder().decode(Playlist.self, from: data)
        //                        let result = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
        //                        print("trying to print user playlists")
        //                        print(result)
                            let resultPlaylist = result
                            completion(.success(resultPlaylist))
                        }
                        catch {
                                completion(.failure(error))
                        }
                    }
                    task.resume()
                }

            case .failure(_):
                print("failed")
            }
        }
    }
    
    
    // gets playlist tracks
    @MainActor public func getPlaylistTracks(with playlist: Playlist, completion: @escaping (Result<[Track], Error>) -> Void) {
            createRequest(
                with: URL(string: playlist.tracks.href),
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
                        let result = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
                        print(result)
//                        let result = try JSONDecoder().decode(Playlists.self, from: data)
//                        let resultPlaylists = result.items
//                        completion(.success(resultPlaylists))
                    }
                    catch {
                        completion(.failure(error))
                    }
                }
                task.resume()
            }
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
            print("token: \(token)")
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
