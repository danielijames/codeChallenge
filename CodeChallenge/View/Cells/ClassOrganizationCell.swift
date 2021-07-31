//
//  ClassOrganizationCell.swift
//  CodeChallenge
//
//  Created by Daniel James on 7/30/21.
//

import UIKit

class ClassOrganizationCell: UITableViewCell {

    @IBOutlet weak var classTitle: UILabel!
    @IBOutlet weak var classDateInformation: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override func prepareForReuse() {
        classTitle.text = ""
        classDateInformation.text = ""
    }

}
