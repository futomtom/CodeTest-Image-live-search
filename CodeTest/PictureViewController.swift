//
//  PictureViewController.swift
//  CodeTest
//
//  Created by alexfu on 3/11/16.
//  Copyright © 2016 alexfu. All rights reserved.
//

import UIKit
import Kingfisher

class PictureViewController: UIViewController {
    
    var url:String = ""

    @IBOutlet weak var FullImageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        FullImageView.kf_setImageWithURL(NSURL(string: url)!)

    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

 
}
