import UIKit
import MapKit
import ISHPullUp
import CoreLocation
import Alamofire
import AlamofireImage
import SVProgressHUD

let time = TimeInterval(15)

class AngllifeViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, CLLocationManagerDelegate, MKMapViewDelegate {
    
    var locationManager:CLLocationManager!
    let defaults = UserDefaults.standard
    var hospitals: [Any] = []
    var hLink: String = ""
    var hName: String = ""
    var lat: Double = 0
    var long: Double = 0
    var isZoom: Bool = true
    
    var timer: Timer?
    
    var annotations: [MKAnnotation] = []
    
    @IBOutlet var map: MKMapView!
    @IBOutlet var bt_help: UIButton!
    @IBOutlet var tb_hospital: UITableView!
    @IBOutlet var v_list: UIView!
    @IBOutlet var v_list_height: NSLayoutConstraint!
    @IBOutlet var bt_current_location: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        bt_current_location.layer.cornerRadius = 0.5 * bt_current_location.bounds.size.width
        bt_current_location.layer.shadowOpacity = 0.7
        bt_current_location.layer.shadowOffset = CGSize(width: 1.0, height: 1.0)
        bt_current_location.layer.shadowColor = UIColor.lightGray.cgColor
        bt_current_location.layer.masksToBounds = false
        
        tb_hospital.isScrollEnabled = false
        
        let panGesture: UIPanGestureRecognizer = UIPanGestureRecognizer.init(target: self, action: #selector(handlePanGesture(gesture:)))
        v_list.addGestureRecognizer(panGesture)
        
        SVProgressHUD.show(withStatus: LOADING_TEXT)
        getCurrentLocation()
        getHospitals()
        getFriends()
        startTimer()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        stopTimer()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    //timer
    func startTimer() {
        defaults.set("Y", forKey: "timer")
        if timer == nil {
            timer = Timer.scheduledTimer(timeInterval: time, target: self, selector: #selector(getUpdate), userInfo: nil, repeats: true)
        }
    }
    
    func stopTimer() {
        if timer != nil {
            timer?.invalidate()
            timer = nil
        }
    }
    
    //get list
    @objc func getUpdate() {
        if let timer = defaults.string(forKey: "timer") {
            if timer == "Y" {
                getCurrentLocation()
                getFriends()
            } else {
                stopTimer()
            }
        }
    }
    
    //list hospital
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return hospitals.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let hCell: HospitalCell = tableView.dequeueReusableCell(withIdentifier: "HospitalCell") as! HospitalCell
        let hospital = hospitals[indexPath.row] as! [String: Any]
        let name: String = hospital["name"] as! String
        let distance: Double = hospital["distance"] as! Double
        let address: String = hospital["address"] as! String
        let img: String = hospital["image"] as! String
        
        hCell.name.text = name
        hCell.distance.text = "\(distance)" + " km"
        hCell.address.text = address
        
        let eImg: String! = img.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        if let url = URL(string: eImg){
            hCell.thumb.af_setImage(withURL: url)
        } else {
            hCell.thumb.image = UIImage(named: "emergency_img_defult")
        }
        
        return hCell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let hospital = hospitals[indexPath.row] as! [String: Any]
        
        if let name: String = hospital["name"] as? String {
            hName = name
        }
        
        if let link: String =  hospital["link"] as? String {
            if let eLink = link.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) {
                hLink = eLink
            }
        }
        
        self.performSegue(withIdentifier: "showWebView", sender: nil)
    }
    
    //location
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        locationManager.stopUpdatingLocation()
        
        let userLocation:CLLocation = locations[0] as CLLocation
        let latitude = userLocation.coordinate.latitude
        let longitude = userLocation.coordinate.longitude
        
        lat = latitude
        long = longitude
        
        if isZoom == true {
            isZoom = false
            showLocationWith(latitude: latitude, longitude: longitude)
        }
        
