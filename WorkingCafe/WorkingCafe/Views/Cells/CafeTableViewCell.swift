//
//  CafeTableViewCell.swift
//  0610
//
//  Created by Chris on 2019/6/28.
//  Copyright © 2019 user. All rights reserved.
//

import UIKit

protocol CafeTableViewCellDelegate: class {
    func didClickCollectButton(_ sender: UIButton, at indexPath: IndexPath)
}

class CafeTableViewCell: UITableViewCell {

    var cafe: Cafe? {
        didSet {
            if let cafe = cafe {
                // url
                if URL(string: cafe.url) != nil {
                    urlButton.isHidden = false
                } else {
                    urlButton.isHidden = true
                }

                // name
                nameLabel.text = cafe.name

                // address
                addressLabel.text = cafe.address

                // wifi
                let wifiText = (0..<cafe.wifi).reduce("") { (acc, _) -> String in
                    return acc + "★"
                }
                let emptyWifiText = (cafe.wifi..<5).reduce("") { (acc, _) -> String in
                    return acc + "☆"
                }
                wifiStarLabel.text = wifiText + emptyWifiText
                wifiStarLabel.textColor = cafe.wifi == 5 ? Theme.current.fullStar : Theme.current.tableViewCellLightText
                wifiStarLabel.textColor = cafe.wifi == 1 ? UIColor(hexString: "EB5757") : wifiStarLabel.textColor

                // seat
                let seatText = (0..<cafe.seat).reduce("") { (acc, _) -> String in
                    return acc + "★"
                }
                let emptySeatText = (cafe.seat..<5).reduce("") { (acc, _) -> String in
                    return acc + "☆"
                }
                seatStarLabel.text = seatText + emptySeatText
                seatStarLabel.textColor = cafe.seat == 5 ? Theme.current.fullStar : Theme.current.tableViewCellLightText
                seatStarLabel.textColor = cafe.seat == 1 ? UIColor(hexString: "EB5757") : seatStarLabel.textColor


                // quiet
                let quietText = (0..<cafe.quiet).reduce("") { (acc, _) -> String in
                    return acc + "★"
                }
                let emptyQuietText = (cafe.quiet..<5).reduce("") { (acc, _) -> String in
                    return acc + "☆"
                }
                quiteStarLabel.text = quietText + emptyQuietText
                quiteStarLabel.textColor = cafe.quiet == 5 ? Theme.current.fullStar : Theme.current.tableViewCellLightText
                quiteStarLabel.textColor = cafe.quiet == 1 ? UIColor(hexString: "EB5757") : quiteStarLabel.textColor

                // tasty
                let tastyText = (0..<cafe.tasty).reduce("") { (acc, _) -> String in
                    return acc + "★"
                }
                let emptyTastyText = (cafe.tasty..<5).reduce("") { (acc, _) -> String in
                    return acc + "☆"
                }
                tastyStarLabel.text = tastyText + emptyTastyText
                tastyStarLabel.textColor = cafe.tasty == 5 ? Theme.current.fullStar : Theme.current.tableViewCellLightText
                tastyStarLabel.textColor = cafe.tasty == 1 ? UIColor(hexString: "EB5757") : tastyStarLabel.textColor

                // cheap
                let cheapText = (0..<cafe.cheap).reduce("") { (acc, _) -> String in
                    return acc + "★"
                }
                let emptyCheapText = (cafe.cheap..<5).reduce("") { (acc, _) -> String in
                    return acc + "☆"
                }
                cheapStarLabel.text = cheapText + emptyCheapText
                cheapStarLabel.textColor = cafe.cheap == 5 ? Theme.current.fullStar : Theme.current.tableViewCellLightText
                cheapStarLabel.textColor = cafe.cheap == 1 ? UIColor(hexString: "EB5757") : cheapStarLabel.textColor

                // music
                let musicText = (0..<cafe.music).reduce("") { (acc, _) -> String in
                    return acc + "★"
                }
                let emptyMusicText = (cafe.music..<5).reduce("") { (acc, _) -> String in
                    return acc + "☆"
                }
                musicStarLabel.text = musicText + emptyMusicText
                musicStarLabel.textColor = cafe.music == 5 ? Theme.current.fullStar : Theme.current.tableViewCellLightText
                musicStarLabel.textColor = cafe.music == 1 ? UIColor(hexString: "EB5757") : musicStarLabel.textColor


//                let isCollected = realmManager.isCafeCollected(cafe)
//                let isCollected = UserDefaults.standard.bool(forKey: cafe.id)
                var isCollected = false
                favoriteManager.isCafeCollected(cafe) { [weak self] (collected) in
                    isCollected = collected


                    self?.collectButton.isSelected = isCollected ? true : false
                    //                collectButton.tintColor = isCollected ? UIColor(hexString: "EB5757") : Theme.current.tint
                    self?.collectButton.tintColor = Theme.current.tint
                    //                if !isCollected {
                    //
                    //                }
                }
            }
        }
    }

