//
//  ViewController.swift
//  FetchRewardsCodingExercise
//
//  Created by endOfLine on 3/9/21.
//

import UIKit

class EventDetails: UIViewController {

    let defaults = UserDefaults.standard
    
    weak var tableView: UITableView!
    var index: IndexPath!
    var event: Event!
    var image: UIImage!
    var isFavorite = false
    let favButton = UIButton(type: .custom)
    
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
        configureFavButton()
    }
    
    func assignProperties() {
        title = event.title
        if ((defaults.object(forKey: "favs") as? [Int])!.contains(event.id)) { isFavorite = true }
        
        view.layoutIfNeeded()
        thumbnail.image = image
        let imageRatio = image.size.width / image.size.height
        let height = thumbnail.frame.width / imageRatio
        thumbnailHeight.constant = height
        
        dateTime.text = SeatGeek.stringDayFrom(date: SeatGeek.dateFrom(rfc: event.datetime_local)) + SeatGeek.stringTimeFrom(date: SeatGeek.dateFrom(rfc: event.datetime_local))
        place.text = (event.venue?.city ?? "") + ", " + (event.venue?.state ?? "")
    }
    
    func setFav() {
        if var favsArray = defaults.object(forKey: "favs") as? [Int] {
            var favsSet = Set(favsArray)
            if isFavorite {
                favButton.setImage(UIImage(named:"heartFill"), for: .normal)
                favButton.tintColor = .systemPink
                favsSet.insert(event.id)
            } else {
                favButton.setImage(UIImage(named:"heartOutline"), for: .normal)
                favButton.tintColor = .white
                favsSet.remove(event.id)
            }
            favsArray = Array(favsSet)
            defaults.setValue(favsArray, forKey: "favs")
        } else {
            defaults.set([event.id], forKey: "favs")
        }
    }
    
    func configureFavButton() {
        favButton.frame = CGRect(x: 0.0, y: 0.0, width: 24, height: 24)
        favButton.imageView?.contentMode = .scaleAspectFit
        favButton.setImage(UIImage(named:"heartOutline"), for: .normal)
        favButton.addTarget(self, action: #selector(toggleFav), for: .touchUpInside)

        let menuBarItem = UIBarButtonItem(customView: favButton)
        let currWidth = menuBarItem.customView?.widthAnchor.constraint(equalToConstant: 24)
        currWidth?.isActive = true
        let currHeight = menuBarItem.customView?.heightAnchor.constraint(equalToConstant: 24)
        currHeight?.isActive = true
        self.navigationItem.rightBarButtonItem = menuBarItem
        setFav()
    }
    
    @objc func toggleFav() {
        print("toggle fav")
        isFavorite.toggle()
        setFav()
        tableView.reloadRows(at: [index], with: .automatic)
    }
}

