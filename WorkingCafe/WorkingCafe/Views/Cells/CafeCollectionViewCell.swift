//
//  CafeCollectionViewCell.swift
//  WorkingCafe
//
//  Created by ChristmasKay on 2020/12/14.
//  Copyright © 2020 ChristmasKay. All rights reserved.
//

import UIKit

// MARK: - Delegate

protocol CafeCollectionViewCellDelegate: class {
	func didClickCollectButton(_ sender: UIButton, at indexPath: IndexPath)
}

// MARK: - Property

class CafeCollectionViewCell: UICollectionViewCell {
	var cafe: Cafe? {
		didSet {
			if let cafe = cafe {
				// name
                // 替換掉反斜線，以避免造成Firestore奇數層錯誤
                var name = cafe.name
                if name.hasPrefix("/") {
                    name = name.replacingOccurrences(of: "/", with: " ")
                }
                
				nameLabel.text = name
				
				// star number
				let starNum: Float = Float(cafe.wifi + cafe.seat + cafe.quiet + cafe.tasty + cafe.cheap + cafe.music) / 6
				starNumberLabel.text = String(format: "%.1f", starNum)
				
				// collectButton
				var isCollected = false
				favoriteManager.isCafeCollected(cafe) { [weak self] (collected) in
					isCollected = collected
					
					self?.collectButton.isSelected = isCollected ? true : false
					self?.collectButton.tintColor = Theme.current.tint
				}
			}
		}
	}
	
	var indexPath: IndexPath!
	
	weak var delegate: CafeCollectionViewCellDelegate?
	
	private lazy var inforView: UIView = {
		let inforView = UIView()
		inforView.backgroundColor = Theme.current.tableViewCellSelectedBackground
		inforView.layer.cornerRadius = 18
		inforView.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.25)
		inforView.shadowOpacity = 1
		inforView.shadowRadius = 4
		inforView.shadowOffset = CGSize(width: 0, height: 4)
		return inforView
	}()
	
	private lazy var gradientImageView: UIImageView = {
		let gradientImageView = UIImageView()
		gradientImageView.image = UIImage(named: "gradientBrown")
		gradientImageView.layer.cornerRadius = 18
		gradientImageView.layer.masksToBounds = true
		return gradientImageView
	}()
	
	private lazy var nameLabel: UILabel = {
		let label = UILabel()
		label.textColor = .white
		label.font = UIFont.systemFont(ofSize: 20)
		return label
	}()
	
	private lazy var starLabel: UILabel = {
		let label = UILabel()
		label.textColor = .white
		label.font = UIFont.systemFont(ofSize: 28)
		label.text = "★"
		return label
	}()
	
	private lazy var starNumberLabel: UILabel = {
		let label = UILabel()
		label.textColor = .white
		label.font = UIFont.systemFont(ofSize: 28)
		return label
	}()
	
	private lazy var collectButton: UIButton = {
		let button = UIButton()
		button.tintColor = Theme.current.tint
		button.setImage(UIImage(named: "navbar_icon_picked_default")?.withRenderingMode(.alwaysTemplate), for: .normal)
		button.setImage(UIImage(named: "navbar_icon_picked_pressed"), for: .selected)
		button.addTarget(self, action: #selector(clickCollectButton(_:)), for: .touchUpInside)
		return button
	}()
	
	// MARK: - View LifeCycle
		
	override init(frame: CGRect) {
		super.init(frame: frame)
		setupViews()
		setupLayouts()
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	override func prepareForReuse() {
		super.prepareForReuse()
	}

}

// MARK: - Helpers

extension CafeCollectionViewCell {
	func setupViews() {
		contentView.addSubview(inforView)
		inforView.addSubview(gradientImageView)
		inforView.addSubview(nameLabel)
		inforView.addSubview(starLabel)
		inforView.addSubview(starNumberLabel)
		inforView.addSubview(collectButton)
	}
	
	func setupLayouts() {
		inforView.translatesAutoresizingMaskIntoConstraints = false
		gradientImageView.translatesAutoresizingMaskIntoConstraints = false
		nameLabel.translatesAutoresizingMaskIntoConstraints = false
		starLabel.translatesAutoresizingMaskIntoConstraints = false
		starNumberLabel.translatesAutoresizingMaskIntoConstraints = false
		collectButton.translatesAutoresizingMaskIntoConstraints = false
		
		// inforView
		NSLayoutConstraint.activate([
			inforView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
			inforView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10),
			inforView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
			inforView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10)
		])
		
		// gradientImageView
		NSLayoutConstraint.activate([
			gradientImageView.topAnchor.constraint(equalTo: inforView.topAnchor, constant: 0),
			gradientImageView.bottomAnchor.constraint(equalTo: inforView.bottomAnchor, constant: 0),
			gradientImageView.leadingAnchor.constraint(equalTo: inforView.leadingAnchor, constant: 0),
			gradientImageView.trailingAnchor.constraint(equalTo: inforView.trailingAnchor, constant: 0)
		])
		
		// nameLabel
		NSLayoutConstraint.activate([
			nameLabel.topAnchor.constraint(equalTo: inforView.topAnchor, constant: 16),
			nameLabel.leadingAnchor.constraint(equalTo: inforView.leadingAnchor, constant: 16),
			nameLabel.trailingAnchor.constraint(equalTo: inforView.trailingAnchor, constant: -16)
		])
		
		// starLabel
		NSLayoutConstraint.activate([
			starLabel.bottomAnchor.constraint(equalTo: inforView.bottomAnchor, constant: -10),
			starLabel.leadingAnchor.constraint(equalTo: inforView.leadingAnchor, constant: 16)
		])
		
		// starNumberLabel
		NSLayoutConstraint.activate([
			starNumberLabel.leadingAnchor.constraint(equalTo: starLabel.trailingAnchor, constant: 8),
			starNumberLabel.centerYAnchor.constraint(equalTo: starLabel.centerYAnchor)
		])
		
		// collectButton
		NSLayoutConstraint.activate([
			collectButton.bottomAnchor.constraint(equalTo: inforView.bottomAnchor, constant: -10),
			collectButton.trailingAnchor.constraint(equalTo: inforView.trailingAnchor, constant: -16),
			collectButton.widthAnchor.constraint(equalToConstant: 33),
			collectButton.heightAnchor.constraint(equalTo: collectButton.widthAnchor, multiplier: 1)
		])
	}
	
	@objc func clickCollectButton(_ sender: UIButton) {
		delegate?.didClickCollectButton(sender, at: indexPath)
	}
	
	func applyTheme() {
		inforView.backgroundColor = Theme.current.cornerButton
		inforView.shadowColor = Theme.current.shadow

		nameLabel.textColor = UIColor.white
		starLabel.textColor = Theme.current.fullStar
		starNumberLabel.textColor = Theme.current.fullStar
	}
}
