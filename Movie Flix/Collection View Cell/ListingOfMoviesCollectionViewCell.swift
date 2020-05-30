//
//  ListingOfMoviesCollectionViewCell.swift
//  Movie Flix
//
//  Created by Apple on 27/05/20.
//  Copyright © 2020 Pratik Patil. All rights reserved.
//

import UIKit

class ListingOfMoviesCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet var imgMovie: UIImageView!
    
    @IBOutlet var lblMovieDescription: UILabel!
    @IBOutlet var lblMovieTitle: UILabel!
    
    @IBOutlet var btnDelete: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

}
