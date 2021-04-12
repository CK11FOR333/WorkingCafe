//
//  CafeDetailContentTableViewCell.swift
//  WorkingCafe
//
//  Created by ChristmasKay on 2020/12/14.
//  Copyright © 2020 ChristmasKay. All rights reserved.
//

import UIKit

protocol CafeDetailContentTableViewCellDelegate: class {
	func didClickLinkButton()
}

class CafeDetailContentTableViewCell: UITableViewCell {
	
	enum ContentTitle {
		case limitedTime
		case socket
		case standingDesk
		case openTime
		case mrt
		case url
	}
	
	var contentTitle: ContentTitle!
	
	var cafe: Cafe? {
		didSet {
			if let cafe = cafe {
				switch contentTitle {
					case .limitedTime:
						switch cafe.limited_time {
							case "yes":
								contentLabel.text = "一律有限時"
							case "maybe":
								contentLabel.text = "看情況，假日或客滿限時"
							case "no":
								contentLabel.text = "一律不限時"
							default:
								contentLabel.text = "-"
						}
						iconLabel.text = "🈶"
						titleLabel.text = "有無限時"
					case .socket:
						switch cafe.socket {
							case "yes":
								contentLabel.text = "很多"
							case "maybe":
								contentLabel.text = "還好，看座位"
							case "no":
								contentLabel.text = "很少"
							default:
								contentLabel.text = "-"
						}
						iconLabel.text = "🔌"
						titleLabel.text = "插座多"
					case .standingDesk:
						switch cafe.standing_desk {
							case "yes":
								contentLabel.text = "很多"
							case "maybe":
								contentLabel.text = "還好，看座位"
							case "no":
								contentLabel.text = "很少"
							default:
								contentLabel.text = "-"
						}
						iconLabel.text = "🦿"
						titleLabel.text = "可站立工作"
					case .openTime:
						contentLabel.text = cafe.open_time.isEmpty ? "-" : cafe.open_time
						iconLabel.text = "🈺"
						titleLabel.text = "營業時間"
					case .mrt:
						contentLabel.text = cafe.mrt.isEmpty ? "-" : cafe.mrt
						iconLabel.text = "Ⓜ️"
						titleLabel.text = "交通站"
					case .url:
						contentLabel.text = cafe.url.isEmpty ? "-" : cafe.url
						contentLabel.isUserInteractionEnabled = true
						contentLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(openLink)))
						iconLabel.text = "🌐"
						titleLabel.text = "官網"
					default:
						break
				}
			}
		}
	}
	
	weak var delegate: CafeDetailContentTableViewCellDelegate?
	
	@IBOutlet weak var iconLabel: UILabel!
	@IBOutlet weak var titleLabel: UILabel!
	@IBOutlet weak var contentLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

extension CafeDetailContentTableViewCell {
	@objc func openLink() {
		delegate?.didClickLinkButton()
	}
	
	func applyTheme() {
		self.backgroundColor = Theme.current.tableViewBackground
		iconLabel.textColor = Theme.current.tableViewCellLightText
		titleLabel.textColor = Theme.current.tableViewCellLightText
		contentLabel.textColor = Theme.current.tableViewCellLightText
	}
}
