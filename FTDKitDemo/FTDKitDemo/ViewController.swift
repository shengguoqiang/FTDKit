//
//  ViewController.swift
//  FTDKitDemo
//
//  Created by shengguoqiang on 16/12/6.
//  Copyright © 2016年 盛世集团. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        /**
         *  图片轮播器
         */
        //1.创建view
        let loopView = FTDLoopView(frame: CGRect(x: 0, y: 0, width: view.bounds.width, height: view.bounds.width * 0.6))
        //2.配置参数
        loopView.config(infinite: true, autoScroll: true, timerInterval: 2, scrollDirection: .horizontal, scrollPosition: .left, placeholderImage: nil)
        view.addSubview(loopView)
        //3.设置代理
        loopView.delegate = self
        //4.加载资源
        loopView.reloadLoopView(resource: ["https://static.tziba.com//advertis/20150811133349843.jpg",
                                           "https://static.tziba.com//advertis/20161202161154949.jpg",
                                           "https://static.tziba.com//advertis/20161130094315490.jpg"])
    }
}

//MARK: - FTDLoopViewDelegate
extension ViewController: FTDLoopViewDelegate {
    func collectionViewDidEndDecelerating(index: Int) {
    }
    
    func collectionViewDidSelected(index: Int) {
    }
}

