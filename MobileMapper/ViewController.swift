//
//  ViewController.swift
//  MobileMapper
//
//  Created by Isabella Baum 2019 on 4/1/19.
//  Copyright © 2019 Isabella Baum 2019. All rights reserved.
//

import UIKit
import MapKit

class ViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {

    
    @IBOutlet weak var mapView: MKMapView!
    
    var parks: [MKMapItem] = []
    
    let locationManager = CLLocationManager()
    var currentLocation : CLLocation!
    
    var initialRegion: MKCoordinateRegion!
    var isInitialMapLoad: Bool = true
    
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
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation.isEqual(mapView.userLocation){
            return nil
        }
        
        var pin = MKAnnotationView(annotation: annotation, reuseIdentifier: nil)
        if let title = annotation.title, let actualTitle = title{
            if actualTitle == "Franco Park"{
               pin.image = UIImage(named: "MobileMakerIconPinImage")
            } else{
                pin = MKAnnotationView(annotation: annotation, reuseIdentifier: nil)
            }
        }
        
        pin.canShowCallout = true
        let button = UIButton(type: .detailDisclosure)
        pin.rightCalloutAccessoryView = button
        let zoomButton = UIButton(type: .contactAdd)
        pin.leftCalloutAccessoryView = zoomButton
        return pin
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        let buttonPressed = control as! UIButton
        if buttonPressed.buttonType == .contactAdd{
            mapView.setRegion(initialRegion, animated: true)
            return
        }
        
        var currentMapItem = MKMapItem()
        if let title = view.annotation?.title, let parkNmae = title{
            for mapItem in parks{
                if mapItem.name == parkNmae{
                    currentMapItem = mapItem
                }
            }
        }
        let placemark = currentMapItem.placemark
        print(placemark)
        if let parkName = placemark.name, let address = placemark.addressDictionary, let Street = address["Street"] as? String{
            let alert = UIAlertController(title: parkName, message: Street, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
            present(alert, animated: true, completion: nil)
        }
    }
    func mapViewDidFinishLoadingMap(_ mapView: MKMapView) {
        if isInitialMapLoad{
            initialRegion = MKCoordinateRegion(center: mapView.centerCoordinate, span: mapView.region.span)
            isInitialMapLoad = false
        }
    }
    
    
}

