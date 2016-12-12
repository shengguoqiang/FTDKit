//
//  FTDLoopView.swift
//  Demo
//
//  Created by FTD on 16/12/1.
//  Copyright © 2016年 江苏投吧金融信息服务有限公司. All rights reserved.
//

import UIKit
import Kingfisher

//cell复用标识
let cellIdentifier = "FTDCellIdentifier"

public protocol FTDLoopViewDelegate: class {
    //cell点击监听
    func collectionViewDidSelected(index: Int)
    //cell滑动结束监听
    func collectionViewDidEndDecelerating(index: Int)
}

public class FTDLoopView: UIView {
    
    //collectionViewLayout
    var collectionViewLayout: UICollectionViewFlowLayout!
    
    //collectionView
    var collectionView: UICollectionView!
    
    //timer
    weak var timer: Timer?
    
    //代理
    public weak var delegate: FTDLoopViewDelegate?
    
    //需要展示图片数量
    var totalShows: Int = 0
    
    //实际图片数量
    var actualShows: Int = 0
    
    //是否无限循环,默认不无限循环
    var infinite: Bool = false
    
    //是否在自动滚动中
    var autoScrolling: Bool = false
    
    //是否自动滚动,默认不自动滚动
    var autoScroll: Bool = false {
        willSet {
           autoScrolling = newValue
        }
    }
    
    //定时器间隔时间，默认2s
    var timerInterval: TimeInterval = 2
    
    //滚动方向,默认横向
    var scrollDirection: UICollectionViewScrollDirection = .horizontal {
        willSet {
           collectionViewLayout.scrollDirection = newValue
        }
    }
    
    //偏移方向->横向：左右，纵向：上下
    var scrollPosition: UICollectionViewScrollPosition = .left
    
    //banner默认背景
    var placeholderImage: UIImage?
    
    //图片url数组
    var sourceArray = [String]() {
        didSet {
            //实际图片数量
            actualShows = sourceArray.count
            //需要展示图片数量
            totalShows = sourceArray.count * 100
            totalShows = (infinite && actualShows > 1) ? totalShows : actualShows
            //刷新collectionView
            collectionView.reloadData()
            //设置初始位置
            setupInitOffSet()
            //是否开启倒计时
            if autoScroll {
                start()
            }
        }
    }
    
    //MARK: - 初始化
    override public init(frame: CGRect) {
        super.init(frame: frame)
        
        //创建collectionViewLayout
        let collectionViewLayout = UICollectionViewFlowLayout()
        collectionViewLayout.minimumLineSpacing = 0
        self.collectionViewLayout = collectionViewLayout
        
        //创建collectionView
        let collectionView = UICollectionView(frame: frame, collectionViewLayout: collectionViewLayout)
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.showsVerticalScrollIndicator = false
        collectionView.isPagingEnabled = true
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = UIColor.white
        addSubview(collectionView)
        self.collectionView = collectionView
        
        //注册cell（注意bundle的获取）
        let FTDLoopViewClass = NSClassFromString("FTDKit.FTDLoopView") as? FTDLoopView.Type
        guard let ftdCla = FTDLoopViewClass else {
             return
        }
        collectionView.register(UINib(nibName: "FTDCollectionViewCell", bundle: Bundle.init(for: ftdCla)), forCellWithReuseIdentifier: cellIdentifier)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        //关闭定时器
        finishRunLoop()
    }
    
    //MARK: - 配置参数
    /**
     *  param infinite         是否无限循环
     *  param autoScroll       是否自动滚动
     *  param timerInterval    定时器间隔
     *  param scrollDirection  滚动方向
     *  param scrollPosition   偏移方向
     */
   public func config(infinite: Bool, autoScroll: Bool, timerInterval: TimeInterval, scrollDirection: UICollectionViewScrollDirection, scrollPosition: UICollectionViewScrollPosition, placeholderImage: UIImage?) {
        //是否无限循环
        self.infinite = infinite
        
        //是否自动滚动
        self.autoScroll = autoScroll
        
        //设置定时器时间间隔
        self.timerInterval = timerInterval
        
        //设置滚动方向
        self.scrollDirection = scrollDirection
        
        //设置偏移方向
        self.scrollPosition = scrollPosition
        
        //设置banner默认背景
        self.placeholderImage = placeholderImage

    }
    
    //MARK: - 刷新滚动视图
   public func reloadLoopView(resource: [String]) {
        //数据源
        sourceArray = resource
    }
    
