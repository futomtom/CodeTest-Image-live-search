//
//  Picture.swift
//  CodeTest
//
//  Created by alexfu on 3/10/16.
//  Copyright © 2016 alexfu. All rights reserved.

import UIKit
import SwiftyJSON




struct Picture
{
    var id:String!
    var imageUrl:String!
    var thumbUrl:String!

    init( photoData:JSON )
    {
        id = photoData["id"].string
        imageUrl = photoData["link"].string        
        thumbUrl=imageUrl
            
            //.substringToIndex((imageUrl.rangeOfString(".", options: .BackwardsSearch, range: nil)?.startIndex-1)!) + "s"
        
        
        let range = thumbUrl.rangeOfString(".", options: .BackwardsSearch, range: nil)
  //      let index = advance(range)
        let character = "s" as Character
        thumbUrl.insert(character, atIndex: range!.endIndex.advancedBy(-1))
       // print("\(thumbUrl)")
       
     //   thumbUrl = imageUrl.insert("s", atIndex: imageUrl.length-4)
    }
}