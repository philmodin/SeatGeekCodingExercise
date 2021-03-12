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
    var thumbnailImage: UIImage?
    var isFavorite = false
    
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
        //checkFav()
        assignProperties()
        configureFavButton()
    }
    
    func assignProperties() {
        title = event.title
        if ((defaults.object(forKey: "favs") as? [Int])!.contains(event.id)) { isFavorite = true }
        thumbnail.image = thumbnailImage
        dateTime.text = SeatGeek.stringDayFrom(date: SeatGeek.dateFrom(rfc: event.datetime_local)) + SeatGeek.stringTimeFrom(date: SeatGeek.dateFrom(rfc: event.datetime_local))
        place.text = event.venue.city + ", " + event.venue.state
    }
    
    func checkFav() {
        if let favs = defaults.object(forKey: "favs") as? [Int] {
            if favs.contains(event.id) { isFavorite = true } else { isFavorite = false }
        }
    }
    
    func setFav() {
        if var favsArray = defaults.object(forKey: "favs") as? [Int] {
//            var favsSet: Set<Int> = Set(favsArray.map { $0 })
            var favsSet = Set(favsArray)
            if isFavorite {
                favsSet.insert(event.id)
            } else {
                favsSet.remove(event.id)
            }
            favsArray = Array(favsSet)
            defaults.setValue(favsArray, forKey: "favs")
        } else {
            defaults.set([event.id], forKey: "favs")
        }
    }
    
    func configureFavButton() {
        if isFavorite {
            navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "heart.fill"), style: .plain, target: self, action: #selector(toggleFav))
            navigationItem.rightBarButtonItem?.tintColor = .systemPink

        } else {
            navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "heart"), style: .plain, target: self, action: #selector(toggleFav))
            navigationItem.rightBarButtonItem?.tintColor = .white
        }
    }
    
    @objc func toggleFav() {
        print("toggle fav")
        isFavorite.toggle()
        setFav()
        configureFavButton()
        tableView.reloadRows(at: [index], with: .automatic)
    }
}