    //MARK: - 布局
    override public func layoutSubviews() {
        super.layoutSubviews()
        //设置collectionView的Frame
        collectionView.frame = CGRect(x: 0, y: 0, width: bounds.width, height: bounds.height)
        //设置itemSize
        collectionViewLayout.itemSize = CGSize(width: bounds.width, height: bounds.height)
        //设置初始位置
        setupInitOffSet()
    }
    
    //MARK: - 设置初始位置
    func setupInitOffSet() {
        guard actualShows > 0 else {//没有图片不需要设置初始位置
            return
        }
        //初始偏移量
        let targetIndex = infinite ? totalShows / 2 : 0
        collectionView.scrollToItem(at: IndexPath(item: targetIndex, section: 0), at: scrollPosition, animated: false)
    }
    
    //MARK: - 开启定时器
    func start() {
        
        guard actualShows > 1 else {//没有图片或只有一张不需要倒计时
            finishRunLoop()
            return
        }
        
        //关闭定时器
        finishRunLoop()
        
        timer = Timer.scheduledTimer(timeInterval: timerInterval, target: self, selector: #selector(FTDLoopView.runLoop), userInfo: nil, repeats: true)
        RunLoop.current.add(timer!, forMode: .UITrackingRunLoopMode)
    }
    
    //MARK: - 关闭定时器
    func finishRunLoop() {
        timer?.invalidate()
        timer = nil
    }
    
    //MARK: - 定时器事件
    func runLoop() {
        //修改collectionView偏移量
        collectionViewChangeOffSet()
    }
    
    //MARK: - collectionView偏移
    func collectionViewChangeOffSet() {
        //当前坐标
        let curIndex = currentIndex()
        //转移至下一坐标
        var targetIndex = curIndex + 1
        if targetIndex >= totalShows {
            if infinite {//无限循环，回到起始位置
                targetIndex = totalShows / 2
                collectionView.scrollToItem(at: IndexPath(item: targetIndex, section: 0), at: scrollPosition, animated: false)
            } else {//不无限循环，回到起始位置
                targetIndex = 0
                collectionView.scrollToItem(at: IndexPath(item: targetIndex, section: 0), at: scrollPosition, animated: true)
            }
        } else {//正常从中间往后偏移
          collectionView.scrollToItem(at: IndexPath(item: targetIndex, section: 0), at: scrollPosition, animated: true)
        }
        
        scrollViewDidEndDecelerating(collectionView)
    }
    
    //MARK: - 获取当前item坐标
    func currentIndex() -> Int {
        var index = 0
        if collectionViewLayout.scrollDirection == .horizontal {
            index = Int((collectionView.contentOffset.x + collectionViewLayout.itemSize.width * 0.5) / collectionViewLayout.itemSize.width)
        } else {
            index = Int((collectionView.contentOffset.y + collectionViewLayout.itemSize.height * 0.5) / collectionViewLayout.itemSize.height)
        }
        return index
    }
}

//MARK: - UICollectionViewDataSource, UICollectionViewDelegate
extension FTDLoopView: UICollectionViewDataSource, UICollectionViewDelegate {
   public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return totalShows
    }
    
   public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath) as! FTDCollectionViewCell
        let index = indexPath.item % actualShows
        let source = sourceArray[index]
        cell.imageView.kf.setImage(with: URL(string: source), placeholder: placeholderImage, options: nil, progressBlock: nil, completionHandler: nil)
        return cell
    }
    
   public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let index = indexPath.item % actualShows
        delegate?.collectionViewDidSelected(index: index)
    }
}

//MARK: - UIScrollViewDelegate
extension FTDLoopView: UIScrollViewDelegate {
    
   public func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        if autoScroll {//关闭定时器
           finishRunLoop()
            //自动滑动过程中，手动拖拽时，修改状态，为了scrollViewDidEndDecelerating中计算准确的偏移量
            autoScrolling = false
        }
    }
    
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        //cell滑动过程中，当前页面判断
        let index = currentIndex() % actualShows
        delegate?.collectionViewDidEndDecelerating(index: index)
    }
    
   public func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if autoScroll {//启动定时器
            start()
        }
    }
    
   public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
       let index = autoScrolling ? (currentIndex() + 1) % actualShows : currentIndex() % actualShows
        delegate?.collectionViewDidEndDecelerating(index: index)
       //页面滑动（无论是自动滑动还是手动拖拽）结束，修改状态
       autoScrolling = autoScroll
    }
}
