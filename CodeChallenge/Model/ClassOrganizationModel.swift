//
//  ClassOrganizationModel.swift
//  CodeChallenge
//
//  Created by Daniel James on 7/30/21.
//

import Foundation

/* Codable inherits both encodable and decodable */

struct ClassOrganizationModel: Codable, Hashable {
    /* All Entries must contain id */
    var id: String
    /* Optional values for which the API could return */
    var name: String?
    var description: String?
    var created: String?
    var folder_id: String?
    
    /*Additional Parameters for Organizing*/
    var timeIntervalSince: Double?
}

