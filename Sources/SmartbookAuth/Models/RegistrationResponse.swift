//
//  RegistrationResponse.swift
//  
//
//  Created by Anton Tsikhanau on 8.08.23.
//

import Foundation

struct RegistrationResponse: Decodable {
    let id: Int?
    let email: String
    let subscription: String?
    let purchases: String?
    let subscriptionEnd: String?
    let confirmed: Bool
    let sharing: String?
}
