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

class MainViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate{
    
    @IBOutlet weak var map: MKMapView!
    var locationManager: CLLocationManager!
    let newPin = MKPointAnnotation()
    
    var currentPlacemark: CLPlacemark? = nil
    
    @IBOutlet weak var btnAddress: UIButton!
    @IBOutlet weak var lblAddress: UILabel!
    @IBOutlet weak var lblChangeAddress: UILabel!
    
    //выезжающие вью
    
    //уточнение адреса
    
    @IBOutlet weak var enterAddressView: UIView!
    @IBOutlet weak var addressSearchBar: UISearchBar!
    @IBOutlet weak var addressSearchBar2: UISearchBar!
    

    //@IBOutlet weak var txtEnterAddress: UITextField!
    //@IBOutlet weak var btnClearAddress: UIButton!
    @IBOutlet weak var searchResultsTableView: UITableView!
    @IBOutlet weak var searchResultsTableView2: UITableView!
    
    var startAddress = "";
    //пункт назначения
    
    @IBOutlet weak var finishAddressView: UIView!
    
    
    //маршрут заказа
    
    @IBOutlet weak var setRouteView: UIView!
    @IBOutlet weak var lblStartAddress: UILabel!
    @IBOutlet weak var lblFinishAddress: UILabel!
    
    var enterAddressPanelIsShowing: Bool = false;
    
    //подчиненные вью
    
    @IBOutlet var porchView: UIView! //уточнение подьезда
    @IBOutlet weak var txtPorchNumber: UITextField!
    
    var additionalPanelIsShowing: Bool = false;
    var keyboardHeight = 0;
    
    //остальные панели
    
    @IBOutlet var timeView: UIView!
    @IBOutlet weak var lblTime: UILabel!
    
    @IBOutlet var payView: UIView!
    @IBOutlet weak var lblPay: UILabel!
    
    @IBOutlet var commentView: UIView!
    @IBOutlet weak var lblComment: UILabel!
    @IBOutlet weak var txtView: UITextView!
    
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
        
        //создаем панель заказа за пределами экрана снизу
        
        self.setRouteView.frame.size.height = self.view.frame.size.height;
        self.setRouteView.frame.size.width = self.view.frame.size.width;
        self.view.addSubview(setRouteView);
        self.setRouteView.frame.origin.y = self.view.frame.height;
        self.setRouteView.frame.origin.x = 0;
        
        //панель уточнения адреса
        
        self.enterAddressView.frame.size.width = self.view.frame.size.width;
        self.view.addSubview(enterAddressView);
        self.enterAddressView.frame.origin.y = self.view.frame.height;
        self.enterAddressView.frame.origin.x = 0;
        
        //панель адреса назначения
        
        self.finishAddressView.frame.size.width = self.view.frame.size.width;
        self.view.addSubview(finishAddressView);
        self.finishAddressView.frame.origin.y = self.view.frame.height;
        self.finishAddressView.frame.origin.x = 0;
        
        //панель уточнения подъезда
        
        self.porchView.frame.size.width = self.view.frame.size.width;
        self.setRouteView.addSubview(porchView);
        self.porchView.frame.origin.y = self.setRouteView.frame.height;
        self.porchView.frame.origin.x = 0;
        
        //панель времени подачи
        
        self.timeView.frame.size.width = self.view.frame.size.width;
        self.setRouteView.addSubview(timeView);
        self.timeView.frame.origin.y = self.setRouteView.frame.height;
        self.timeView.frame.origin.x = 0;
        
        //панель способа оплаты
        
        self.payView.frame.size.width = self.view.frame.size.width;
        self.setRouteView.addSubview(payView);
        self.payView.frame.origin.y = self.setRouteView.frame.height;
        self.payView.frame.origin.x = 0;
        
        //панель комментария
        
        self.commentView.frame.size.height = self.view.frame.size.height;
        self.commentView.frame.size.width = self.view.frame.size.width;
        self.setRouteView.addSubview(commentView);
        self.commentView.frame.origin.y = self.setRouteView.frame.height;
        self.commentView.frame.origin.x = 0;
        
