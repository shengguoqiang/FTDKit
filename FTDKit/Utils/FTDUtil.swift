//工具类

import UIKit

public enum FTDNumShowStyle {
    case normal       //正常显示
    case two_decimals //保留两位小数
}

public class FTDUtil: NSObject {
    
    //MARK: - 处理数字分割显示
    public static func showNum(num: String, showStyle: FTDNumShowStyle = .normal) -> String {
        //判断是否已经处理过
        guard !num.contains(",") else {
            return num
        }
        var intNum: String?     //整数
        var doubleNum: String?  //小数
        var sectionOne: String? //整数经过处理显示
        var sectionTwo: String? //小数经过处理显示
        //判断是否有小数
        if num.contains(".") {
            intNum = num.components(separatedBy: ".")[0]
            doubleNum = num.components(separatedBy: ".")[1]
        } else {
            intNum = num.components(separatedBy: ".")[0]
        }
        //处理整数
        if let num = intNum {
            if Int(num)! > 0 {
                sectionOne = showIntNum(num: num)
            } else {
                sectionOne = "0"
            }
        }
        //处理小数
        if let num = doubleNum {
            sectionTwo = showDoubleNum(num: num, showStyle: showStyle)
        }
        guard sectionTwo != nil else {
            if showStyle == .two_decimals {//保留两位小数
                return "\(sectionOne ?? "").00"
            }
            return sectionOne ?? ""
        }
        return "\(sectionOne ?? "").\(sectionTwo ?? "")"
    }
    
    //MARK: - 处理字符串中特殊样式显示
    public static func showAttributeString(target: String) -> String {
       return "..."
    }
}

extension FTDUtil {
    //MARK: - 处理小数
    fileprivate static func showDoubleNum(num: String, showStyle: FTDNumShowStyle) -> String? {
        switch showStyle {
        case .normal: //正常显示
            return num
        case .two_decimals: //保留两位小数
            let length = num.lengthOfBytes(using: .utf8)
            let intNum = Int(num)!
            if intNum >= 10 || length == 2 {
                return "\(num)"
            }
            return "\(num)0"
        }
    }
    
    //MARK: - 处理整数
    fileprivate static func showIntNum(num: String) -> String {
        let res =  seperateNum(num: Int(num)!)
        guard res.0 > 0 else {
            return "\(thousandNum(num: res.1))"
        }
        guard !isMoreThanOneThousand(num: res.0) else {
            let str = showIntNum(num: "\(res.0)")
            return "\(str),\(thousandNum(num: res.1))"
        }
        return "\(res.0),\(thousandNum(num: res.1))"
    }
    
    //处理【333,444】中的【444】部分显示
    fileprivate static func thousandNum(num: Int) -> String {
        switch num {
        case let num where num >= 100:
            return "\(num)"
        case let num where num < 100 && num >= 10:
            return "0\(num)"
        case let num where num < 10:
            return "00\(num)"
        default:
            return "0"
        }
    }
    
    //分割千位和万位以上部分
    fileprivate static func seperateNum(num: Int) -> (Int, Int) {
        if isMoreThanOneThousand(num: num) {
            return (num/1000, num%1000)
        }
        return (0, num%1000)
    }
    
    //判断是否大于1000
    fileprivate static func isMoreThanOneThousand(num: Int) -> Bool {
        return num >= 1000
    }
}
