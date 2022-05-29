//
//  APICaller.swift
//  OITU
//
//  Created by Ian Washabaugh on 5/16/22.
//

import Foundation
import Combine

final class APICaller: ObservableObject {
    private var cancellables = Set<AnyCancellable>()
    @Published var authManager: AuthManager

    init(authManager: AuthManager) {
        self.authManager = authManager
        authManager.objectWillChange.sink { _ in
            self.objectWillChange.send()
        }
        .store(in: &cancellables)
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
        // using the href to get full data, avoiding the 50 song cap. Now the cap is 100 songs
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
                        let result = try JSONDecoder().decode(PlaylistTrack.self, from: data)
                        let resultTracks = result.items
                        print(resultTracks)
                        completion(.success(resultTracks))
                    }
                    catch {
                        completion(.failure(error))
                    }
                }
                task.resume()
            }
    }
    

//     adds track to playlist
    // returns JSON
    @MainActor public func addTrackToPlaylist(with track: Track, with playlist: Playlist, completion: @escaping (Result<String, Error>) -> Void) {
        createRequest(
            with: URL(string: Constants.baseAPIURL + "/playlists/\(playlist.id)/tracks"),
            type: .POST)
        { baseRequest in
            var request = baseRequest
            let json = [
                "uris": [track.track.uri]
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
                    _ = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
                    completion(.success("Added track."))
                }
                catch {
                    completion(.failure(error))
                }
            }
            task.resume()
        }
    }
    
    // deletes track from playlist
    // returns JSON
    @MainActor public func deleteTrackFromPlaylist(with track: Track, with playlist: Playlist, completion: @escaping (Result<String, Error>) -> Void) {
        createRequest(
            with: URL(string: Constants.baseAPIURL + "/playlists/\(playlist.id)/tracks"),
            type: .DELETE)
        { baseRequest in
            var request = baseRequest
            let json = [
                "uris": [track.track.uri]
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
                    _ = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
                    completion(.success("Removed track."))
                }
                catch {
                    completion(.failure(error))
                }
            }
            task.resume()
        }
    }
    
    // gets the current devices to play from
    @MainActor public func getAvailablePlayers(completion: @escaping (Result<[Device], Error>) -> Void) {
            createRequest(
                with: URL(string: Constants.baseAPIURL + "/me/player/devices"),
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
                        let result = try JSONDecoder().decode(PlaybackDevices.self, from: data)
                        print("here is the result: \(result)")
                        let resultDevices = result.devices
                        completion(.success(resultDevices))
                    }
                    catch {
                        completion(.failure(error))
                    }
                }
                task.resume()
            }
    }
    
    
    // starts the playback on a device
    // endpoint reutrns string?
    @MainActor public func playSong(with track: Track, with device: Device, completion: @escaping (Result<String, Error>) -> Void) {
        createRequest(
            with: URL(string: Constants.baseAPIURL + "/player/play?device_id=\(device.id)"),
            type: .PUT)
        { baseRequest in
            var request = baseRequest
            let json = [
                "context_uri": track.track.uri,
//                "position_ms": 30000
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
                    _ = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
                    completion(.success("Playing track."))
                }
                catch {
                    completion(.failure(error))
                }
            }
            task.resume()
        }
    }
    
    
    // pause playback
    // endpoint returns string??
    @MainActor public func pauseSong(with device: Device, completion: @escaping (Result<String, Error>) -> Void) {
        createRequest(
            with: URL(string: Constants.baseAPIURL + "/player/pause?device_id=\(device.id)"),
            type: .PUT)
        { baseRequest in
            let task = URLSession.shared.dataTask(with: baseRequest) { data,
                _,
                error in
                guard let data = data, error == nil else {
                    completion(.failure(APIError.failedToGetData))
                    return
                }

                do {
                    _ = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
                    completion(.success("Paused track."))
                }
                catch {
                    completion(.failure(error))
                }
            }
            task.resume()
        }
    }
    
    // seek to position in song
    // endpoint returns string?
    @MainActor public func seekToPosition(with device: Device, with position: Int, completion: @escaping (Result<String, Error>) -> Void) {
        createRequest(
            with: URL(string: Constants.baseAPIURL + "/player/seek?device_id=\(device.id)?position_ms=\(position)"),
            type: .PUT)
        { baseRequest in
            let task = URLSession.shared.dataTask(with: baseRequest) { data,
                _,
                error in
                guard let data = data, error == nil else {
                    completion(.failure(APIError.failedToGetData))
                    return
                }

                do {
                    _ = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
                    completion(.success("Paused track."))
                }
                catch {
                    completion(.failure(error))
                }
            }
            task.resume()
        }
    }


    // basis for requests

    enum HTTPMethod: String {
        case GET
        case POST
        case DELETE
        case PUT
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
