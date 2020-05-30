//
//  MovieDetailsViewController.swift
//  Movie Flix
//
//  Created by Apple on 26/05/20.
//  Copyright © 2020 Pratik Patil. All rights reserved.
//

import UIKit

class MovieDetailsViewController: UIViewController {
    
    var imgPosterString = ""
    var overviewString = ""
    var movieReleaseDate = ""
    var movieTitle = ""
    var avgVote = ""
    var duration = ""
    
    @IBOutlet var imgPoster: UIImageView!
    @IBOutlet var lblMovieTitle: UILabel!
    @IBOutlet var lblMovieDescribtion: UITextView!
    @IBOutlet var lblReleaseDate: UILabel!
    @IBOutlet var lblVotePercentage: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        self.navigationController?.navigationBar.barTintColor = UIColor(red: 238/255, green: 184/255, blue: 83/255, alpha: 1)
        self.navigationController?.navigationBar.tintColor = UIColor.darkGray
        self.lblMovieTitle.text = movieTitle
        self.lblMovieDescribtion.text = overviewString
        self.lblReleaseDate.text = movieReleaseDate
        self.lblVotePercentage.text = "Rating: \(avgVote)"
        
        DispatchQueue.main.async() { //[weak self] in
            let url = URL(string: self.imgPosterString)
            let data = try? Data(contentsOf: url!)
            if let imageData = data { let image = UIImage(data: imageData)
                self.imgPoster.image = image
            }
        }
    }
}
