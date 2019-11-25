//
//  ListItemCell.swift
//  UbikeMap
//
//  Created by Kao Ming-Hsiu on 2019/11/25.
//  Copyright © 2019 ObiCat. All rights reserved.
//

import UIKit

class ListItemCell: UITableViewCell {
    @IBOutlet weak var 場站名稱: UILabel!
    @IBOutlet weak var 場站總停車格: UILabel!
    @IBOutlet weak var 場站目前車輛數量: UILabel!
    @IBOutlet weak var 空位數量: UILabel!
    @IBOutlet weak var 地址: UILabel!
    @IBOutlet weak var 資料更新時間: UILabel!
//    @IBOutlet weak var 我的最愛: Bool {get set}
}
