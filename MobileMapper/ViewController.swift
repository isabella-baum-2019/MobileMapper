//
//  ViewController.swift
//  MobileMapper
//
//  Created by Isabella Baum 2019 on 4/1/19.
//  Copyright © 2019 Isabella Baum 2019. All rights reserved.
//

import UIKit
import MapKit

class ViewController: UIViewController, CLLocationManagerDelegate {

    
    @IBOutlet weak var mapView: MKMapView!
    
    var parks: [MKMapItem] = []
    
    let locationManager = CLLocationManager()
    var currentLocation : CLLocation!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager.requestWhenInUseAuthorization()
        mapView.showsUserLocation = true
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.startUpdatingLocation()
    }
 
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        currentLocation = locations[0]
        print(currentLocation)
    }

    @IBAction func zoomButtonTapped(_ sender: UIBarButtonItem) {
        let coordinateSpan = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        let center = currentLocation.coordinate
        let region = MKCoordinateRegion(center: center, span: coordinateSpan)
        mapView.setRegion(region, animated: true)
    }
    
    @IBAction func searchButtonTapped(_ sender: UIBarButtonItem) {
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = "Parks"
        let span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        request.region = MKCoordinateRegion(center: currentLocation.coordinate, span: span)
        let search = MKLocalSearch(request: request)
        
        search.start { (response, error) in
            guard let response = response else { return }
            for mapItem in response.mapItems{
                self.parks.append(mapItem)
                let annotation = MKPointAnnotation()
                annotation.coordinate = mapItem.placemark.coordinate
                annotation.title = mapItem.name
                self.mapView.addAnnotation(annotation)
            }
        }
    }
}