        setUpObserver();
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
            self.lblStartAddress.text = self.lblAddress.text
            currentPlacemark = placemark
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
        var street = "";
        if (currentPlacemark?.addressDictionary!["Street"] != nil) { street = currentPlacemark!.addressDictionary!["Street"] as! String}
        startAddress = "\(street)";
        lblStartAddress.text = startAddress;
    }
    
    @IBAction func btnCloseSetRouteView_Clicked(_ sender: Any)  //скрывается
    {
        UIView.animate(withDuration: 0.5, delay: 0.3, options: [], animations: {
            self.setRouteView.frame.origin.y += self.setRouteView.frame.size.height
        }, completion: nil)
    }
    
    //обработчики кнопок панели заказа
    
    //уточнение подъезда
    
    @IBAction func btnPorch_Clicked(_ sender: Any)      //показывается
    {
        if (!additionalPanelIsShowing)
        {
            txtPorchNumber.becomeFirstResponder()
            UIView.animate(withDuration: 0.5, delay: 0.3, options: [], animations: {
                self.porchView.frame.origin.y -= self.porchView.frame.size.height + CGFloat(self.keyboardHeight)
            }, completion: nil)
            additionalPanelIsShowing = true;
        }
    }
    
    @IBAction func btnPorchClosed_Clicked(_ sender: Any)  //скрывается
    {
        if (txtPorchNumber.text != "")
        {
            lblStartAddress.text = startAddress + ", п" + txtPorchNumber.text!
        }
        else { lblStartAddress.text = startAddress }
        
        txtPorchNumber.resignFirstResponder()
        
        UIView.animate(withDuration: 0.5, delay: 0.3, options: [], animations: {
            self.porchView.frame.origin.y += self.porchView.frame.size.height + CGFloat(self.keyboardHeight)
        }, completion: nil)
        
        additionalPanelIsShowing = false;
    }
    
    //время подачи
    
 
    @IBAction func btnTime_Clicked(_ sender: Any)
    {
        if (!additionalPanelIsShowing)
        {
            UIView.animate(withDuration: 0.5, delay: 0.3, options: [], animations: {
                self.timeView.frame.origin.y -= self.timeView.frame.size.height
            }, completion: nil)
            additionalPanelIsShowing = true;
        }
    }
    
    @IBAction func btnTimeClose_Clicked(_ sender: Any)
    {
            UIView.animate(withDuration: 0.5, delay: 0.3, options: [], animations: {
                self.timeView.frame.origin.y += self.timeView.frame.size.height
            }, completion: nil)
            additionalPanelIsShowing = false;

    }
    

    @IBAction func btnTimeChoose_Clicked(_ sender: UIButton)
    {
        lblTime.text = sender.title(for: UIControlState.normal)!
    }
    
    //способ оплаты
    
    @IBAction func btnPay_Clicked(_ sender: Any)
    {
        if (!additionalPanelIsShowing)
        {
            UIView.animate(withDuration: 0.5, delay: 0.3, options: [], animations: {
                self.payView.frame.origin.y -= self.payView.frame.size.height
            }, completion: nil)
            additionalPanelIsShowing = true;
        }
    }
    
    @IBAction func btnPayClose_Clicked(_ sender: Any)
    {
        UIView.animate(withDuration: 0.5, delay: 0.3, options: [], animations: {
            self.payView.frame.origin.y += self.payView.frame.size.height
        }, completion: nil)
        additionalPanelIsShowing = false;
    }
    
    @IBAction func btnPayChoose_Clicked(_ sender: UIButton)
    {
        lblPay.text = sender.title(for: UIControlState.normal)!
    }
    
    //комментарий
    
    @IBAction func btnComment_Clicked(_ sender: Any)
    {
        UIView.animate(withDuration: 0.5, delay: 0.3, options: [], animations: {
            self.commentView.frame.origin.y -= self.commentView.frame.size.height
        }, completion: nil)
    }
    
    @IBAction func btnCommentClose_Clicked(_ sender: Any)
    {
        txtView.resignFirstResponder()
        
        UIView.animate(withDuration: 0.5, delay: 0.3, options: [], animations: {
            self.commentView.frame.origin.y += self.commentView.frame.size.height
        }, completion: nil)
        
        lblComment.text = txtView.text;
        
    }
    
    //вызов панели уточнения адреса со стартовой точки марщрута
    
    @IBAction func btnStartAddress_Clicked(_ sender: Any)
    {
        UIView.animate(withDuration: 0.5, delay: 0.3, options: [], animations: {
            self.enterAddressView.frame.origin.y -= self.enterAddressView.frame.size.height
        }, completion: nil)
        
        addressSearchBar.text = currentPlacemark?.addressDictionary!["Street"] as! String?
    }
    
    //панель уточнения адреса
    
    @IBAction func btnAddress_Clicked(_ sender: Any)  //показывается
    {
        
        if (!enterAddressPanelIsShowing)
        {
            UIView.animate(withDuration: 0.5, delay: 0.3, options: [], animations: {
                self.enterAddressView.frame.origin.y -= self.enterAddressView.frame.size.height
            }, completion: nil)
            enterAddressPanelIsShowing = true
        }
        
        addressSearchBar.text = currentPlacemark!.addressDictionary!["Street"] as! String?
    }
    
    @IBAction func btnCloseEnterAddressView_Clicked(_ sender: Any)  //скрывается
    {
        //if (enterAddresPanelIsShowing)
        //{
        UIView.animate(withDuration: 0.5, delay: 0.3, options: [], animations: {
            self.enterAddressView.frame.origin.y += self.enterAddressView.frame.size.height
        }, completion: nil)
        enterAddressPanelIsShowing = false;
        //}
        addressSearchBar.resignFirstResponder()
    }
    
    //панель адреса назначения
    
    @IBAction func btnFinishAddress_Clicked(_ sender: Any)
    {
        UIView.animate(withDuration: 0.5, delay: 0.3, options: [], animations: {
            self.finishAddressView.frame.origin.y -= self.finishAddressView.frame.size.height
        }, completion: nil)
        
        //addressSearchBar2.text = currentPlacemark?.addressDictionary!["Street"] as! String?
    }
    
    @IBAction func btnCloseFinishAddress_Clicked(_ sender: Any)
    {
        UIView.animate(withDuration: 0.5, delay: 0.3, options: [], animations: {
            self.finishAddressView.frame.origin.y += self.enterAddressView.frame.size.height
        }, completion: nil)
        
        lblFinishAddress.text = addressSearchBar2.text
        addressSearchBar2.resignFirstResponder()
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
    
    //обсервер для доступа к высоте клавиатуры
    
    private func setUpObserver() {
        NotificationCenter.default.addObserver(self, selector: .keyboardWillShow, name: .UIKeyboardWillShow, object: nil)
    }
    
    @objc fileprivate func keyboardWillShow(notification:NSNotification) {
        if let keyboardRectValue = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            keyboardHeight = Int(keyboardRectValue.height)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

private extension Selector {
    static let keyboardWillShow = #selector(MainViewController.keyboardWillShow(notification:))
}

extension MainViewController: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        searchCompleter.queryFragment = searchText
    }
}

extension MainViewController: MKLocalSearchCompleterDelegate {
    
    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        searchResults = completer.results
        searchResultsTableView.reloadData()
        searchResultsTableView2.reloadData()    }
    
    func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: Error) {
        // handle error
    }
}

extension MainViewController: UITableViewDataSource {
    
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

extension MainViewController: UITableViewDelegate {
    
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
            self.addressSearchBar2.text = searchResult.title
            
            self.map.setCenter(coordinate!, animated: false)
            
            //self.newPin.coordinate = CLLocationCoordinate2D(latitude: (coordinate?.latitude)!, longitude: (coordinate?.longitude)!)
            //self.map.addAnnotation(self.newPin)
            
        }
    }
}



