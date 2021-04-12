//
//  CafeDetailAddressTableViewCell.swift
//  WorkingCafe
//
//  Created by ChristmasKay on 2020/12/14.
//  Copyright © 2020 ChristmasKay. All rights reserved.
//

import UIKit

class CafeDetailAddressTableViewCell: UITableViewCell {
	
	var cafe: Cafe? {
		didSet {
			if let cafe = cafe {
				addressLabel.text = cafe.address
			}
		}
	}
	
	@IBOutlet weak var addressLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

extension CafeDetailAddressTableViewCell {
	func applyTheme() {
		self.backgroundColor = Theme.current.tableViewBackground
		addressLabel.textColor = Theme.current.tableViewCellLightText
	}
}
