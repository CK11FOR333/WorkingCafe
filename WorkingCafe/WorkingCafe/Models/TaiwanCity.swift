//
//  TaiwanCity.swift
//  WorkingCafe
//
//  Created by ChristmasKay on 2020/8/12.
//  Copyright © 2020 ChristmasKay. All rights reserved.
//

import Foundation

enum TaiwanCity: String {
    case keelung    = "Keelung"
    case taipei     = "Taipei"
    case taoyuan    = "Taoyuan"
    case hsinchu    = "Hsinchu"
    case miaoli     = "Miaoli"
    case taichung   = "Taichung"
    case changhua   = "Changhua"
    case nantou     = "Nantou"
    case yunlin     = "Yunlin"
    case chiayi     = "Chiayi"
    case tainan     = "Tainan"
    case kaohsiung  = "Kaohsiung"
    case pingtung   = "Pingtung"
    case taitung    = "Taitung"
    case hualien    = "Hualien"
    case yilan       = "Yilan"
    case penghu     = "Penghu"
    case lienchiang = "Lienchiang"
}

extension TaiwanCity: CustomStringConvertible {
    var description: String {
        switch self {
        case .keelung:
            return "基隆"
        case .taipei:
            return "台北"
        case .taoyuan:
            return "桃園"
        case .hsinchu:
            return "新竹"
        case .miaoli:
            return "苗栗"
        case .taichung:
            return "台中"
        case .changhua:
            return "彰化"
        case .nantou:
            return "南投"
        case .yunlin:
            return "雲林"
        case .chiayi:
            return "嘉義"
        case .tainan:
            return "台南"
        case .kaohsiung:
            return "高雄"
        case .pingtung:
            return "屏東"
        case .taitung:
            return "台東"
        case .hualien:
            return "花蓮"
        case .yilan:
            return "宜蘭"
        case .penghu:
            return "澎湖"
        case .lienchiang:
            return "連江"
        }
    }
}
