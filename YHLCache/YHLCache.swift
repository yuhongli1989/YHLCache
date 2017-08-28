//
//  YHLCache.swift
//  test
//
//  Created by Jack on 2017/8/25.
//  Copyright © 2017年 Jack. All rights reserved.
//

import UIKit

class YHLCache: NSObject {
    
    private lazy var defaultPath:URL = {
        var url = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        return url.appendingPathComponent("YHLStore")
        
    }()
    
    private let manager = FileManager.default
    
    static let cache = NSCache<NSString,YHLCacheObject>()
    
    
    
    override init() {
        super.init()
        print(defaultPath)
        if !manager.fileExists(atPath: defaultPath.path) {
            do {
                try manager.createDirectory(at: defaultPath, withIntermediateDirectories: true, attributes: nil)
            } catch  {
                print("创建文件夹失败")
            }
        }
    }
    
    func remove(forKey:String)  {
        
        YHLCache.cache.removeObject(forKey: forKey as NSString)
        let path = defaultPath.appendingPathComponent(forKey)
        if manager.fileExists(atPath: path.path) {
            do {
                try manager.removeItem(at: path)
            } catch  {
                print("移除文件失败")
            }
            
        }
        
    }
    //字节
    func fileSize()->Double  {
        var resultSize:Double = 0

        do {
            let urls = try manager.contentsOfDirectory(at: self.defaultPath, includingPropertiesForKeys: nil, options: [])
            for url in urls{
                let dict = try?  manager.attributesOfItem(atPath: url.path)
                if let size = dict?[FileAttributeKey(rawValue: "NSFileSize")] as? Double{
                    resultSize += size
                }
            }
            return resultSize
            
        } catch  {
            
        }
        return resultSize

    }
    
    func removeAll()  {
        YHLCache.cache.removeAllObjects()
        do {
            let urls = try manager.contentsOfDirectory(at: self.defaultPath, includingPropertiesForKeys: nil, options: [])
            for url in urls{

               try? manager.removeItem(at: url)
            }
            
        } catch  {
            
        }
        
    }
    
    func object(_ forKey:String)->AnyObject?{
        if let o = objectFromCache(forKey: forKey),o.isOutTime{
            return o.object
        }
        if let o = objectFromFile(forKey: forKey),o.isOutTime{
            return o.object
        }
        return nil
    }
    
    func setObject(_ objc:Any,_ forKey:String,_ time:YHLTimeLimit = .forever) ->Bool {
        let o = objc as AnyObject
        let path = defaultPath.appendingPathComponent(forKey)
        if manager.fileExists(atPath: path.path) {
            remove(forKey: forKey)
        }
        var ob:YHLCacheObject!
        switch time {
        case let .second(i):
            let d = Date(timeInterval: i, since: Date())
            
            ob = YHLCacheObject(d, o)
            break
        default:
             ob = YHLCacheObject(nil, o)
            break
        }
        YHLCache.cache.setObject(ob, forKey: forKey as NSString)
        let f = NSKeyedArchiver.archiveRootObject(ob, toFile: path.path)
        return f
    }
    
    
    private func objectFromCache(forKey:String)->YHLCacheObject?{
        
        return YHLCache.cache.object(forKey: forKey as NSString)
        
    }

    private func objectFromFile(forKey:String) -> YHLCacheObject? {
        let path = defaultPath.appendingPathComponent(forKey)
        
        if let oj = NSKeyedUnarchiver.unarchiveObject(withFile: path.path) as? YHLCacheObject{
            return oj
        }
        return nil
    }
}


enum YHLTimeLimit {
    case forever
    case second(Double)
}



