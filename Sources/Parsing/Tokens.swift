//
//  Tokens.swift
//  HLSCore
//
//  Created by Fabian Canas on 9/3/16.
//  Copyright © 2016 Fabian Canas. All rights reserved.
//

import Foundation

/// Foundation

func character( condition: @escaping (Character) -> Bool) -> Parser<Character> {
    return Parser { stream in
        guard let char = stream.first, condition(char) else { return nil }
        return (char, stream.dropFirst())
    }
}

func character(in characterSet: CharacterSet ) -> Parser<Character> {
    return character(condition: { characterSet.contains($0.unicodeScalar) } )
}

func string(_ string: String) -> Parser<String> {
    return Parser<String> { stream in
        var remainder = stream
        for char in string.characters {
            guard let (_, newRemainder) = character(condition: { $0 == char }).parse(remainder) else {
                return nil
            }
            remainder = newRemainder
        }
        return (string, remainder)
    }
}

extension Character {
    public var unicodeScalar: UnicodeScalar {
        return String(self).unicodeScalars.first!
    }
}

/// First Order

let digit = character(in: CharacterSet.decimalDigits)

let hexDigit = character(in: CharacterSet.hexidecimalDigits)

// Fragments

let hexPrefix = string("0x") <|> string("0X")

let decimalPoint = string(".")

let negation = string("-")

let quote = string("\"")

let x = character { $0 == "x" }

let numericString = { String($0) } <^> digit.many1

let floatingPointString = numericString.followed(by: decimalPoint, combine: +).followed(by: numericString, combine: +)

let int = { characters in UInt(String(characters))! } <^> digit.many1

let newline = character { $0 == "\n" } <|> (character { $0 == "\n" } <* character { $0 == "\r" })

let url = { URL(string: $0) } <^> ({ String($0) } <^> character(in: CharacterSet.urlAllowed).many1)
