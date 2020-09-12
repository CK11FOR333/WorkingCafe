//
//  User.swift
//  0610
//
//  Created by Chris on 2019/8/8.
//  Copyright © 2019 user. All rights reserved.
//

import Foundation
import Firebase

struct User {

    var providerID: String
    var uid: String
    var displayName: String
    var photoURLstr: String
    var email: String
    var phoneNumber: String

    var dictionary: [String: Any] {
        return [
            "providerID": providerID,
            "uid": uid,
            "displayName": displayName,
            "photoURLstr": photoURLstr,
            "email": email,
            "phoneNumber": phoneNumber,
        ]
    }

}

extension User: DocumentSerializable {

    init?(dictionary: [String : Any]) {
        guard
            let providerID = dictionary["providerID"] as? String,
            let uid = dictionary["uid"] as? String,
            let displayName = dictionary["displayName"] as? String,
            let photoURLstr = dictionary["photoURLstr"] as? String,
            let email = dictionary["email"] as? String,
            let phoneNumber = dictionary["phoneNumber"] as? String
        else {
            return nil
        }

        self.init(providerID: providerID,
                  uid: uid,
                  displayName: displayName,
                  photoURLstr: photoURLstr,
                  email: email,
                  phoneNumber: phoneNumber)
    }

}
