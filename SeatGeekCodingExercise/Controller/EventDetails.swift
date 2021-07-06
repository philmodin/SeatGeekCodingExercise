//
//  ViewController.swift
//  SeatGeekCodingExercise
//
//  Created by endOfLine on 3/9/21.
//

import UIKit
import MapKit
import SafariServices

class EventDetails: UIViewController, MKMapViewDelegate, SFSafariViewControllerDelegate {

    let defaults = UserDefaults.standard
    
    weak var tableView: UITableView!
    weak var searchController: UISearchController!
    var index: IndexPath!
    var event: EventsResponse.Event!
    var image = UIImage.placeholder
    let favButton = UIButton(type: .custom)
    let favorites = Favorites()
    var mapRegionThatFits: MKCoordinateRegion?
    var safari: SFSafariViewController!
    
    @IBOutlet var mapView: MKMapView!
    @IBOutlet var thumbnail: UIImageView! {
        didSet {
            thumbnail.layer.cornerRadius = 32
            thumbnail.clipsToBounds = true
        }
    }
    @IBOutlet var eventTitle: UILabel!
    @IBOutlet var venue: UILabel!
    @IBOutlet var city: UILabel!
    @IBOutlet var date: UILabel!
    @IBOutlet var time: UILabel!
    @IBOutlet var ticketsButton: UIButton! {
        didSet {
            ticketsButton.layer.cornerRadius = 32
        }
    }
    @IBOutlet var priceRange: UILabel!
    
    @IBAction func ticketsTapped(_ sender: UIButton) {
        ticketsPresent()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        assignProperties()
        favButtonConfigure()
        mapConfigure()
        ticketsConfigure()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if let region = mapRegionThatFits { mapView.setRegion(region, animated: true) }
    }
    
    func assignProperties() {
        eventTitle.text = event.title
        thumbnail.image = image
        venue.text = event.venue?.name
        city.text = event.venue?.display_location
        date.text = event.day
        time.text = event.time
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
    
    func mapAddAnnotation(for venue: EventsResponse.Event.Venue) {
        let annotation = MKPointAnnotation()
        annotation.title = venue.name
        annotation.coordinate = venue.coordinates
        mapView.addAnnotation(annotation)
    }
    
    func mapConfigure() {
        if let venue = event.venue {
            mapView.delegate = self
            mapView.centerCoordinate = venue.coordinates
            
            let regionClose = MKCoordinateRegion(center: venue.coordinates, latitudinalMeters: 2_000, longitudinalMeters: 2_000)
            mapRegionThatFits = mapView.regionThatFits(regionClose)
            
            let regionFar = MKCoordinateRegion(center: venue.coordinates, latitudinalMeters: 60_000, longitudinalMeters: 60_000)
            mapView.region = regionFar
            
            mapAddAnnotation(for: venue)
        } else {
            mapView.isHidden = true
        }
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard annotation is MKPointAnnotation else { return nil }
        
        let reuseID = "annotation"
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseID)
        
        if annotationView == nil {
            annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseID)
            annotationView?.canShowCallout = true
        } else {
            annotationView?.annotation = annotation
        }
        return annotationView
    }
    
    func ticketsConfigure() {
        if let url = URL(string: event.url) {
            safari = SFSafariViewController(url: url)
            safari.modalPresentationStyle = .pageSheet
            safari.delegate = self
            if let lowest = event.stats.lowest_price, let highest = event.stats.highest_price {
                let prices = "$\(lowest) - $\(highest)"
                priceRange.text = prices
                return
            }
        } else {
            ticketsButton.isEnabled = false
        }
        priceRange.text = ""
    }
    
    func ticketsPresent() {
        if searchController.isActive {
            searchController.present(safari, animated: true)
        } else {
            present(safari, animated: true, completion: nil)
        }
    }
    
    func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
        controller.dismiss(animated: true, completion: nil)
    }
}

