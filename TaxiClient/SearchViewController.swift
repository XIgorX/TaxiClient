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
    
    let defaults = UserDefaults.standard
    
    @IBOutlet weak var btnCancel: UIButton!
    
    @IBOutlet weak var lblStatus: UILabel!

    @IBOutlet weak var map: MKMapView!
    var locationManager: CLLocationManager!
    let newPin = MKPointAnnotation()
    var pins = [MKPointAnnotation]()
    
    var spanX = 0.01;
    var spanY = 0.01;
    
    let kTaxiesCount = 4;
    let eps = 0.0001
    
    var choosedTaxiIndex = -1;
    var choosed = false;
    var stopped = false;
    
    var updateTimer: Timer? = nil;
    var chooseTimer: Timer? = nil;
    var goTimer: Timer? = nil;
    
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
        
        for i in 0...kTaxiesCount - 1
        {
            let randX = Double(Int(arc4random_uniform(UInt32(100))) + (-50)) * spanX * 0.01 * 1.5
            let randY = Double(Int(arc4random_uniform(UInt32(100))) + (-50)) * spanY * 0.01 * 1.5
        
            print(randX)
            print(randY)
        
            let pin = MKPointAnnotation()
            pin.coordinate = CLLocationCoordinate2D(latitude: (locationManager.location?.coordinate.latitude)! + randY, longitude: (locationManager.location?.coordinate.longitude)! + randX)
            pins.append(pin)
            
            map.addAnnotation(pins[i])
            
        }
        
        choosedTaxiIndex = Int(arc4random_uniform(UInt32(kTaxiesCount)))        
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard !(annotation is MKUserLocation) else {
            return nil
        }
        
        let annotationIdentifier = "Identifier"
        var annotationView: MKAnnotationView?
        if let dequeuedAnnotationView = mapView.dequeueReusableAnnotationView(withIdentifier: annotationIdentifier) {
            annotationView = dequeuedAnnotationView
            annotationView?.annotation = annotation
        }
        else {
            annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: annotationIdentifier)
            annotationView?.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        }
        
        if let annotationView = annotationView {
            
            annotationView.canShowCallout = true
            annotationView.image = UIImage(named: "pin.png")
            
        }
        
        return annotationView
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
        
        self.map.showsUserLocation = true;
        
        //newPin.coordinate = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        //map.addAnnotation(newPin)
        
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
        
        updateTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.update), userInfo: nil, repeats: true)
        
        chooseTimer = Timer.scheduledTimer(timeInterval: 20, target: self, selector: #selector(self.taxiChoosed), userInfo: nil, repeats: false)
        
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
                let _ = self.navigationController?.popViewController(animated: true);
                
            case .cancel:
                print("cancel")
                
            case .destructive:
                print("destructive")
            }
        }))
        alert.addAction(UIAlertAction(title: "Не отменять заказ", style: .cancel, handler: nil
            
        ))
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
        //отдаляем карту
        if (!stopped)
        {
        
        if (!choosed)
        {
            spanX = spanX * 1.01;
            spanY = spanY * 1.01;
        
            let span = MKCoordinateSpanMake(spanX, spanY);
            let region = MKCoordinateRegionMake(currentLocation, span)
        
            self.map.setRegion(region, animated: true)
        }
        else    //к нам едет машина
        {
            pins[choosedTaxiIndex].coordinate = CLLocationCoordinate2D(latitude: pins[choosedTaxiIndex].coordinate.latitude + ((locationManager.location?.coordinate.latitude)! - pins[choosedTaxiIndex].coordinate.latitude) / 10, longitude: pins[choosedTaxiIndex].coordinate.longitude + ((locationManager.location?.coordinate.longitude)! - pins[choosedTaxiIndex].coordinate.longitude) / 10);
            
            if  abs(pins[choosedTaxiIndex].coordinate.latitude - (locationManager.location?.coordinate)!.latitude) < eps
            {
                lblStatus.text = "Поездка"
                
                let alert = UIAlertController(title: "Такси прибыло!", message: "Вас ожидает автомобиль такой-то такой-то", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "Поехали!", style: .default, handler: nil))
                self.present(alert, animated: true, completion: nil)
                
                updateTimer?.invalidate()
                updateTimer = nil
                
                stopped = true;
                
                goTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.go), userInfo: nil, repeats: true)
            }
            
        }
        }
    }
    
    @objc func taxiChoosed()
    {
        for i in 0...kTaxiesCount - 1
        {
            if (i != choosedTaxiIndex)
            { map.removeAnnotation(pins[i]) }
        }
        
        choosed = true;
        
        lblStatus.text = "Ожидание такси"
        
        let alert = UIAlertController(title: "Вам назначено", message: "Вам назначен автомобиль такой-то такой-то", preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Отлично!", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
        
        chooseTimer?.invalidate()
        chooseTimer = nil
    }
    
    @objc func go()
    {
        let finishAddress: String? = defaults.string(forKey: "currentFinishAddress");
        let geoCoder = CLGeocoder()
        geoCoder.geocodeAddressString(finishAddress!) { (placemarks, error) in
            guard
                let placemarks = placemarks,
                let location = placemarks.first?.location
                else {
                    // handle no location found
                    return
                }
            
        let span:MKCoordinateSpan = MKCoordinateSpanMake(180 , 180);
        let myLocation: CLLocationCoordinate2D = CLLocationCoordinate2DMake(location.coordinate.latitude, location.coordinate.longitude)
            
        let region:MKCoordinateRegion = MKCoordinateRegionMake(myLocation, span)
        self.map.setRegion(region, animated: true)
            
        self.pins[self.choosedTaxiIndex].coordinate = CLLocationCoordinate2D(latitude: self.pins[self.choosedTaxiIndex].coordinate.latitude + ((location.coordinate.latitude) - self.pins[self.choosedTaxiIndex].coordinate.latitude) / 10, longitude: self.pins[self.choosedTaxiIndex].coordinate.longitude + ((location.coordinate.longitude) - self.pins[self.choosedTaxiIndex].coordinate.longitude) / 10);
            
            if  abs(self.pins[self.choosedTaxiIndex].coordinate.latitude - (location.coordinate).latitude) < 1
            {
                
                let alert = UIAlertController(title: "Приехали!", message: "Вы прибыли в место назначения", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "Наконец-то!", style: .default, handler: { action in
                    switch action.style{
                    case .default:
                        let _ = self.navigationController?.popViewController(animated: true)
                        
                    case .cancel:
                        print("cancel")
                        
                    case .destructive:
                        print("destructive")
                    }
                }))
                self.present(alert, animated: true, completion: nil)
                
                self.goTimer?.invalidate()
                self.goTimer = nil
                
                
                
            }
        }
    }
}
