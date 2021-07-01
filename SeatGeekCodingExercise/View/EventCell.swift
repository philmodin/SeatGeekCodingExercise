//
//  EventCell.swift
//  SeatGeekCodingExercise
//
//  Created by endOfLine on 3/10/21.
//

import UIKit

//enum EventCellStatus { case loaded, loading, noConnection, noEvents }

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
    
//    func configureView(_ status: EventCellStatus, _ event: EventsResponse.Event) {
//        
//        selectionStyle = .none
//        
//        switch status {
//        case .loaded: displayLoaded(event)
//        case .loading: displayLoading()
//        case .noConnection: displayNoConnection()
//        case .noEvents: displayNoEvents()
//        }
//    }
    
    func displayLoaded(_ event: EventsResponse.Event) {
        
        title.text = event.title
        favorite.image = (favorites.isFavorite(event.id) ? UIImage(named: "heartFill") : nil)
        favorites.isFavorite(event.id) ? (favorite.image = UIImage(named: "heartFill")) : (favorite.image = nil)
        location.text = (event.venue?.city ?? "") + ", " + (event.venue?.state ?? "")
        time.text = event.day + "\n" + event.time
        SGRequest().thumbnail(for: event.performers[0]?.imageURL) { [weak self] image in
            DispatchQueue.main.async {
                self?.thumbnail.image = image
            }
        }
    }
    
    func displayLoading() {
        
        title.text = "_____ ___ __________ _______ _____ ___________"
        favorite.image = nil
        location.text = "__ _______"
        time.text = "______ _____ _ ____\n____ __"
        thumbnail.image = nil
        activityIndicator.startAnimating()
    }
    
    func displayNoConnection() {
        
        title.text = "\nCheck internet connection 🔌"
        favorite.image = nil
        location.text = ""
        time.text = ""
        thumbnail.image = nil
        activityIndicator.stopAnimating()
    }
    
    func displayNoEvents() {
        
        title.text = "\n0 events 🤷‍♂️"
        favorite.image = nil
        location.text = ""
        time.text = ""
        thumbnail.image = nil
        activityIndicator.stopAnimating()
    }
}
