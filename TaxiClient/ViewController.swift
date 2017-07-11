//
//  ViewController.swift
//  TaxiClient
//
//  Created by Igor on 17.06.17.
//  Copyright © 2017 Igor. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class ViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate{
    
    @IBOutlet weak var map: MKMapView!
    var locationManager: CLLocationManager!
    let newPin = MKPointAnnotation()
    
    var currentPlacemark: CLPlacemark? = nil
    
    @IBOutlet weak var btnAddress: UIButton!
    @IBOutlet weak var lblAddress: UILabel!
    @IBOutlet weak var lblChangeAddress: UILabel!
    
    //выезжающие вью
    
    @IBOutlet weak var enterAddressView: UIView!
    @IBOutlet weak var addressSearchBar: UISearchBar!
    //@IBOutlet weak var txtEnterAddress: UITextField!
    //@IBOutlet weak var btnClearAddress: UIButton!
    @IBOutlet weak var searchResultsTableView: UITableView!
    
    @IBOutlet var setRouteView: UIView!
    @IBOutlet weak var lblStartAddress: UILabel!
    
    var enterAddresPanelIsShowing: Bool = false;
    
    //поиск адреса
    var searchCompleter = MKLocalSearchCompleter()
    var searchResults = [MKLocalSearchCompletion]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        map.showsUserLocation = true
        map.delegate = self
        
        searchCompleter.delegate = self
        
        if (CLLocationManager.locationServicesEnabled())
        {
            locationManager = CLLocationManager()
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            //locationManager.requestAlwaysAuthorization()
            locationManager.requestWhenInUseAuthorization()
            locationManager.startMonitoringSignificantLocationChanges()
            
            if (CLLocationManager.locationServicesEnabled()) {
                locationManager.requestLocation()
            }
            
        }
        
        self.setRouteView.frame.size.height = self.view.frame.size.height;
        self.setRouteView.frame.size.width = self.view.frame.size.width;
        self.view.addSubview(setRouteView);
        self.setRouteView.frame.origin.y = self.view.frame.height;
        self.setRouteView.frame.origin.x = 0;
    }
    
    func locationManager(_ locationManager: CLLocationManager, didUpdateLocations locations: [CLLocation])
    {
        let location = locations[0];
        
        let span:MKCoordinateSpan = MKCoordinateSpanMake(0.01, 0.01);
        let myLocation: CLLocationCoordinate2D = CLLocationCoordinate2DMake(location.coordinate.latitude, location.coordinate.longitude)
        
        let region:MKCoordinateRegion = MKCoordinateRegionMake(myLocation, span)
        map.setRegion(region, animated: true)
        
        self.map.showsUserLocation = false;
        //self.map.tintColor = UIColor.green
        //self.map .setUserTrackingMode(.follow, animated: true)
        
        newPin.coordinate = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        map.addAnnotation(newPin)
        
        //if (location != nil)
        //{
            CLGeocoder().reverseGeocodeLocation(location, completionHandler: {(placemarks, error)->Void in
            if (error != nil) {
                print("Reverse geocoder failed with error" + (error?.localizedDescription)!)
                return
            }
                
            if (placemarks?.count)! > 0 {
                let pm = (placemarks?[0])! as CLPlacemark
                self.displayLocationInfo(placemark: pm)
            } else {
                print("Problem with the data received from geocoder")
            }
        })
        //}
    }
    
    
    func displayLocationInfo(placemark: CLPlacemark?) {
        if placemark != nil {
            //stop updating location to save battery life
            locationManager.stopUpdatingLocation()
            lblAddress.text = ""
            var street = "";
            if (placemark!.addressDictionary!["Street"] != nil) { street = placemark!.addressDictionary!["Street"] as! String}
            var locality = ""
            if (placemark!.locality != nil) { locality = placemark!.locality!}
            var country = ""
            if (placemark!.country != nil) { country = placemark!.country!}
            
            lblAddress.text = "\(street) , \(locality), \(country)"
            currentPlacemark = placemark;
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Failed to find user's location: \(error.localizedDescription)")
    }
    
    internal func mapView(_ map: MKMapView, regionDidChangeAnimated animated: Bool)
    {
        let location: CLLocation = CLLocation(latitude: (map.centerCoordinate.latitude), longitude: (map.centerCoordinate.longitude))

        newPin.coordinate = location.coordinate
        map.addAnnotation(newPin)
        
        CLGeocoder().reverseGeocodeLocation(location, completionHandler: {(placemarks, error)->Void in
            if (error != nil) {
                print("Reverse geocoder failed with error" + (error?.localizedDescription)!)
                return
            }
            
            if (placemarks?.count)! > 0 {
                let pm = (placemarks?[0])! as CLPlacemark
                self.displayLocationInfo(placemark: pm)
            } else {
                print("Problem with the data received from geocoder")
            }
        })
    }
    
    //выезжающие панели
    
    //панель заказа
    
    @IBAction func btnNext_Clicked(_ sender: Any)   //показывается
    {
        UIView.animate(withDuration: 0.5, delay: 0.3, options: [], animations: {
            self.setRouteView.frame.origin.y -= self.setRouteView.frame.size.height
        }, completion: nil)
        lblStartAddress.text = currentPlacemark?.addressDictionary!["Street"]! as! String?;
    }
    
    @IBAction func btnCloseSetRouteView_Clicked(_ sender: Any)  //скрывается
    {
        UIView.animate(withDuration: 0.5, delay: 0.3, options: [], animations: {
            self.setRouteView.frame.origin.y += self.setRouteView.frame.size.height
        }, completion: nil)    }
    
    //обработчики кнопок
    @IBAction func btnPorch_Clicked(_ sender: Any)
    {
        
    }
    
    //панель уточнения адреса
    
    @IBAction func btnAddress_Clicked(_ sender: Any)  //показывается
    {
        
        if (!enterAddresPanelIsShowing)
        {
            UIView.animate(withDuration: 0.5, delay: 0.3, options: [], animations: {
                self.enterAddressView.frame.origin.y -= self.enterAddressView.frame.size.height
            }, completion: nil)
            enterAddresPanelIsShowing = true
        }
        
        addressSearchBar.text = currentPlacemark?.addressDictionary!["Street"]! as! String?
    }
    
    @IBAction func btnCloseEnterAddressView_Clicked(_ sender: Any)  //скрывается
    {
        if (enterAddresPanelIsShowing)
        {
        UIView.animate(withDuration: 0.5, delay: 0.3, options: [], animations: {
            self.enterAddressView.frame.origin.y += self.enterAddressView.frame.size.height
        }, completion: nil)
        enterAddresPanelIsShowing = false;
        }
    }
    
    
    /*
    @IBAction func txtEnterAddress_EditingChanged(_ sender: Any)  //видимость кнопки "Х"
    {
        if (addressSearchBar.text=="") { btnClearAddress.isHidden = true }
        else { btnClearAddress.isHidden = false }
        
        //addressSearchBar.queryFragment = addressSearchBar.text!
    }

    @IBAction func btnClearAddress_Clicked(_ sender: Any)  //кнопка "Х"
    {
        addressSearchBar.text=""
        btnClearAddress.isHidden = true
    }*/
    
    //центрирование
    
    @IBAction func btnCursor_Clicked(_ sender: Any)
    {
        locationManager.requestLocation()
    }
    
    //методы делегата SearchCompleter
    
   // func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
    //    searchResults = completer.results
        //searchResultsTableView.reloadData()
    //}
    
    //func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: Error) {
        // handle error
    //}
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension ViewController: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        searchCompleter.queryFragment = searchText
    }
}

extension ViewController: MKLocalSearchCompleterDelegate {
    
    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        searchResults = completer.results
        searchResultsTableView.reloadData()
    }
    
    func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: Error) {
        // handle error
    }
}

extension ViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchResults.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let searchResult = searchResults[indexPath.row]
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: nil)
        cell.textLabel?.text = searchResult.title
        cell.detailTextLabel?.text = searchResult.subtitle
        return cell
    }
}

extension ViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let completion = searchResults[indexPath.row]
        
        let searchRequest = MKLocalSearchRequest(completion: completion)
        let search = MKLocalSearch(request: searchRequest)
        search.start { (response, error) in
            let coordinate = response?.mapItems[0].placemark.coordinate
            
            print(String(describing: coordinate))
            
            let searchResult = self.searchResults[indexPath.row]
            self.addressSearchBar.text = searchResult.title
            
            self.map.setCenter(coordinate!, animated: false)
            
            //self.newPin.coordinate = CLLocationCoordinate2D(latitude: (coordinate?.latitude)!, longitude: (coordinate?.longitude)!)
            //self.map.addAnnotation(self.newPin)
            
        }
    }
}



