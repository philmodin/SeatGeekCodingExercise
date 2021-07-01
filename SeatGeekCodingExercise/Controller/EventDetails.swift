//
//  ViewController.swift
//  SeatGeekCodingExercise
//
//  Created by endOfLine on 3/9/21.
//

import UIKit

class EventDetails: UIViewController {

    let defaults = UserDefaults.standard
    
    weak var tableView: UITableView!
    var index: IndexPath!
    var event: EventsResponse.Event!
    var image: UIImage!
    let favButton = UIButton(type: .custom)
    let favorites = Favorites()
    
    @IBOutlet var thumbnailHeight: NSLayoutConstraint!
    @IBOutlet var thumbnail: UIImageView! {
        didSet {
            thumbnail.layer.cornerRadius = 16
            thumbnail.clipsToBounds = true
        }
    }
    @IBOutlet var dateTime: UILabel!
    @IBOutlet var place: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        assignProperties()
        favButtonConfigure()
    }
    
    func assignProperties() {
        title = event.title
        
        view.layoutIfNeeded()
        thumbnail.image = image
        let imageRatio = image.size.width / image.size.height
        let height = thumbnail.frame.width / imageRatio
        thumbnailHeight.constant = height
        
        place.text = event.cityState
        dateTime.text = event.day + " " + event.time
    }
    
    func favButtonConfigure() {
        favButton.frame = CGRect(x: 0.0, y: 0.0, width: 24, height: 24)
        favButton.imageView?.contentMode = .scaleAspectFit
        favButton.setImage(UIImage(named:"heartOutline"), for: .normal)
        favButton.addTarget(self, action: #selector(favButtonTapped), for: .touchUpInside)

        let menuBarItem = UIBarButtonItem(customView: favButton)
        let currWidth = menuBarItem.customView?.widthAnchor.constraint(equalToConstant: 24)
        currWidth?.isActive = true
        let currHeight = menuBarItem.customView?.heightAnchor.constraint(equalToConstant: 24)
        currHeight?.isActive = true
        self.navigationItem.rightBarButtonItem = menuBarItem
        favButtonUpdate()
    }
    
    func favButtonUpdate() {
        if favorites.isFavorite(event.id) {
            favButton.setImage(UIImage(named:"heartFill"), for: .normal)
            favButton.tintColor = .systemPink
        } else {
            favButton.setImage(UIImage(named:"heartOutline"), for: .normal)
            favButton.tintColor = .white
        }
    }
    
    @objc func favButtonTapped() {
        favorites.toggle(event.id)
        favButtonUpdate()
        tableView.reloadRows(at: [index], with: .automatic)
    }
}

