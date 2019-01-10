//
//  MapViewController.swift
//  VK Project
//
//  Created by Denis Abramov on 06/11/2018.
//  Copyright © 2018 Denis Abramov. All rights reserved.
//

import Foundation
import MapKit
import CoreLocation

class MapPin: NSObject, MKAnnotation {
    var coordinate: CLLocationCoordinate2D
    var title: String?
    var subtitle: String?
    init(coordinate: CLLocationCoordinate2D, title: String?, subtitle: String?) {
        self.coordinate = coordinate
        self.title = title
        self.subtitle = subtitle
    }
}

class MapViewController: UIViewController, CLLocationManagerDelegate {
    var locationTouch: CLLocation = CLLocation(latitude: 0, longitude: 0)
    
    @IBOutlet weak var mapView: MKMapView!
    
    let locationManager = CLLocationManager()
    override func viewDidLoad() {
        super.viewDidLoad()
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager.requestWhenInUseAuthorization()
        self.locationManager.startUpdatingLocation()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let currentLocation = locations.last?.coordinate {
            if let currentSpeed = locations.last?.speed{
                print(currentSpeed)
            }
            print(currentLocation)
            let coordinate = CLLocation(latitude: currentLocation.latitude, longitude: currentLocation.longitude)
            let coder = CLGeocoder()
            coder.reverseGeocodeLocation(coordinate) {(myPlaces,Error) -> Void in
                if let place = myPlaces?.first {
                    print(place.description)
                    self.locationTouch = coordinate
                }
            }
            let currentRadius: CLLocationDistance = 1000
            let currentRegion = MKCoordinateRegion(center: (currentLocation), latitudinalMeters: currentRadius * 2.0, longitudinalMeters: currentRadius * 2.0)
            self.mapView.setRegion(currentRegion, animated: true)
            self.mapView.showsUserLocation = true
        }
    }
}
