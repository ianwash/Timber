//
//  Track.swift
//  OITU
//
//  Created by Ian Washabaugh on 5/21/22.
//

import Foundation

struct Track: Codable {
    let track: TrackInfo
}

struct TrackInfo: Codable {
    let album: AlbumInfo
    let name: String
    let uri: String
}

struct AlbumInfo: Codable {
    let images: [APIImage]
}


//{
//            "added_at": "2021-09-10T04:17:04Z",
//            "added_by": {
//                "external_urls": {
//                    "spotify": "https://open.spotify.com/user/ian_wash"
//                },
//                "href": "https://api.spotify.com/v1/users/ian_wash",
//                "id": "ian_wash",
//                "type": "user",
//                "uri": "spotify:user:ian_wash"
//            },
//            "is_local": false,
//            "primary_color": null,
//            "track": {
//                "album": {
//                    "album_type": "single",
//                    "artists": [
//                    ],
//                    "available_markets": [
//                        "AD",
//                    ],
//                    "external_urls": {
//                        "spotify": "https://open.spotify.com/album/632AmGXsZTyDa52gsJlDVF"
//                    },
//                    "href": "https://api.spotify.com/v1/albums/632AmGXsZTyDa52gsJlDVF",
//                    "id": "632AmGXsZTyDa52gsJlDVF",
//                    "images": [
//                        {
//                            "height": 640,
//                            "url": "https://i.scdn.co/image/ab67616d0000b2731ddeb0fc6dd26b427bdbda20",
//                            "width": 640
//                        },
//                        {
//                            "height": 300,
//                            "url": "https://i.scdn.co/image/ab67616d00001e021ddeb0fc6dd26b427bdbda20",
//                            "width": 300
//                        },
//                        {
//                            "height": 64,
//                            "url": "https://i.scdn.co/image/ab67616d000048511ddeb0fc6dd26b427bdbda20",
//                            "width": 64
//                        }
//                    ],
//                    "name": "You And I (Remixes)",
//                    "release_date": "2019-08-30",
//                    "release_date_precision": "day",
//                    "total_tracks": 4,
//                    "type": "album",
//                    "uri": "spotify:album:632AmGXsZTyDa52gsJlDVF"
//                },
//                "artists": [
//                    {
//                        "external_urls": {
//                            "spotify": "https://open.spotify.com/artist/4SqTiwOEdYrNayaGMkc7ia"
//                        },
//                        "href": "https://api.spotify.com/v1/artists/4SqTiwOEdYrNayaGMkc7ia",
//                        "id": "4SqTiwOEdYrNayaGMkc7ia",
//                        "name": "LÉON",
//                        "type": "artist",
//                        "uri": "spotify:artist:4SqTiwOEdYrNayaGMkc7ia"
//                    },
//                    {
//                        "external_urls": {
//                            "spotify": "https://open.spotify.com/artist/4vO1cl2ndGrUPSl6IYTHs6"
//                        },
//                        "href": "https://api.spotify.com/v1/artists/4vO1cl2ndGrUPSl6IYTHs6",
//                        "id": "4vO1cl2ndGrUPSl6IYTHs6",
//                        "name": "SAINT WKND",
//                        "type": "artist",
//                        "uri": "spotify:artist:4vO1cl2ndGrUPSl6IYTHs6"
//                    }
//                ],
//                "available_markets": [
//                    "AD",
//
//                ],
//                "disc_number": 1,
//                "duration_ms": 239000,
//                "episode": false,
//                "explicit": false,
//                "external_ids": {
//                    "isrc": "QMRSZ1901549"
//                },
//                "external_urls": {
//                    "spotify": "https://open.spotify.com/track/43vJhPJKdY2aLz7bODyrtg"
//                },
//                "href": "https://api.spotify.com/v1/tracks/43vJhPJKdY2aLz7bODyrtg",
//                "id": "43vJhPJKdY2aLz7bODyrtg",
//                "is_local": false,
//                "name": "You And I - SAINT WKND Remix",
//                "popularity": 49,
//                "preview_url": "https://p.scdn.co/mp3-preview/9806dd174f1b10767c2e43b94679592762983755?cid=325ebcb4d132478c886b5e19c5e19c39",
//                "track": true,
//                "track_number": 3,
//                "type": "track",
//                "uri": "spotify:track:43vJhPJKdY2aLz7bODyrtg"
//            },
//            "video_thumbnail": {
//                "url": null
//            }
//        },
