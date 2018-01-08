
/*********小贴士**************/
//1.创建FTDLoopView
//2.配置参数config
//3.设置代理
//4.加载资源

import UIKit
import Kingfisher

@objc public protocol FTDLoopViewDelegate: class {
    /**cell点击监听*/
    /**
     *  @param index 当前索引
     */
    @objc optional func collectionViewDidSelected(index: Int)
    
    /**
     *  @param instanceName 当前类实例的名称
     *  @param index     当前索引
     */
    @objc optional func collectionViewDidSelected(instanceName: String?, index: Int)
    
    /**cell滑动结束监听*/
    /**
     *  @param index 当前索引
     */
    @objc optional func collectionViewDidEndDecelerating(index: Int)
    
    /**
     *  @param instanceName 当前类实例的名称
     *  @param index     当前索引
     */
    @objc optional func collectionViewDidEndDecelerating(instanceName: String?, index: Int)
}

public class FTDLoopView: UIView {
    
    //MARK: - 公共属性
    //代理
    public weak var delegate: FTDLoopViewDelegate?
    
    /******************************************************************/
    
    //MARK: - 私有属性
    //当前实例的名称-区分同一页面中多个FTDLoopView实例
    fileprivate var instanceName: String?
    
    //collectionViewLayout
    private var collectionViewLayout: UICollectionViewFlowLayout!
    
    //collectionView
    private var collectionView: UICollectionView!
    
    //timer
    private weak var timer: Timer?
    
    //需要展示图片数量
    fileprivate var totalShows: Int = 0
    
    //实际图片数量
    fileprivate var actualShows: Int = 0
    
    //是否无限循环,默认不无限循环
    private var infinite: Bool = false
    
    //是否在自动滚动中
    fileprivate var autoScrolling: Bool = false
    
    //是否自动滚动,默认不自动滚动
    fileprivate var autoScroll: Bool = false {
        willSet {
            autoScrolling = newValue
        }
    }
    
    //定时器间隔时间，默认2s
    private var timerInterval: TimeInterval = 2
    
    //滚动方向,默认横向
    private var scrollDirection: UICollectionViewScrollDirection = .horizontal {
        willSet {
            collectionViewLayout.scrollDirection = newValue
        }
    }
    
    //偏移方向->横向：左右，纵向：上下
    private var scrollPosition: UICollectionViewScrollPosition = .left
    
    //是否需要监听滚动视图滚到一半时，索引变化,默认需要监听
    fileprivate var monitorIndexChanged: Bool = true
    
    //cellNibName
    private var cellNibName: String!
    
    //cell重用标识符
    fileprivate var cellIdentifier: String!
    
