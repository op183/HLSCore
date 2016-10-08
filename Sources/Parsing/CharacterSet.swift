//
//  CharacterSet.swift
//  HLSCore
//
//  Created by Fabian Canas on 9/4/16.
//  Copyright © 2016 Fabian Canas. All rights reserved.
//

import Foundation

extension CharacterSet {
    /// Characters allowed in an upper-case hex number, not including an X for prefixing
    ///
    ///`[0...9, A...F]`
    static let hexidecimalDigits = CharacterSet.decimalDigits.union(CharacterSet(charactersIn: "A"..."F"))
    
    /// Characters allowed in a quoted string.
    /// 
    /// Inverse of `[\r, \n, "]`
    static let forQuotedString = CharacterSet(charactersIn: "\r\n\"").inverted
    
    /// Valid characters in an enumerated string
    ///
    /// Like a quoted string additionally not allowing whitespace nor commas
    static let forEnumeratedString = CharacterSet(charactersIn: ",\"").union(CharacterSet.whitespacesAndNewlines).inverted
    
    /// Valid characters in an attributed name
    ///
    /// `[A...Z, 0...9, -]`
    static let forAttributeName = CharacterSet(charactersIn: "A"..."Z").union(CharacterSet(charactersIn: "0"..."9")).union(CharacterSet(charactersIn: "-"))
    
    /// Valid characters in a URL
    static let urlAllowed = CharacterSet.urlUserAllowed.union(.urlHostAllowed).union(.urlPathAllowed).union(.urlQueryAllowed).union(.urlFragmentAllowed).union(.urlPasswordAllowed).union(CharacterSet(charactersIn:":"))
    
    /// Valid characters in an ISO 8601 date
    static let iso8601 = CharacterSet.decimalDigits.union(CharacterSet(charactersIn: "WTZ/+:−-"))
}