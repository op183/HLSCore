//
//  Tags.swift
//  HLSCore
//
//  Created by Fabian Canas on 9/5/16.
//  Copyright © 2016 Fabian Canas. All rights reserved.
//

import Foundation
import Types

/// The first tag
let PlaylistStart = string("#EXTM3U")

let URLPseudoTag = Tag.url <^> TypeParser.url

// MARK: Aggregate Tags

let MediaPlaylistTag = ExclusiveMediaPlaylistTag <|> SegmentTag <|> PlaylistTag

let MasterPlaylistTag = ExclusiveMasterPlaylistTag <|> PlaylistTag

let PlaylistTag = AnyTag.playlist <^> EXTVERSION <|>
                                      EXTXINDEPENDENTSEGMENTS <|>
                                      URLPseudoTag

let SegmentTag = AnyTag.segment <^> EXTINF <|>
                                    EXTXBYTERANGE <|>
                                    EXTXDISCONTINUITY <|>
                                    EXTXKEY <|>
                                    EXTXMAP <|>
                                    EXTXPROGRAMDATETIME <|>
                                    EXTXDATERANGE

let ExclusiveMediaPlaylistTag = AnyTag.media <^> EXTXTARGETDURATION <|>
                                                 EXTXMEDIASEQUENCE <|>
                                                 EXTXDISCONTINUITYSEQUENCE <|>
                                                 EXTXENDLIST <|>
                                                 EXTXPLAYLISTTYPE <|>
                                                 EXTXIFRAMESONLY

let ExclusiveMasterPlaylistTag = AnyTag.master <^> EXTXMEDIA <|>
                                                   EXTXSTREAMINF <|>
                                                   EXTXIFRAMESTREAMINF <|>
                                                   EXTXSESSIONDATA <|>
                                                   EXTXSESSIONKEY

// MARK: Basic Tags

let EXTVERSION = Tag.version <^> string("#EXT-X-VERSION:") *> BasicParser.int

let EXTXINDEPENDENTSEGMENTS = { _ in Tag.independentSegments } <^> string("#EXT-X-INDEPENDENT-SEGMENTS")

let EXTXSTART = Tag.startIndicator <^> ( StartIndicator.init <^!> ( string("#EXT-X-START:") *> attributeList ))

// MARK: Media Segment Tags

let EXTINF = Tag.MediaPlaylist.Segment.inf <^> string("#EXTINF:") *> (( decimalFloatingPoint <|> decimalInteger ) <* character { $0 == "," } <&> ({ String($0) } <^!> character(in: CharacterSet.newlines.inverted).many).optional)

let EXTXBYTERANGE = Tag.MediaPlaylist.Segment.byteRange <^> ( string("#EXT-X-BYTERANGE:") *> TypeParser.byteRange )

let EXTXDISCONTINUITY = { _ in Tag.MediaPlaylist.Segment.discontinuity } <^> string("#EXT-X-DISCONTINUITY")

let EXTXKEY = Tag.MediaPlaylist.Segment.key <^> (DecryptionKey.init <^!> string("#EXT-X-KEY:") *> attributeList )

let EXTXMAP = Tag.MediaPlaylist.Segment.map <^> ( MediaInitializationSection.init <^!> string("#EXT-X-MAP:") *> attributeList )

let EXTXPROGRAMDATETIME = Tag.MediaPlaylist.Segment.programDateTime <^> string("#EXT-X-PROGRAM-DATE-TIME:") *> TypeParser.date

let EXTXDATERANGE = Tag.MediaPlaylist.Segment.dateRange <^> string("#EXT-X-DATERANGE:") *> attributeList

// MARK: Media Playlist Tags

let EXTXTARGETDURATION = Tag.MediaPlaylist.targetDuration <^> string("#EXT-X-TARGETDURATION:") *> decimalInteger

let EXTXMEDIASEQUENCE = Tag.MediaPlaylist.mediaSequence <^> string("#EXT-X-MEDIA-SEQUENCE:") *> decimalInteger

let EXTXDISCONTINUITYSEQUENCE = Tag.MediaPlaylist.discontinuitySequence <^> string("#EXT-X-DISCONTINUITY-SEQUENCE:") *> decimalInteger

let EXTXENDLIST = { _ in Tag.MediaPlaylist.endList } <^> string("#EXT-X-ENDLIST")

let EXTXPLAYLISTTYPE = Tag.MediaPlaylist.playlistType <^> string("#EXT-X-PLAYLIST-TYPE:") *> enumeratedString

let EXTXIFRAMESONLY = { _ in Tag.MediaPlaylist.iFramesOnly } <^> string("#EXT-X-I-FRAMES-ONLY")

// MARK: Master Playlist Tags

let EXTXMEDIA = Tag.MasterPlaylist.media <^> ( Rendition.init <^!> string("#EXT-X-MEDIA:") *> attributeList)

let EXTXSTREAMINF = Tag.MasterPlaylist.streamInfo <^> ( StreamInfo.init <^!>  string("#EXT-X-STREAM-INF:") *> attributeList <* BasicParser.newline.many <&> TypeParser.url)

let EXTXIFRAMESTREAMINF = Tag.MasterPlaylist.iFramesStreamInfo <^> string("#EXT-X-I-FRAME-STREAM-INF:") *> attributeList

let EXTXSESSIONDATA = Tag.MasterPlaylist.sessionData <^> string("#EXT-X-SESSION-DATA:") *> attributeList

let EXTXSESSIONKEY = Tag.MasterPlaylist.sessionKey <^> string("#EXT-X-SESSION-KEY:") *> attributeList

// MARK: Tag Taxonomy

enum AnyTag {
    case playlist(Tag)
    case media(Tag.MediaPlaylist)
    case segment(Tag.MediaPlaylist.Segment)
    case master(Tag.MasterPlaylist)
}

enum Tag {
    
    case version(UInt)
    
    case independentSegments
    case startIndicator(StartIndicator)
    
    /// Not a tag, but definitely a top-level element. Makes parsing easier.
    case url(URL)
    
    enum MediaPlaylist {
        case targetDuration(AttributeValue)
        case mediaSequence(AttributeValue)
        case discontinuitySequence(AttributeValue)
        case endList
        case playlistType(AttributeValue)
        case iFramesOnly
        
        enum Segment {
            case inf(AttributeValue, String?)
            case byteRange(CountableClosedRange<UInt>)
            case discontinuity
            
            case key(DecryptionKey)
            case map(MediaInitializationSection)
            
            case programDateTime(Date?)
            case dateRange(AttributeList)
        }
    }
    
    enum MasterPlaylist {
        case media(Rendition)
        case streamInfo(StreamInfo)
        case iFramesStreamInfo(AttributeList)
        case sessionData(AttributeList)
        case sessionKey(AttributeList)
    }
}

