//
//  Cafe.swift
//  0610
//
//  Created by Chris on 2019/7/1.
//  Copyright © 2019 user. All rights reserved.
//

import Foundation
import Firebase

struct Cafe {

    var id: String
    var mrt: String
    var url: String
    var city: String
    var name: String
    var socket: String
    var address: String
    var longitude: String
    var latitude: String
    var limited_time: String
    var standing_desk: String

    var wifi: Int
    var seat: Int
    var quiet: Int
    var tasty: Int
    var cheap: Int
    var music: Int

    var users: [String] = []

    var dictionary: [String: Any] {
        return [
            "id": id,
            "mrt": mrt,
            "url": url,
            "city": city,
            "name": name,
            "socket": socket,
            "address": address,
            "longitude": longitude,
            "latitude": latitude,
            "limited_time": limited_time,
            "standing_desk": standing_desk,

            "wifi": wifi,
            "seat": seat,
            "quiet": quiet,
            "tasty": tasty,
            "cheap": cheap,
            "music": music,
            "users": users
        ]
    }

    init(id: String,
         mrt: String,
         url: String,
         city: String,
         name: String,
         socket: String,
         address: String,
         longitude: String,
         latitude: String,
         limited_time: String,
         standing_desk: String,
         wifi: Int,
         seat: Int,
         quiet: Int,
         tasty: Int,
         cheap: Int,
         music: Int,
         users: [String]) {

        self.id = id
        self.mrt = mrt
        self.url = url
        self.city = city
        self.name = name
        self.socket = socket
        self.address = address
        self.longitude = longitude
        self.latitude = latitude
        self.limited_time = limited_time
        self.standing_desk = standing_desk
        self.wifi = wifi
        self.seat = seat
        self.quiet = quiet
        self.tasty = tasty
        self.cheap = cheap
        self.music = music
        self.users = users
    }

}

extension Cafe: DocumentSerializable {

    init?(dictionary: [String : Any]) {
        guard
            let id = dictionary["id"] as? String,
            let mrt = dictionary["mrt"] as? String,
            let url = dictionary["url"] as? String,
            let city = dictionary["city"] as? String,
            let name = dictionary["name"] as? String,
            let socket = dictionary["socket"] as? String,
            let address = dictionary["address"] as? String,
            let longitude = dictionary["longitude"] as? String,
            let latitude = dictionary["latitude"] as? String,
            let limited_time = dictionary["limited_time"] as? String,
            let standing_desk = dictionary["standing_desk"] as? String,

            let wifi = dictionary["wifi"] as? Int,
            let seat = dictionary["seat"] as? Int,
            let quiet = dictionary["quiet"] as? Int,
            let tasty = dictionary["tasty"] as? Int,
            let cheap = dictionary["cheap"] as? Int,
            let music = dictionary["music"] as? Int,
            let users = dictionary["users"] as? [String]
        else {
            return nil
        }

        self.init(id: id,
                  mrt: mrt,
                  url: url,
                  city: city,
                  name: name,
                  socket: socket,
                  address: address,
                  longitude: longitude,
                  latitude: latitude,
                  limited_time: limited_time,
                  standing_desk: standing_desk,
                  wifi: wifi,
                  seat: seat,
                  quiet: quiet,
                  tasty: tasty,
                  cheap: cheap,
                  music: music,
                  users: users)
    }
    
}
