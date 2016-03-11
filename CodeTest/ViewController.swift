//
//  ViewController.swift
//  CodeTest
//
//  Created by alexfu on 3/10/16.
//  Copyright © 2016 alexfu. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class ViewController: UISearchController{

    @IBOutlet weak var SearchBar: UISearchBar!
    @IBOutlet weak var collectView: UICollectionView!
    override func viewDidLoad() {
        super.viewDidLoad()
       
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    }




extension ViewController: UISearchResultsUpdating {
    
     func updateSearchResultsForSearchController(searchController: UISearchController) {
        guard let searchText = SearchBar.text
            where !searchText.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet()).characters.isEmpty
            else { return }
        self.Search(searchText,page: 0,completion: {})
    }
    
}


extension ViewController: UICollectionViewDataSource {
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 0
    }
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("cell", forIndexPath: indexPath) as! imageCell
        let image = UIImage(named: "add_buddy")!
        
        cell.imgView.image=image
        return cell
    }
   
     func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 0
    }
}

