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
import OSLog

public enum FileNames: String { case assignments = "assignments", folders = "folders"}
public let DateFormat: String = "yyyy-MM-dd'T'HH:mm:ssZ"
typealias assignments = [FileNames: [ClassOrganizationModel]]

final class ViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    let dateFormatter = DateFormatter()
    var assignmentsDict = assignments()
    var assignments_ByFolderID = [ Int: [ClassOrganizationModel] ]()
    static let pointsOfInterest = OSLog(subsystem: "com.apple.CodeChallenge", category: .pointsOfInterest)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    func setup() {
        dateFormatter.dateFormat = DateFormat
        fetchData(completion: { [weak self] classInfo in
            DispatchQueue.global(qos: .userInitiated).async { [weak self] in
                os_signpost(.begin, log: ViewController.pointsOfInterest, name: "Filtering Data")
                self?.filterData(data: classInfo)
                os_signpost(.end, log: ViewController.pointsOfInterest, name: "Filtering Data")
            }
        })
    }

    func fetchData(completion: (assignments?)->Void) {
        assignmentsDict[FileNames.assignments] = self.fetchClassFile(forName: FileNames.assignments.rawValue)
        assignmentsDict[FileNames.folders] = self.fetchClassFile(forName: FileNames.folders.rawValue)
        if !assignmentsDict.isEmpty {
        /* Fetching data was a success */
            completion(assignmentsDict)
            return
        }
        /* You have failed to fetch data */
        completion(nil)
        return
    }
    
    func filterData(data: assignments?) {
        guard var data = data else {return}

        /* Sort the folders by ID */
        let filteredFolders = data[FileNames.folders]?.sorted{ $0.id < $1.id }
        data[FileNames.folders] = filteredFolders
        
        /* Unassigned Folder count */
        guard let folderCount = filteredFolders?.count else {return}
        let unassignedFolder = folderCount + 1
        
        
        
        let assignments = data[FileNames.assignments] ?? []
        _ = assignments.enumerated().map({
            var elementOfInterest = $0.element
            
            /* 1. Add TimeIntervalSince1970 */
            let currentDate = $0.element.created ?? ""
            let date = dateFormatter.date(from: currentDate) ?? Date()
            elementOfInterest.timeIntervalSince = date.timeIntervalSince1970
            
            /* 2. Assign Folder ID to nil Folders */
            let folder_ID = Int($0.element.folder_id ?? "\(unassignedFolder)")
            if assignments_ByFolderID[folder_ID ?? unassignedFolder] == nil {
                assignments_ByFolderID[folder_ID ?? unassignedFolder] = [elementOfInterest]
            } else {
                assignments_ByFolderID[folder_ID ?? unassignedFolder]?.append(elementOfInterest)
            }
            
        })
        
        /* 3. Sort Assignments By Date */
        for eachAssignment in assignments_ByFolderID {
            assignments_ByFolderID[eachAssignment.key] = assignments_ByFolderID[eachAssignment.key]?.sorted{$0.timeIntervalSince ?? 0.0 < $1.timeIntervalSince ?? 0.0}
        }

        self.assignmentsDict = data
    }
}




// MARK:: Table View Delegate Functions
extension ViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return assignments_ByFolderID[section+1]?.count ?? 0
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        /* Account for uncategorized cell and avoid crash by stopping array from checking an index out of range */
        guard section < assignmentsDict[FileNames.folders]?.count ?? 0 else {return "Uncategorized"}
        return assignmentsDict[FileNames.folders]?[section].name
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        let count = assignmentsDict[FileNames.folders]?.count ?? 0
        return count + 1
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ClassOrganizationCell") as? ClassOrganizationCell else {return UITableViewCell.init()}
        let section = indexPath.section
        cell.classTitle.text = assignments_ByFolderID[section+1]?[indexPath.row].name
        let cellDate = assignments_ByFolderID[section+1]?[indexPath.row].created
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

