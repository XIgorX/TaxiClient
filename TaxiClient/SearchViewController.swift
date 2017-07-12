//
//  SearchViewController.swift
//  TaxiClient
//
//  Created by Igor on 07.07.17.
//  Copyright © 2017 Igor. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class SearchViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {
    
    
  @IBOutlet weak var btnCancel: UIButton!

    @IBOutlet weak var map: MKMapView!
    var locationManager: CLLocationManager!
    let newPin = MKPointAnnotation()
    
    var spanX = 0.01;
    var spanY = 0.01;
    
    var currentLocation: CLLocationCoordinate2D = CLLocationCoordinate2DMake(0, 0)
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
        
        let span:MKCoordinateSpan = MKCoordinateSpanMake(spanX, spanY);
        let myLocation: CLLocationCoordinate2D = CLLocationCoordinate2DMake(location.coordinate.latitude, location.coordinate.longitude)
        
        currentLocation = myLocation;
        
        let region:MKCoordinateRegion = MKCoordinateRegionMake(myLocation, span)
        map.setRegion(region, animated: true)
        
        print(location.altitude);
        
        self.map.showsUserLocation = false;
        
        newPin.coordinate = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        map.addAnnotation(newPin)
        
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
        
        //zooming out
        
        let _ = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.update), userInfo: nil, repeats: true)
        
        
        
        //UIView.animate(withDuration: 10, delay: 0.3, options: [], animations: {
        //    self.map.setRegion(region, animated: true)
        //}, completion: nil)
    }
    
    func displayLocationInfo(placemark: CLPlacemark?) {
        if placemark != nil {
            //stop updating location to save battery life
            locationManager.stopUpdatingLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Failed to find user's location: \(error.localizedDescription)")
    }
    
    @IBAction func btnCancel_Clicked(_ sender: Any)
    {
        let alert = UIAlertController(title: "Отмена заказа", message: "Вы действительно хотите отменить заказ?", preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Отменить заказ", style: .default, handler: { action in
            switch action.style{
            case .default:
                //посылаем запрос на отмену
                //возвращаемся к предыдущему экрану
                let _ = self.navigationController?.popViewController(animated: false);
                
            case .cancel:
                print("cancel")
                
            case .destructive:
                print("destructive")
            }
        }))
        alert.addAction(UIAlertAction(title: "Не отменять заказ", style: .cancel, handler: { action in
            switch action.style{
            case .default:
                print("default")
                
            case .cancel:
                print("cancel")
                
            case .destructive:
                print("destructive")
            }
            
        }))
        self.present(alert, animated: true, completion: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    @objc func update()
    {
        spanX = spanX * 1.01;
        spanY = spanY * 1.01;
        
        let span = MKCoordinateSpanMake(spanX, spanY);
        let region = MKCoordinateRegionMake(currentLocation, span)
        
        self.map.setRegion(region, animated: true)
    }
}
