//
//  DataHandler.swift
//  CodeChallenge
//
//  Created by Daniel James on 7/30/21.
//

import Foundation

extension ViewController {
    func fetchClassFile(forName name: String) -> [ClassOrganizationModel]? {
        do {
            if let bundlePath = Bundle.main.path(forResource: name,
                                                 ofType: "json"),
               let jsonData = try String(contentsOfFile: bundlePath).data(using: .utf8) {
                return self.parse(jsonData: jsonData)
            }
        } catch let err as NSError {
            print("decode error", err.localizedDescription)
        }
        return nil
    }
    
    func parse(jsonData: Data) -> [ClassOrganizationModel]? {
        do {
            let decodedData = try JSONDecoder().decode(Array<ClassOrganizationModel>.self,
                                                       from: jsonData)
            return decodedData
        } catch let err as NSError {
            print("decode error", err.localizedDescription)
        }
        return nil
    }
}