    var indexPath: IndexPath!

    weak var delegate: CafeTableViewCellDelegate?

    // IBOutlet

    @IBOutlet weak var cardView: UIView!

    @IBOutlet weak var infoView: UIView!

    @IBOutlet weak var urlButton: UIButton!

    @IBOutlet weak var nameLabel: UILabel!

    @IBOutlet weak var collectButton: UIButton!

    @IBOutlet weak var wifiLabel: UILabel!
    @IBOutlet weak var wifiStarLabel: UILabel!

    @IBOutlet weak var seatLabel: UILabel!
    @IBOutlet weak var seatStarLabel: UILabel!

    @IBOutlet weak var quiteLabel: UILabel!
    @IBOutlet weak var quiteStarLabel: UILabel!

    @IBOutlet weak var tastyLabel: UILabel!
    @IBOutlet weak var tastyStarLabel: UILabel!

    @IBOutlet weak var cheapLabel: UILabel!
    @IBOutlet weak var cheapStarLabel: UILabel!

    @IBOutlet weak var musicLabel: UILabel!
    @IBOutlet weak var musicStarLabel: UILabel!

    @IBOutlet weak var addressLabel: UILabel!

    // IBAction

    @IBAction func clickCollectButton(_ sender: UIButton) {
        delegate?.didClickCollectButton(sender, at: indexPath)
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        cardView.cornerRadius = 10
        cardView.shadowOffset = CGSize(width: 0, height: 4)
        cardView.shadowRadius = 4
        cardView.shadowOpacity = 0.7
        cardView.layer.masksToBounds = false

        urlButton.setImage(UIImage(named: "list_icon_linkWeb_default")?.withRenderingMode(.alwaysTemplate), for: .normal)

        collectButton.tintColor = Theme.current.tint
        collectButton.setImage(UIImage(named: "navbar_icon_picked_default")?.withRenderingMode(.alwaysTemplate), for: .normal)
        collectButton.setImage(UIImage(named: "navbar_icon_picked_pressed"), for: .selected)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }

    override func prepareForReuse() {
        super.prepareForReuse()
    }

    func applyTheme() {
        self.backgroundColor = Theme.current.tableViewBackground

        cardView.backgroundColor = Theme.current.cornerButton
        cardView.shadowColor = Theme.current.shadow

        nameLabel.textColor = Theme.current.tableViewCellDarkText
        addressLabel.textColor = Theme.current.tableViewCellDarkText

        infoView.backgroundColor = Theme.current.tableViewCellBackgorund

        wifiLabel.textColor = Theme.current.tableViewCellLightText
        seatLabel.textColor = Theme.current.tableViewCellLightText
        tastyLabel.textColor = Theme.current.tableViewCellLightText
        cheapLabel.textColor = Theme.current.tableViewCellLightText
        quiteLabel.textColor = Theme.current.tableViewCellLightText
        musicLabel.textColor = Theme.current.tableViewCellLightText

        urlButton.tintColor = Theme.current.tint
    }

}
