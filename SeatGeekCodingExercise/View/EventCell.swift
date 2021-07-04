//
//  EventCell.swift
//  SeatGeekCodingExercise
//
//  Created by endOfLine on 3/10/21.
//

import UIKit

class EventCell: UITableViewCell {

    @IBOutlet var thumbnail: UIImageView! {
        didSet {
            thumbnail.layer.cornerRadius = 16
            thumbnail.clipsToBounds = true
        }
    }
    @IBOutlet var activityIndicator: UIActivityIndicatorView!
    @IBOutlet var favorite: UIImageView!
    @IBOutlet var title: UILabel!
    @IBOutlet var location: UILabel!
    @IBOutlet var time: UILabel!
    
    let favorites = Favorites()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func displayLoaded(_ event: EventsResponse.Event, image: UIImage?) {
        
        title.text = event.title
        favorite.image = (favorites.isFavorite(event.id) ? UIImage(named: "heartFill") : nil)
        favorites.isFavorite(event.id) ? (favorite.image = UIImage(named: "heartFill")) : (favorite.image = nil)
        location.text = event.venue?.display_location
        time.text = event.day + "\n" + event.time
        if let image = image {
            activityIndicator.stopAnimating()
            thumbnail.image = image
        } else {
            activityIndicator.startAnimating()
        }
    }
    
    func displayLoading() {
//        print("cell displayLoading")
        title.text = "_____ ___ __________ _______ _____ ___________"
        favorite.image = nil
        location.text = "__ _______"
        time.text = "______ _____ _ ____\n____ __"
        thumbnail.image = nil
        activityIndicator.startAnimating()
    }
}
