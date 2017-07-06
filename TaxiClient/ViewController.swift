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
    
    @IBOutlet weak var btnAddress: UIButton!
    @IBOutlet weak var lblAddress: UILabel!
    @IBOutlet weak var lblChangeAddress: UILabel!
    
    @IBOutlet weak var enterAddressView: UIView!
    @IBOutlet weak var txtEnterAddress: UITextField!
    @IBOutlet weak var btnClearAddress: UIButton!
    
    var enterAddresPanelIsShowing: Bool = false;
    
    var locationManager: CLLocationManager!
    let newPin = MKPointAnnotation()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        map.showsUserLocation = true
        map.delegate = self
        
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
        
    }
    
    func locationManager(_ locationManager: CLLocationManager, didUpdateLocations locations: [CLLocation])
    {
        let location = locations[0];
        
        let span:MKCoordinateSpan = MKCoordinateSpanMake(0.01, 0.01);
        let myLocation: CLLocationCoordinate2D = CLLocationCoordinate2DMake(location.coordinate.latitude, location.coordinate.longitude)
        
        let region:MKCoordinateRegion = MKCoordinateRegionMake(myLocation, span)
        map.setRegion(region, animated: true)
        
        print(location.altitude);
        
        self.map.showsUserLocation = true;
        
        if (locationManager.location != nil)
        {
            CLGeocoder().reverseGeocodeLocation(locationManager.location!, completionHandler: {(placemarks, error)->Void in
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
    }
    
    
    func displayLocationInfo(placemark: CLPlacemark?) {
        if placemark != nil {
            //stop updating location to save battery life
            locationManager.stopUpdatingLocation()
            lblAddress.text = ""
            lblAddress.text = "\(placemark!.locality!), \(placemark!.postalCode!), \(placemark!.administrativeArea!),  \(placemark!.country!)"
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Failed to find user's location: \(error.localizedDescription)")
    }
    
    //выездная панель
    
    @IBAction func btnNext_Clicked(_ sender: Any)  //появляется
    {
        
        if (!enterAddresPanelIsShowing)
        {
            UIView.animate(withDuration: 0.5, delay: 0.3, options: [], animations: {
            self.enterAddressView.frame.origin.y -= self.enterAddressView.frame.size.height
            }, completion: nil)
            enterAddresPanelIsShowing = true;
        }
    }
    
    @IBAction func btnAddress_Clicked(_ sender: Any)
    {
        
        if (!enterAddresPanelIsShowing)
        {
            UIView.animate(withDuration: 0.5, delay: 0.3, options: [], animations: {
                self.enterAddressView.frame.origin.y -= self.enterAddressView.frame.size.height
            }, completion: nil)
            enterAddresPanelIsShowing = true;
        }
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
    

    @IBAction func txtEnterAddress_EditingChanged(_ sender: Any)  //видимость кнопки "Х"
    {
        if (txtEnterAddress.text=="") { btnClearAddress.isHidden = true }
        else { btnClearAddress.isHidden = false }
    }

    @IBAction func btnClearAddress_Clicked(_ sender: Any)  //кнопка "Х"
    {
        txtEnterAddress.text=""
        btnClearAddress.isHidden = true
    }
    
    //центрирование
    
    @IBAction func btnCursor_Clicked(_ sender: Any)
    {
        locationManager.requestLocation()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

