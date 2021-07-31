//
//  ViewController.swift
//  CodeChallenge
//
//  Created by Thomas Martin on 11/15/20.
//

/* At Classkick, our teachers make a lot of assignments, and they LOVE putting them into folders.
 * Your task is produce a simple table view that lists assignments and, optionally, folders.
 * See ExampleSolutionScreenshot.png for a simple example that uses the optional folders.
 *
 * Requirements:
 * Technology needed: Xcode 12, iPhone Simulator
 * You shall use the assignments.json file in this project
 * The table view rows shall display the assignment's name
 * Tapping a row shall deselect the row and print the tapped assignment's information in the console
 * Tests are encouraged
 *
 * Bonus 1: Dates
 *  - The table rows shall have a human readable subtitle consisting of the assignment's created date
 * Bonus 2: Sorting
 *  - You shall sort the assignments by their created date.
 *  - It doesn't have to be user sortable, a one time sort is okay.
 * Bonus 3: Use Folders
 *  - You shall use the folders.json file in this project, as well as the folder_id defined in the assignments.json
 *  - The table shall have a section for each folder
 *  - The section titles shall be the folder's name
 *  - The section rows shall be the assignments in that section/folder
 * Bonus 4: Invalid Folders
 *  - If an assignment doesn't have, or has an invalid folder_id, it should reside in a section/folder called "Uncategorized"
 */

import UIKit

final class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var tableView: UITableView!
    lazy var assignmentsData: [ClassOrganizationModel]? = nil
    lazy var foldersData: [ClassOrganizationModel]? = nil
    lazy var folderDataCount: Int = 0
    let dateFormatter = DateFormatter()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        fetchData()
    }
    
    func setup() {
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    /* Store Data locally for parsing */
    /* Data fetched locally is fetched Synchronously */
    func fetchData() {
        assignmentsData = self.fetchClassFile(forName: "assignments")
        foldersData = self.fetchClassFile(forName: "folders")
        
        /* Retain the count of sections needed */
        folderDataCount = foldersData?.count ?? 0
        
        /*Process the data*/
        if var assignmentsData = assignmentsData, var foldersData = foldersData {
            adjustAllData(data: &assignmentsData)
            adjustAllData(data: &foldersData)
            /* Assign the adjusted data to the local vars*/
            self.assignmentsData = assignmentsData
            self.foldersData = foldersData
        }
    }
}

// MARK:: Logic for filtering and adjusting the Data
extension ViewController {
    /* Adjust the folder ID */
    func adjustAllData(data: inout [ClassOrganizationModel]){
        for (index, eachGrouping) in data.enumerated() {
            if let currentDate = eachGrouping.created, let currentGroupingDate = dateFormatter.date(from: currentDate) {
                data[index].timeIntervalSince = currentGroupingDate.timeIntervalSince1970
            }
            /*Adjust folder ID to correctly classify uncategorized sections*/
            guard let folderID = eachGrouping.folder_id, Int(folderID) ?? (folderDataCount + 1) < folderDataCount else {
                data[index].adjustFolderID(newId: folderDataCount+1)
                continue
            }
        }
        data = data.sorted { $0.timeIntervalSince ?? 0.0 < $1.timeIntervalSince ?? 0.0 }
    }
}

// MARK:: Table View Delegate Functions
extension ViewController {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let assignmentsData = assignmentsData else {return 0}
        /* Assign the assignments data to the proper section*/
        let matchingSectionCount = assignmentsData.filter({Int($0.folder_id ?? "") == (section+1)}).count
        return matchingSectionCount
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        /* Account for uncategorized cell and avoid crash by stopping array from checking an index out of range */
        guard section < folderDataCount else {return "Uncategorized"}
        return foldersData?[section].name
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return folderDataCount + 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ClassOrganizationCell") as? ClassOrganizationCell else {return UITableViewCell.init()}
        guard let assignmentsData = assignmentsData else {return UITableViewCell.init()}
        
        let section = indexPath.section
        let matchingSectionData = assignmentsData.filter({Int($0.folder_id ?? "") == (section+1)})
        
        let cellName = matchingSectionData[indexPath.row].name
        let cellDate = matchingSectionData[indexPath.row].created
        
        cell.classTitle.text = cellName
        
        if let stringDate = cellDate, let formatedDate = self.formatDate(date: stringDate) {
            cell.classDateInformation.text = formatedDate
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        80
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
    }
}

