//
//  YHLCacheObject.swift
//  test
//
//  Created by Jack on 2017/8/25.
//  Copyright © 2017年 Jack. All rights reserved.
//

import UIKit

class YHLCacheObject: NSObject,NSCoding {
    
    let date:Date?
    let object:AnyObject
    
    init(_ time:Date?,_ obj:AnyObject) {
        date = time
        object = obj
        super.init()
    }
    
    var isOutTime:Bool {
        if let d = date,d.timeIntervalSinceNow<0{
            return false
        }
        return true
        
    }
    
    func encode(with aCoder: NSCoder){
        aCoder.encode(date, forKey: "date")
        aCoder.encode(object, forKey: "object")
    }
    
    required init?(coder aDecoder: NSCoder){
        
        guard let d = aDecoder.decodeObject(forKey: "date") as? Date,
              let obj = aDecoder.decodeObject(forKey: "object") else {
            return nil
        }
        date = d
        object = obj as AnyObject
        super.init()
    }
    

}
