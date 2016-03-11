//
//  imageCellCollectionViewCell.swift
//  CodeTest
//
//  Created by alexfu on 3/10/16.
//  Copyright © 2016 alexfu. All rights reserved.
//

import UIKit

class imageCell: UICollectionViewCell {
    
    @IBOutlet weak var imgView: UIImageView!
    
    @IBOutlet weak var idText: UITextField!
    override func prepareForReuse() {
        super.prepareForReuse()
        
        imgView.image = nil
        
    }
}