    //图片url数组
    fileprivate var sourceArray = [AnyObject]() {
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
    
    /******************************************************************/
    
    //MARK: - 公共方法
    
    /** 配置参数
     *  @param infinite         是否无限循环
     *  @param autoScroll       是否自动滚动
     *  @param timerInterval    定时器间隔
     *  @param scrollDirection  滚动方向
     *  @param scrollPosition   偏移方向
     *  @param cellNibName      cellNibName
     *  @param cellIdentifier   cell重用标识符
     */
    public func config(infinite: Bool,
                       autoScroll: Bool,
                       timerInterval: TimeInterval,
                       scrollDirection: UICollectionViewScrollDirection,
                       scrollPosition: UICollectionViewScrollPosition,
                       cellNibName: String,
                       cellIdentifier: String) {
        /**初始化**/
        setup()
        
        /**设置属性**/
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
        
        //设置cellNibName
        self.cellNibName = cellNibName;
        
        //设置cell重用标识
        self.cellIdentifier = cellIdentifier
        
        //注册cell
        collectionView.register(UINib(nibName: cellNibName, bundle: nil), forCellWithReuseIdentifier: cellIdentifier)
    }
    
    /** 配置参数
     *  @param infinite             是否无限循环
     *  @param autoScroll           是否自动滚动
     *  @param timerInterval        定时器间隔
     *  @param scrollDirection      滚动方向
     *  @param scrollPosition       偏移方向
     *  @param monitorIndexChanged  是否需要监听滚动视图滚到一半时，索引变化
     *  @param cellNibName          cellNibName
     *  @param cellIdentifier       cell重用标识符
     */
    public func config(infinite: Bool,
                       autoScroll: Bool,
                       timerInterval: TimeInterval,
                       scrollDirection: UICollectionViewScrollDirection,
                       scrollPosition: UICollectionViewScrollPosition,
                       monitorIndexChanged: Bool,
                       cellNibName: String,
                       cellIdentifier: String) {
        //初始化设置
        config(infinite: infinite, autoScroll: autoScroll, timerInterval: timerInterval, scrollDirection: scrollDirection, scrollPosition: scrollPosition, cellNibName: cellNibName, cellIdentifier: cellIdentifier)
        
        //监听滚动视图滚到一半时，索引变化
        self.monitorIndexChanged = monitorIndexChanged
    }
    
    /** 配置参数
     *  @param infinite             是否无限循环
     *  @param autoScroll           是否自动滚动
     *  @param timerInterval        定时器间隔
     *  @param scrollDirection      滚动方向
     *  @param scrollPosition       偏移方向
     *  @param instanceName         当前实例的名称-区分同一页面中多个FTDLoopView实例
     *  @param cellNibName          cellNibName
     *  @param cellIdentifier       cell重用标识符
     */
    public func config(infinite: Bool,
                       autoScroll: Bool,
                       timerInterval: TimeInterval,
                       scrollDirection: UICollectionViewScrollDirection,
                       scrollPosition: UICollectionViewScrollPosition,
                       instanceName: String?,
                       cellNibName: String,
                       cellIdentifier: String) {
        //初始化设置
        config(infinite: infinite, autoScroll: autoScroll, timerInterval: timerInterval, scrollDirection: scrollDirection, scrollPosition: scrollPosition, cellNibName: cellNibName, cellIdentifier: cellIdentifier)
        
        //当前类实例名称
        self.instanceName = instanceName
    }
    
    /** 刷新滚动视图
     *  @param resource 资源
     */
    public func reloadLoopView(resource: [AnyObject]) {
        //数据源
        sourceArray = resource
    }
    
    /** 滚动视图移至指定位置
     *  @param item 指定位置坐标
     */
    public func scrollToItem(_ item: IndexPath) {
        collectionView.scrollToItem(at: item, at: scrollPosition, animated: false)
    }
    
    /** 刷新当前collectionViewCell
     */
    public func reloadcurrentItem() {
        collectionView.reloadItems(at: [IndexPath(item: currentIndex(), section: 0)])
    }
    
    //开启定时器
    public func start() {
        
        guard actualShows > 1 else {//没有图片或只有一张不需要倒计时
            finishRunLoop()
            return
        }
        
        //关闭定时器
        finishRunLoop()
        
        timer = Timer.scheduledTimer(timeInterval: timerInterval, target: self, selector: #selector(FTDLoopView.runLoop), userInfo: nil, repeats: true)
        RunLoop.current.add(timer!, forMode: .UITrackingRunLoopMode)
    }
    
    //关闭定时器
    public func finishRunLoop() {
        timer?.invalidate()
        timer = nil
    }
    
    /******************************************************************/
    
    //MARK: - 私有方法
    //初始化
    private func setup() {
        //创建collectionViewLayout
        if self.collectionViewLayout == nil {
            let collectionViewLayout = UICollectionViewFlowLayout()
            collectionViewLayout.minimumLineSpacing = 0
            self.collectionViewLayout = collectionViewLayout
        }
        
        //创建collectionView
        if self.collectionView == nil {
            let collectionView = UICollectionView(frame: CGRect(origin: CGPoint.zero, size: CGSize.zero), collectionViewLayout: collectionViewLayout)
            collectionView.showsHorizontalScrollIndicator = false
            collectionView.showsVerticalScrollIndicator = false
            collectionView.isPagingEnabled = true
            collectionView.delegate = self
            collectionView.dataSource = self
            collectionView.backgroundColor = UIColor.clear
            addSubview(collectionView)
            self.collectionView = collectionView
        }
        
        //布局
        layoutIfNeeded()
    }
    
    //布局
    override public func layoutSubviews() {
        super.layoutSubviews()
        //非空判断
        guard collectionView != nil, collectionViewLayout != nil else {
            return
        }
        //设置collectionView的Frame
        collectionView.frame = CGRect(x: 0, y: 0, width: bounds.width, height: bounds.height)
        //设置itemSize
        collectionViewLayout.itemSize = CGSize(width: bounds.width, height: bounds.height)
        //设置初始位置
        setupInitOffSet()
    }
    
    //设置初始位置
    private func setupInitOffSet() {
        guard actualShows > 0 else {//没有图片不需要设置初始位置
            return
        }
        //初始偏移量
        let targetIndex = infinite ? totalShows / 2 : 0
        collectionView.scrollToItem(at: IndexPath(item: targetIndex, section: 0), at: scrollPosition, animated: false)
    }
    
    //定时器事件
    @objc private func runLoop() {
        //修改collectionView偏移量
        collectionViewChangeOffSet()
    }
    
    //collectionView偏移
    private func collectionViewChangeOffSet() {
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
    
    //获取当前item坐标
    fileprivate func currentIndex() -> Int {
        var index = 0
        if collectionViewLayout.scrollDirection == .horizontal {
            index = Int((collectionView.contentOffset.x + collectionViewLayout.itemSize.width * 0.5) / collectionViewLayout.itemSize.width)
        } else {
            index = Int((collectionView.contentOffset.y + collectionViewLayout.itemSize.height * 0.5) / collectionViewLayout.itemSize.height)
        }
        return index
    }
    
    //MARK: - 销毁FTDLoopView实例
    deinit {
        //关闭定时器
        finishRunLoop()
    }
}

//MARK: - 代理事件
//UICollectionViewDataSource, UICollectionViewDelegate
extension FTDLoopView: UICollectionViewDataSource, UICollectionViewDelegate {
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return totalShows
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath) as! FTDCollectionViewCell
        let index = indexPath.item % actualShows
        let source = sourceArray[index]
        //子类实现该方法
        cell.reloadData(source)
        return cell
    }
    
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let index = indexPath.item % actualShows
        delegate?.collectionViewDidSelected?(index: index)
        delegate?.collectionViewDidSelected?(instanceName: instanceName, index: index)
    }
}

//UIScrollViewDelegate
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
        guard monitorIndexChanged else {//无需监听滚动一半时，索引变化
            return
        }
        guard actualShows > 0 else {
            return
        }
        let index = currentIndex() % actualShows
        delegate?.collectionViewDidEndDecelerating?(index: index)
        delegate?.collectionViewDidEndDecelerating?(instanceName: instanceName, index: index)
    }
    
    public func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if autoScroll {//启动定时器
            start()
        }
    }
    
    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        guard actualShows > 0 else {
            return
        }
        if !monitorIndexChanged {//无需监听滚动一半时，索引变化
            let index = autoScrolling ? (currentIndex() + 1) % actualShows : currentIndex() % actualShows
            delegate?.collectionViewDidEndDecelerating?(index: index)
            delegate?.collectionViewDidEndDecelerating?(instanceName: instanceName, index: index)
        }
        //页面滑动（无论是自动滑动还是手动拖拽）结束，修改状态
        autoScrolling = autoScroll
    }
}

