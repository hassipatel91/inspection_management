//
//  AuthenticationModel.swift
//  InspectionManagementApp
//
//  Created by Sukh Vilas on 22/08/24.
//

import Foundation

// Authentication request
struct AuthenticationReq: Codable {
    let email: String
    let password: String
}
