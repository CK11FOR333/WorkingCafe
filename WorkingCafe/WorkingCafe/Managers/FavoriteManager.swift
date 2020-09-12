//
//  FavoriteManager.swift
//  0610
//
//  Created by Chris on 2019/8/8.
//  Copyright © 2019 user. All rights reserved.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore

let favoriteManager = FavoriteManager.sharedInstance

final class FavoriteManager {
    
    // MARK: - Singleton

    static let sharedInstance = FavoriteManager()

    // MARK: - Variables

//    var favoriteCafe: LocalCollection<Cafe>!

    func addFavoriteCafe(_ cafe: Cafe) {
        guard let currentUser = Auth.auth().currentUser else { return }



        let docRef = Firestore.firestore().collection("FavoriteCafes").document("\(cafe.name)")

        docRef.getDocument { (document, error) in
            if let document = document, document.exists {
//                let dataDescription = document.data().map(String.init(describing:)) ?? "nil"
//                log.debug("Document data: \(dataDescription)")

                docRef.updateData(["users": FieldValue.arrayUnion(["\(currentUser.uid)"])])
                log.debug("Add Favorite Document")
            } else {
                var cafe = cafe
                cafe.users.append(currentUser.uid)

                docRef.setData(cafe.dictionary)
                log.debug("Add Favorite Document")
            }
        }
    }

    func removeFavoriteCafe(_ cafe: Cafe) {
        guard let currentUser = Auth.auth().currentUser else { return }

        let docRef = Firestore.firestore().collection("FavoriteCafes").document("\(cafe.name)")

        docRef.updateData(["users":FieldValue.arrayRemove(["\(currentUser.uid)"])])
    }

    func isCafeCollected(_ cafe: Cafe, completion: @escaping (_ collected: Bool) -> Void) {
        guard let currentUser = Auth.auth().currentUser else {
            completion(false)
            return
        }

        let docRef = Firestore.firestore().collection("FavoriteCafes").document("\(cafe.name)")

        docRef.getDocument { (document, error) in
            if let document = document, document.exists {
//                let dataDescription = document.data().map(String.init(describing:)) ?? "nil"
//                log.debug("Document data: \(dataDescription)")f

                var isCollected = false
                if let cafe = Cafe(dictionary: document.data()!) {
                    for (_, user) in cafe.users.enumerated() {
                        if user == "\(currentUser.uid)" {
                            isCollected = true
                            log.debug("Cafe isCollected")
                        }
                    }
                }
                completion(isCollected)
                
            } else {
                completion(false)
            }
        }
    }

    func getCafes(_ completion: @escaping (_ cafes: [Cafe]) -> Void) {
        guard let currentUser = Auth.auth().currentUser else {
            completion([])
            return
        }

        let collection = Firestore.firestore().collection("FavoriteCafes")

        collection.getDocuments { (querySnapshot, error) in
            if let error = error {
                log.error("Getting Documents Error: \(error.localizedDescription)")
            } else {
                let cafes = querySnapshot?.documents.map { (document) -> Cafe in
                    if let cafe = Cafe(dictionary: document.data()) {
                        return cafe
                    } else {
                        // Don't use fatalError here in a real app.
                        fatalError("Unable to initialize type \(Cafe.self) with dictionary \(document.data())")
                    }
                }

                if let cafes = cafes {
                    var collectedCafes: [Cafe] = []

                    for (_, cafe) in cafes.enumerated() {
                        for (_, user) in cafe.users.enumerated() {
                            if user == "\(currentUser.uid)" {
                                collectedCafes.append(cafe)
                            }
                        }
                    }

                    completion(collectedCafes)
                } else {
                    completion([])
                }
            }
        }
    }

}
