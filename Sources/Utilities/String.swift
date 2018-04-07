//
//  String.swift
//  HLSCore
//
//  Created by Fabian Canas on 8/19/16.
//  Copyright © 2016 Fabian Canas. All rights reserved.
//

import Foundation

extension String {
    
    public var fullRange :Range<Index> {
        get {
            return Range(uncheckedBounds: (lower: startIndex, upper: endIndex))
        }
    }
    
    public func deepestDirectoryPath() -> String {
        if self.hasSuffix("/") {
            return self
        }
        guard let lastSlashIndex = self.range(of: "/", options: .backwards)?.lowerBound else {
            return "/"
        }
        
        return String(self[..<self.index(after: lastSlashIndex)])
    }
    
}

extension NSString {
    public var fullRange :NSRange {
        get {
            return NSRange(location: 0, length: self.length)
        }
    }
}
