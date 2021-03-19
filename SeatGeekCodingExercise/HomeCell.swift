//
//  HomeCell.swift
//  SeatGeekCodingExercise
//
//  Created by endOfLine on 3/10/21.
//

import UIKit

class HomeCell: UITableViewCell {

    @IBOutlet var thumbnail: UIImageView! {
        didSet {
            thumbnail.layer.cornerRadius = 16
            thumbnail.clipsToBounds = true
        }
    }
    @IBOutlet var activityIndicator: UIActivityIndicatorView! {
        didSet {
            //activityIndicator.startAnimating()
        }
    }
    @IBOutlet var favorite: UIImageView!
    @IBOutlet var title: UILabel!
    @IBOutlet var location: UILabel!
    @IBOutlet var time: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
