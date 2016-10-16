//
//  PlaylistParser.swift
//  HLSCore
//
//  Created by Fabian Canas on 10/16/16.
//  Copyright © 2016 Fabian Canas. All rights reserved.
//

import Foundation
import Types

let newlines = BasicParser.newline.many1

func playlist(string :String, atURL url: URL) -> MediaPlaylist? {
    
    let parser = PlaylistStart *> (MediaPlaylistTag <* newlines).many
    
    let parseResult = parser.run(string)

    struct OpenMediaSegment {
        var duration :TimeInterval?
        var title :String?
        var byteRange :CountableClosedRange<UInt>?
        var programDateTime :Date?
        var discontinuity :Bool?
    }
    
    struct PlaylistBuilder {
        var playlistType :MediaPlaylist.PlaylistType?
        var version :UInt = 1
        var duration :TimeInterval?
        var start :StartIndicator?
        var segments :[MediaSegment] = []
        var closed :Bool?
        
        var activeKey :DecryptionKey?
        var activeMediaInitializationSection :MediaInitializationSection?
        
        var openSegment :OpenMediaSegment?
        
        var fatalTag :AnyTag?
    }
    
    guard let tags = parseResult?.0 else {
        return nil
    }
    
    let playlistBuilder = tags.reduce(PlaylistBuilder(), { (state :PlaylistBuilder, tag :AnyTag) -> PlaylistBuilder in
        
        var builder = state
        
        switch tag {
        case let .playlist(playlist):
            switch playlist {
            case let .version(version):
                builder.version = version
            case .independentSegments:
                // TODO: encode independent segments in structs
                break
            case let .startIndicator(attributes):
                builder.start = StartIndicator(attributes: attributes)
            }
        case let .media(media):
            switch media {
            case let .targetDuration(duration):
                switch duration {
                case let .decimalFloatingPoint(f):
                    builder.duration = f
                case let .decimalInteger(i):
                    builder.duration = TimeInterval(i)
                default:
                    builder.fatalTag = tag
                }
            case .mediaSequence(_):
                // TODO: Media Sequence Unimplemented
                break
            case .discontinuitySequence(_):
                // TODO: Discontinuity Sequence Unimplemented
                break
            case .endList:
                builder.closed = true
            case let .playlistType(type):
                switch type {
                case let .enumeratedString(string):
                    builder.playlistType = MediaPlaylist.PlaylistType(rawValue: string.rawValue)
                default:
                    builder.fatalTag = tag
                }
            case .iFramesOnly:
                // TODO: i-frame lists not implemented
                break
            }
        case let .segment(segment):
            var openSegment = builder.openSegment ?? OpenMediaSegment()
            
            switch segment {
            case let .inf(duration, title):
                switch duration {
                case let .decimalFloatingPoint(f):
                    openSegment.duration = f
                case let .decimalInteger(i):
                    openSegment.duration = TimeInterval(i)
                default:
                    builder.fatalTag = tag
                }
                openSegment.title = title
            case let .byteRange(byteRange):
                openSegment.byteRange = byteRange
            case .discontinuity:
                // Probably applies to the _next_ segment, not the current one.
                openSegment.discontinuity = true
            case let .key(attributes):
                builder.activeKey = DecryptionKey(attributes: attributes)
            case let .map(attributes):
                builder.activeMediaInitializationSection = MediaInitializationSection(attributes: attributes)
            case let .programDateTime(date):
                openSegment.programDateTime = date
            case .dateRange(_):
                // TODO: Date Range
                break
            }
            
        case .master(_):
            builder.fatalTag = tag
        }
        
        return builder
    })
    
    guard let targetDuration = playlistBuilder.duration, let closed = playlistBuilder.closed else {
        return nil
    }
    
    return MediaPlaylist(type: playlistBuilder.playlistType, version: playlistBuilder.version, uri: url, targetDuration: targetDuration, closed: closed, start: playlistBuilder.start, segments: playlistBuilder.segments)
}