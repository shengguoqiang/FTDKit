//
//  ViewController.swift
//  FTDKitDemo
//
//  Created by shengguoqiang on 16/12/6.
//  Copyright © 2016年 盛世集团. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    //代码
    var loopView: FTDLoopView!
    
    //nib
    @IBOutlet weak var nibLoopView: FTDLoopView!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        /**
         *  代码
         */
        //1.创建view
        loopView = FTDLoopView(frame: CGRect(x: 0, y: 0, width: view.bounds.width, height: view.bounds.width * 0.6))
        //2.配置参数
        loopView.config(infinite: true, autoScroll: true, timerInterval: 2, scrollDirection: .horizontal, scrollPosition: .left, cellNibName: "MyCell", cellIdentifier: "MyCellId")
        view.addSubview(loopView)
        //3.设置代理
        loopView.delegate = self
        //4.加载资源
        loopView.reloadLoopView(resource: ["https://static.tziba.com//advertis/20150811133349843.jpg" as AnyObject,
                                           "https://static.tziba.com//advertis/20161202161154949.jpg" as AnyObject,
                                           "https://static.tziba.com//advertis/20161130094315490.jpg" as AnyObject])
        
        /**
         *  nib
         */
        //1.配置参数
        nibLoopView.config(infinite: true, autoScroll: true, timerInterval: 2, scrollDirection: .vertical, scrollPosition: .bottom, cellNibName: "YourCell", cellIdentifier: "YourCellId")
        //2.设置代理
        nibLoopView.delegate = self
        //3.加载资源
        nibLoopView.reloadLoopView(resource: ["你中大奖啦" as AnyObject,
                                              "特别通知：您好，快来领奖吧！" as AnyObject,
                                              "对不起！奖已领！" as AnyObject])
        
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        //关闭轮播图
        loopView.finishRunLoop()
        nibLoopView.finishRunLoop()
    }
}

//MARK: - FTDLoopViewDelegate
extension ViewController: FTDLoopViewDelegate {
    func collectionViewDidEndDecelerating(index: Int) {
        print("currentIndex = \(index)")
    }
    
    func collectionViewDidSelected(index: Int) {
        print("selectedIndex = \(index)")
    }
}

