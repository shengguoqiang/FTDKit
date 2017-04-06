//
//  MyCell.swift
//  FTDKitDemo
//
//  Created by FTD on 17/4/6.
//  Copyright © 2017年 盛世集团. All rights reserved.
//

import UIKit

//自定义cell必须继承FTDCollectionViewCell
class MyCell: FTDCollectionViewCell {

    //bannerView
    @IBOutlet weak var bannerView: UIImageView!
    
    //重写父类方法
    override func reloadData(_ bean: AnyObject) {
        guard let str = bean as? String else {
            return
        }
        bannerView.kf.setImage(with: URL(string: str))
    }
}
