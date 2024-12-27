//
//  User.swift
//  
//
//  Created by Anton Tsikhanau on 25.07.23.
//

import Foundation

public struct User: Codable {
    public let id: Int
    public let email: String
    public let subscription: String?
    public let purchases: String?
    public let subscriptionEnd: String?
    public let confirmed: Bool
    public let sharing: String?
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
