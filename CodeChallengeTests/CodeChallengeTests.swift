//
//  CodeChallengeTests.swift
//  CodeChallengeTests
//
//  Created by Thomas Martin on 11/15/20.
//

import XCTest
@testable import CodeChallenge

private enum VCErrorCases: Error {
    case NoVC
}

class CodeChallengeTests: XCTestCase {
    
    var sut: ViewController?

    override func setUpWithError() throws {
        guard let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ViewController") as? ViewController else {
            throw VCErrorCases.NoVC}
        sut = vc
        sut?.loadViewIfNeeded()
    }

    override func tearDownWithError() throws {
        sut = nil
    }

    func testDateFormat() {
        //Setup
        let dateFormat = sut?.dateFormatter.dateFormat
        //Action
        /* Action of view did load called setup to handle date formatting */
        //Test
        XCTAssertNotNil(dateFormat)
    }
    
    func testTableViewConnections() {
        //Setup
        let tableView = sut?.tableView
        //Action
        /* Action of view did load called setup to handle date formatting */
        //Test
        XCTAssertNotNil(tableView?.delegate, "TableView delegate missing")
        XCTAssertNotNil(tableView?.dataSource, "TableView datasource missing")
    }
    
    func testFetchData() {
        //Setup
        var assignments: assignments?
        _ = sut?.fetchData(completion: { assignmentsRecieved in
            assignments = assignmentsRecieved
        })
        //Action
        /* Action of view did load called setup to handle date formatting */
        //Test
        XCTAssertNotNil(assignments, "Local files contain values")
    }

}
