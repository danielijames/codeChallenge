//
//  Extensions.swift
//  CodeChallenge
//
//  Created by Daniel James on 7/30/21.
//

import Foundation
import UIKit

extension UIViewController {
    func formatDate(date: String) -> String? {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX") // set locale to reliable US_POSIX
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        if let date = dateFormatter.date(from:date) {
            dateFormatter.dateStyle = .short
            dateFormatter.timeStyle = .short
            let newDate = dateFormatter.string(from: date)
            return newDate
        }
        return nil
    }
}
