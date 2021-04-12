//
//  CafeDetailNameTableViewCell.swift
//  WorkingCafe
//
//  Created by ChristmasKay on 2020/12/14.
//  Copyright © 2020 ChristmasKay. All rights reserved.
//

import UIKit

class CafeDetailNameTableViewCell: UITableViewCell {
	
	var cafe: Cafe? {
		didSet {
			if let cafe = cafe {                
				nameLabel.text = cafe.name
			}
		}
	}
	
	@IBOutlet weak var nameLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

extension CafeDetailNameTableViewCell {
	func applyTheme() {
		self.backgroundColor = Theme.current.tableViewBackground
		nameLabel.textColor = Theme.current.tableViewCellLightText
	}
}