        sendLocation(latitude: latitude, longitude: longitude)
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Error \(error)")
    }
    
    //map
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let annotationView = AttractionAnnotationView(annotation: annotation, reuseIdentifier: "Attraction")
        annotationView.canShowCallout = true
        return annotationView
    }
    
    func getCurrentLocation() {
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.startUpdatingLocation()
        }
    }
    
    func sendLocation(latitude: CLLocationDegrees, longitude: CLLocationDegrees) {
        if let token = defaults.string(forKey: "token") {
            let userId: String! = defaults.string(forKey: "id")
            let parameters: Parameters = [
                "token": token,
                "userId": userId,
                "latitude": latitude,
                "longitude": longitude
            ]
            
            Alamofire.request(UPDATE_LOCATION_URL, method: .post, parameters: parameters, encoding: URLEncoding.default).responseJSON { response in
                if let json = response.result.value {
                    let result = json as! Dictionary<String, Any>
                    let code: String = result["code"] as! String
                    if code == "200" {
                        print("send location succes")
                    } else if code == "104" {
                        self.defaults.set("N", forKey: "login")
                        self.defaults.set("N", forKey: "timer")
                        let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
                        let loginViewController = storyboard.instantiateViewController(withIdentifier: "login")
                        UIApplication.shared.keyWindow?.rootViewController = loginViewController
                    }
                }
            }
        }
    }
    
    func getHospitals() {
        if let token = defaults.string(forKey: "token") {
            let parameters: Parameters = [
                "token": token,
                "lang": "EN"
            ]
            
            Alamofire.request(HOSPITAL_LIST_URL, method: .get, parameters: parameters, encoding: URLEncoding.default).responseJSON { response in
                SVProgressHUD.dismiss()
                if let json = response.result.value {
                    let result = json as! Dictionary<String, Any>
                    let code: String = result["code"] as! String
                    if code == "200" {
                        if let data: [String: Any] = result["data"] as? [String: Any] {
                            if let hospital: Array = data["hospital"] as? [Any] {
                                self.addAnnotations(items: hospital, type: .hospital)
                                self.hospitals = hospital
                                self.tb_hospital.reloadData()
                            }
                        }
                    } else if code == "104" {
                        self.defaults.set("N", forKey: "login")
                        self.defaults.set("N", forKey: "timer")
                        let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
                        let loginViewController = storyboard.instantiateViewController(withIdentifier: "login")
                        UIApplication.shared.keyWindow?.rootViewController = loginViewController
                    }
                }
            }
        }
    }
    
    func getFriends() {
        if let token = defaults.string(forKey: "token") {
            let parameters: Parameters = [
                "token": token
            ]
            
            Alamofire.request(FAMILY_LIST_URL, method: .get, parameters: parameters, encoding: URLEncoding.default).responseJSON { response in
                if let json = response.result.value {
                    let result = json as! Dictionary<String, Any>
                    let code: String = result["code"] as! String
                    if code == "200" {
                        if let data: [String: Any] = result["data"] as? [String: Any] {
                            let friends: Array = data["member"] as! [Any]
                            self.addFriendAnnotations(items: friends)
                            self.getAmbulances()
                        }
                    } else if code == "104" {
                        self.defaults.set("N", forKey: "login")
                        self.defaults.set("N", forKey: "timer")
                        let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
                        let loginViewController = storyboard.instantiateViewController(withIdentifier: "login")
                        UIApplication.shared.keyWindow?.rootViewController = loginViewController
                    }
                }
            }
        }
    }
    
    func getAmbulances() {
        let headers = [
            "Content-Type": "application/json",
            "secret_key": SECRET_KEY
        ]
        let url = TOURIST_EVENT_TRACKING.replacingOccurrences(of: "@", with: "201801150003")
        Alamofire.request(url, method: .get, parameters: nil, encoding: URLEncoding.default, headers: headers).responseJSON { response in
            if let json = response.result.value {
                let result = json as! Dictionary<String, Any>
                let code: String = result["status_code"] as! String
                if code == "200" {
                    
                } else if code == "104" {
                    self.defaults.set("N", forKey: "login")
                    self.defaults.set("N", forKey: "timer")
                    let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
                    let loginViewController = storyboard.instantiateViewController(withIdentifier: "login")
                    UIApplication.shared.keyWindow?.rootViewController = loginViewController
                }
            }
        }
    }
    
    func showLocationWith(latitude: CLLocationDegrees, longitude: CLLocationDegrees)  {
        let latDelta:CLLocationDegrees = 0.1
        let lonDelta:CLLocationDegrees = 0.1
        let span:MKCoordinateSpan = MKCoordinateSpanMake(latDelta, lonDelta)
        let location: CLLocationCoordinate2D = CLLocationCoordinate2DMake(latitude, longitude)
        let region:MKCoordinateRegion = MKCoordinateRegionMake(location, span)
        map.setRegion(region, animated: true)
    }
    
    func addAnnotations(items: [Any], type: AttractionType) {
        for item in items {
            let pin =  item as! [String: Any]
            let latitude: Double = pin["latitude"] as! Double
            let longitude: Double = pin["longitude"] as! Double
            let title: String = pin["name"] as! String
            let annotation = AttractionAnnotation(latitude: latitude, longitude: longitude, title: title, type: type, icon: "", status: "")
            map.addAnnotation(annotation)
        }
    }
    
    func addFriendAnnotations(items: [Any]) {
        for annotation in map.annotations {
            for friendAnn in annotations {
                if annotation === friendAnn {
                    map.removeAnnotation(annotation)
                }
            }
        }
        
        annotations.removeAll()
        
        for item in items {
            let pin =  item as! [String: Any]
            let latitude: String = pin["latitude"] as! String
            let longitude: String = pin["longitude"] as! String
            let lat: Double = latitude.toDouble()!
            let long: Double = longitude.toDouble()!
            let firstname: String = pin["firstname"] as! String
            let lastname: String = pin["lastname"] as! String
            let title: String = firstname + " " + lastname
            let icon: String = pin["personal_image_path"] as! String
            let status: String = pin["status"] as! String
            let annotation = AttractionAnnotation(latitude: lat, longitude: long, title: title, type: .current, icon: icon, status: status)
            map.addAnnotation(annotation)
            annotations.append(annotation)
        }
    }
    
    @objc func handlePanGesture(gesture: UIPanGestureRecognizer) {
        if gesture.state == .ended {
            if case .Down = gesture.verticalDirection(target: self.view) {
                v_list_height.constant = 150
                UIView.animate(withDuration: 0.3, animations: {
                    self.view.layoutIfNeeded()
                }, completion: { (animate) in
                    self.bt_help.isHidden = false
                    self.bt_current_location.isHidden = false
                    self.tb_hospital.isScrollEnabled = false
                })
            } else {
                v_list_height.constant = self.view.bounds.size.height - (self.navigationController?.navigationBar.bounds.size.height)! - 20
                bt_help.isHidden = true
                bt_current_location.isHidden = true
                tb_hospital.isScrollEnabled = true
                UIView.animate(withDuration: 0.3, animations: {
                    self.view.layoutIfNeeded()
                }, completion: nil)
            }
        }
    }
    
    @IBAction func showMenu(_ sender: Any) {
        if let container = self.so_containerViewController {
            container.isSideViewControllerPresented = true
        }
    }

    @IBAction func showCurrentLocation(_ sender: Any) {
        isZoom = true
        getCurrentLocation()
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showWebView" {
            let hospitalDetail: WebViewController = segue.destination as! WebViewController
            hospitalDetail.link = hLink
            hospitalDetail.navigationItem.title = hName
        }
        
        if segue.identifier == "showHelp" {
            let help: HelpViewController = segue.destination as! HelpViewController
            help.lat = lat
            help.long = long
        }
    }

}

extension UIPanGestureRecognizer {
    
    enum GestureDirection {
        case Up
        case Down
        case Left
        case Right
    }
    
    /// Get current vertical direction
    ///
    /// - Parameter target: view target
    /// - Returns: current direction
    func verticalDirection(target: UIView) -> GestureDirection {
        return self.velocity(in: target).y > 0 ? .Down : .Up
    }
    
    /// Get current horizontal direction
    ///
    /// - Parameter target: view target
    /// - Returns: current direction
    func horizontalDirection(target: UIView) -> GestureDirection {
        return self.velocity(in: target).x > 0 ? .Right : .Left
    }
    
    /// Get a tuple for current horizontal/vertical direction
    ///
    /// - Parameter target: view target
    /// - Returns: current direction
    func versus(target: UIView) -> (horizontal: GestureDirection, vertical: GestureDirection) {
        return (self.horizontalDirection(target: target), self.verticalDirection(target: target))
    }
    
}

extension String {
    func toDouble() -> Double? {
        if self.isEmpty {
            return 0
        }
        return NumberFormatter().number(from: self)?.doubleValue
    }
}
