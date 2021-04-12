//
//  CafeDetailStarTableViewCell.swift
//  WorkingCafe
//
//  Created by ChristmasKay on 2020/12/14.
//  Copyright © 2020 ChristmasKay. All rights reserved.
//

import UIKit

class CafeDetailStarTableViewCell: UITableViewCell {
	
	enum ValueStarTitle {
		case wifi
		case seat
		case quiet
		case tasty
		case cheap
		case music
	}
	
	var valueStarTitle: ValueStarTitle!
	
	var cafe: Cafe? {
		didSet {
			if let cafe = cafe {
				switch valueStarTitle {
					case .wifi:
						let wifiText = (0..<cafe.wifi).reduce("") { (acc, _) -> String in
							return acc + "🌕"
						}
						let emptyWifiText = (cafe.wifi..<5).reduce("") { (acc, _) -> String in
							return acc + "🌑"
						}
						starLabel.text = wifiText + emptyWifiText
						iconLabel.text = "📶"
						titleLabel.text = "WIFI穩定"
					case .seat:
						let seatText = (0..<cafe.seat).reduce("") { (acc, _) -> String in
							return acc + "🌕"
						}
						let emptySeatText = (cafe.seat..<5).reduce("") { (acc, _) -> String in
							return acc + "🌑"
						}
						starLabel.text = seatText + emptySeatText
						iconLabel.text = "🈳"
						titleLabel.text = "通常有位"
					case .quiet:
						let quietText = (0..<cafe.quiet).reduce("") { (acc, _) -> String in
							return acc + "🌕"
						}
						let emptyQuietText = (cafe.quiet..<5).reduce("") { (acc, _) -> String in
							return acc + "🌑"
						}
						starLabel.text = quietText + emptyQuietText
						iconLabel.text = "💤"
						titleLabel.text = "安靜程度"
					case .tasty:
						let tastyText = (0..<cafe.tasty).reduce("") { (acc, _) -> String in
							return acc + "🌕"
						}
						let emptyTastyText = (cafe.tasty..<5).reduce("") { (acc, _) -> String in
							return acc + "🌑"
						}
						starLabel.text = tastyText + emptyTastyText
						iconLabel.text = "☕️"
						titleLabel.text = "咖啡好喝"
					case .cheap:
						let cheapText = (0..<cafe.cheap).reduce("") { (acc, _) -> String in
							return acc + "🌕"
						}
						let emptyCheapText = (cafe.cheap..<5).reduce("") { (acc, _) -> String in
							return acc + "🌑"
						}
						starLabel.text = cheapText + emptyCheapText
						iconLabel.text = "💵"
						titleLabel.text = "價格便宜"
					case .music:
						let musicText = (0..<cafe.music).reduce("") { (acc, _) -> String in
							return acc + "🌕"
						}
						let emptyMusicText = (cafe.music..<5).reduce("") { (acc, _) -> String in
							return acc + "🌑"
						}
						starLabel.text = musicText + emptyMusicText
						iconLabel.text = "🎻"
						titleLabel.text = "裝潢音樂"
					default:
						break
				}
			}
		}
	}
	
	@IBOutlet weak var iconLabel: UILabel!
	@IBOutlet weak var titleLabel: UILabel!
	@IBOutlet weak var starLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }

}

extension CafeDetailStarTableViewCell {
	func applyTheme() {
		self.backgroundColor = Theme.current.tableViewBackground
		iconLabel.textColor = Theme.current.tableViewCellLightText
		titleLabel.textColor = Theme.current.tableViewCellLightText
		starLabel.textColor = Theme.current.tableViewCellLightText
	}
}
