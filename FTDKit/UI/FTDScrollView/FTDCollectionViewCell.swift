//1.自定义cell必须继承FTDCollectionViewCell
//2.子类实现reloadData(_ bean: AnyObject)方法

import UIKit

open class FTDCollectionViewCell: UICollectionViewCell {
    open func reloadData(_ bean: AnyObject) {
        //子类实现
    }
}
