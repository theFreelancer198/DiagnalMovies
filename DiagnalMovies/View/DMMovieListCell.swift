//
//  DMMovieListCell.swift
//  DiagnalMovies
//
//  Created by Abhishek on 29/04/20.
//  Copyright © 2020 Abhishek. All rights reserved.
//

import UIKit

class DMMovieListCell: UICollectionViewCell {
    
    @IBOutlet weak var movieCellBg: UIView!
    @IBOutlet weak var movieNameLabel: UILabel!
    @IBOutlet weak var movieThumbImageView: UIImageView!
    
    override func prepareForReuse() {
        super.prepareForReuse()
        configure(with: nil)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    func configure(with movie: Movie?) {
        if let movie = movie {
            movieNameLabel?.text = movie.name
            let image = UIImage(named: movie.posterImage) ??  UIImage(named:"placeholder_for_missing_posters.png")!
            movieThumbImageView?.image = image
        } else {
            //            displayNameLabel.alpha = 0
            //            reputationContainerView.alpha = 0
            //            indicatorView.startAnimating()
        }
    }
}

