//
//  ImgurService.swift
//  CodeTest
//
//  Created by alexfu on 3/10/16.
//  Copyright © 2016 alexfu. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON
import Kingfisher



class ImgurService {
    

    static func Search(searchString:String, page: Int,completion: (photos: [Picture]?, error:NSError?) -> Void)
    {
        var myPictures : [Picture] = []
        
        let url="https://api.imgur.com/3/gallery/search/viral"
        let headers = [
            "Authorization": "Client-ID 7c0055c9f21a3e8"
        ]
        
        let parameters = [
            "q": searchString,
            "page": page.description,
                    ]
        
        Alamofire.request(.GET,url, parameters: parameters,headers: headers).responseJSON{
            response in
            
             let jsonObject = JSON(response.result.value!)
             let  pictures = jsonObject["data"]
                
            for (_, object) in pictures {
                let is_album=object["is_album"].stringValue
                if(is_album=="false")
                {
                let picture = Picture(photoData: object)
                myPictures.append(picture)
                }
            }
            print("\(myPictures.count)")
       /*
            let urls = myPictures.map { NSURL(string: $0.thumbUrl)! }
            let prefetcher = ImagePrefetcher(urls: urls, optionsInfo: nil, progressBlock: nil, completionHandler: {
                (skippedResources, failedResources, completedResources) -> () in
             //   print("These resources are prefetched: \(completedResources)")
            })
            prefetcher.start()
        */    
            
            
            
        completion(photos: myPictures, error: nil)
        }
        
    }

    
   
    
 }