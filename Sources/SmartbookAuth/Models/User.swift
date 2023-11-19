//
//  User.swift
//  
//
//  Created by Anton Tsikhanau on 25.07.23.
//

import Foundation

public struct User: Decodable {
    let id: Int
    let email: String
    let subscription: String?
    let purchases: String?
    let subscriptionEnd: String?
    let confirmed: Bool
    let sharing: String?
}

extension User {
    init?(registrationResponse: RegistrationResponse) {
        guard let id = registrationResponse.id else {
            return nil
        }
        self.id = id
        email = registrationResponse.email
        subscription = registrationResponse.subscription
        purchases = registrationResponse.purchases
        subscriptionEnd = registrationResponse.subscriptionEnd
        confirmed = registrationResponse.confirmed
        sharing = registrationResponse.sharing
    }
}
