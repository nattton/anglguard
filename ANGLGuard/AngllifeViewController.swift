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
    
    var friendsAnn: [MKAnnotation] = []
    var ambulanceAnn: MKAnnotation?
    
    var list_height: CGFloat = 0
    var isMaxiMize: Bool = false
    
    @IBOutlet var map: MKMapView!
    @IBOutlet var tf_can_i_help_you: UIButton!
    @IBOutlet var bt_help: UIButton!
    @IBOutlet var tb_hospital: UITableView!
    @IBOutlet var v_list: UIView!
    @IBOutlet var v_list_height: NSLayoutConstraint!
    @IBOutlet var bt_current_location: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setText()
        
        list_height = self.view.bounds.size.height - (self.navigationController?.navigationBar.bounds.size.height)! - 20
        
        bt_current_location.layer.cornerRadius = 0.5 * bt_current_location.bounds.size.width
        bt_current_location.layer.shadowOpacity = 0.7
        bt_current_location.layer.shadowOffset = CGSize(width: 1.0, height: 1.0)
        bt_current_location.layer.shadowColor = UIColor.lightGray.cgColor
        bt_current_location.layer.masksToBounds = false
        
        v_list.frame = tb_hospital.frame
        
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
    
    func setText() {
        tf_can_i_help_you.setTitle("can_i_help".localized(), for: .normal)
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
                        let appDelegate = UIApplication.shared.delegate as! AppDelegate
                        appDelegate.clearProfile()
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
                "lang": Language.getCurrentLanguage().language()
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
                        let appDelegate = UIApplication.shared.delegate as! AppDelegate
                        appDelegate.clearProfile()
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
                            NSLog("data = \(data)")
                            let friends: Array = data["member"] as! [Any]
                            self.addFriendAnnotations(items: friends)
                            if let job_id: String = data["job_id"] as? String, !(job_id.isEmpty) {
                                self.getAmbulances(id: job_id)
                            }
                        }
                    } else if code == "104" {
                        self.defaults.set("N", forKey: "login")
                        self.defaults.set("N", forKey: "timer")
                        let appDelegate = UIApplication.shared.delegate as! AppDelegate
                        appDelegate.clearProfile()
                        let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
                        let loginViewController = storyboard.instantiateViewController(withIdentifier: "login")
                        UIApplication.shared.keyWindow?.rootViewController = loginViewController
                    }
                }
            }
        }
    }
    
    func getAmbulances(id: String) {
        let headers = [
            "Content-Type": "application/json",
            "secret_key": SECRET_KEY
        ]
        let url = TOURIST_EVENT_TRACKING.replacingOccurrences(of: "@", with: id)
        Alamofire.request(url, method: .get, parameters: nil, encoding: URLEncoding.default, headers: headers).responseJSON { response in
            if let json = response.result.value {
                let result = json as! Dictionary<String, Any>
                let code: String = result["status_code"] as! String
                if code == "200" {
                    if let data: [String: Any] = result["result"] as? [String: Any] {
                        if let job_process: String = data["job_process"] as? String, job_process != "CLOSED" {
                            if let ambulance: [String: Any] = data["ambulance"] as? [String: Any] {
                                NSLog("ambulance = \(ambulance)")
                                let title: String! = ambulance["ambulance_name"] as? String
                                if let location: [String: Any] = ambulance["current_location"] as? [String: Any] {
                                    if let lat: Double = location["latitude"] as? Double, let long: Double = location["longitude"] as? Double {
                                        self.addAmbulanceAnnotation(latitude: lat, longitude: long, title: title)
                                    }
                                }
                            }
                        }
                    }
                } else if code == "104" {
                    self.defaults.set("N", forKey: "login")
                    self.defaults.set("N", forKey: "timer")
                    let appDelegate = UIApplication.shared.delegate as! AppDelegate
                    appDelegate.clearProfile()
                    let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
                    let loginViewController = storyboard.instantiateViewController(withIdentifier: "login")
                    UIApplication.shared.keyWindow?.rootViewController = loginViewController
                }
            }
        }
    }
    
    func addAmbulanceAnnotation(latitude: Double, longitude: Double, title: String) {
        for annotation in map.annotations {
            if annotation === ambulanceAnn {
                map.removeAnnotation(annotation)
            }
        }
        let annotation = AttractionAnnotation(latitude: latitude, longitude: longitude, title: title, type: .ambulance, icon: "", status: "")
        map.addAnnotation(annotation)
        ambulanceAnn = annotation
    }
    
    func showLocationWith(latitude: CLLocationDegrees, longitude: CLLocationDegrees)  {
        let latDelta: CLLocationDegrees = 0.005
        let lonDelta: CLLocationDegrees = 0.005
        let span: MKCoordinateSpan = MKCoordinateSpanMake(latDelta, lonDelta)
        let location: CLLocationCoordinate2D = CLLocationCoordinate2DMake(latitude, longitude)
        let region: MKCoordinateRegion = MKCoordinateRegionMake(location, span)
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
            for friendAnn in friendsAnn {
                if annotation === friendAnn {
                    map.removeAnnotation(annotation)
                }
            }
        }
        
        friendsAnn.removeAll()
        
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
            var status: String = pin["status"] as! String
            let pid = pin["id"] as! String
            let mid = defaults.string(forKey: "id")
            if pid == mid {
                status = "A"
            }
            let annotation = AttractionAnnotation(latitude: lat, longitude: long, title: title, type: .current, icon: icon, status: status)
            map.addAnnotation(annotation)
            friendsAnn.append(annotation)
        }
    }
    
    func maximizeHospitalList() {
        v_list_height.constant = list_height
        bt_help.isHidden = true
        bt_current_location.isHidden = true
        UIView.animate(withDuration: 0.3, animations: {
            self.view.layoutIfNeeded()
        }, completion: { (animate) in
            self.v_list.frame = self.tb_hospital.frame
            self.v_list.frame.size.height = 30
        })
        
        isMaxiMize = true
    }
    
    func minimizeHospitalList() {
        v_list_height.constant = 150
        UIView.animate(withDuration: 0.3, animations: {
            self.view.layoutIfNeeded()
        }, completion: { (animate) in
            self.bt_help.isHidden = false
            self.bt_current_location.isHidden = false
            self.v_list.frame = self.tb_hospital.frame
        })
        
        isMaxiMize = false
    }
    
    @IBAction func handlePanGesture(_ sender: UIPanGestureRecognizer) {
        if sender.state == .ended {
            if case .Down = sender.verticalDirection(target: self.view) {
                minimizeHospitalList()
            } else {
                maximizeHospitalList()
            }
        }
    }
    
    @IBAction func handleTapGesture(_ sender: UITapGestureRecognizer) {
//        if isMaxiMize == true {
//            minimizeHospitalList()
//        } else {
//            maximizeHospitalList()
//        }
        
        let hospital = hospitals[0] as! [String: Any]
        
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

extension UIScrollView {
    var isBouncing: Bool {
        return isBouncingTop || isBouncingLeft || isBouncingBottom || isBouncingRight
    }
    var isBouncingTop: Bool {
        return contentOffset.y < -contentInset.top
    }
    var isBouncingLeft: Bool {
        return contentOffset.x < -contentInset.left
    }
    var isBouncingBottom: Bool {
        let contentFillsScrollEdges = contentSize.height + contentInset.top + contentInset.bottom >= bounds.height
        return contentFillsScrollEdges && contentOffset.y > contentSize.height - bounds.height + contentInset.bottom
    }
    var isBouncingRight: Bool {
        let contentFillsScrollEdges = contentSize.width + contentInset.left + contentInset.right >= bounds.width
        return contentFillsScrollEdges && contentOffset.x > contentSize.width - bounds.width + contentInset.right
    }
}
