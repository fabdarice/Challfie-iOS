//
//  Haneke.swift
//  Haneke
//
//  Created by Hermes Pique on 9/9/14.
//  Copyright (c) 2014 Haneke. All rights reserved.
//

import UIKit

public struct HanekeGlobals {
    
    public static let Domain = "io.haneke"
    
}


public struct Haneke {
    
    public struct Shared {
        
        public static var imageCache : HNKCache<UIImage> {
            struct Static {
                static let name = "shared-images"
                static let cache = HNKCache<UIImage>(name: name)
            }
            return Static.cache
        }
        
        public static var dataCache : HNKCache<NSData> {
            struct Static {
                static let name = "shared-data"
                static let cache = HNKCache<NSData>(name: name)
            }
            return Static.cache
        }
        
        public static var stringCache : HNKCache<String> {
            struct Static {
                static let name = "shared-strings"
                static let cache = HNKCache<String>(name: name)
            }
            return Static.cache
        }
        
        public static var JSONCache : HNKCache<JSON> {
            struct Static {
                static let name = "shared-json"
                static let cache = HNKCache<JSON>(name: name)
            }
            return Static.cache
        }
    }
    
    static func errorWithCode(code : Int, description : String) -> NSError {
        let userInfo = [NSLocalizedDescriptionKey: description]
        return NSError(domain: HanekeGlobals.Domain, code: code, userInfo: userInfo)
    }
    
    struct Log {
        
        static func error(message : String, _ error : NSError? = nil) {
            if let error = error {
                NSLog("%@ with error %@", message, error);
            } else {
                NSLog("%@", message)
            }
        }
        
    }
}