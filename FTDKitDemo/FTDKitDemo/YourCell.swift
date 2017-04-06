//
//  YourCell.swift
//  FTDKitDemo
//
//  Created by FTD on 17/4/6.
//  Copyright © 2017年 盛世集团. All rights reserved.
//

import UIKit

//自定义cell必须继承FTDCollectionViewCell
class YourCell: FTDCollectionViewCell {
    
    //标题
    @IBOutlet weak var markLabel: UILabel!

    //重写父类方法
    override func reloadData(_ bean: AnyObject) {
        guard let str = bean as? String else {
            return
        }
        markLabel.text = str
    }
}
