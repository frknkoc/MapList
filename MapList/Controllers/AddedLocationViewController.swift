import UIKit
import MapKit
import CoreData

class AddedLocationViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {
    
    var selectedName = ""
    var selectedId : UUID?
    
    var annotationName = ""
    var annotationNote = ""
    var annotationLatitude = Double()
    var annotationLongitude = Double()

    @IBOutlet weak var noteTextfield: UITextField!
    @IBOutlet weak var nameTextfield: UITextField!
    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.delegate = self

        if selectedName != ""{
            if let uuidString = selectedId?.uuidString{
                let appDelegate = UIApplication.shared.delegate as! AppDelegate
                let context = appDelegate.persistentContainer.viewContext
                
                let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Location")
                fetchRequest.predicate = NSPredicate(format: "id = %@", uuidString)
                fetchRequest.returnsObjectsAsFaults = false
                
                do  {
                    let sonuclar = try context.fetch(fetchRequest)
                    if sonuclar.count > 0 {

                        for sonuc in sonuclar as! [NSManagedObject]{
                            if let name = sonuc.value(forKey: "name") as? String {
                                annotationName = name
                                
                                if let note = sonuc.value(forKey: "note") as? String {
                                    annotationNote = note
                                    
                                    if let latitude = sonuc.value(forKey: "latitude") as? Double {
                                        annotationLatitude = latitude
                                        
                                        if let longitude = sonuc.value(forKey: "longitude") as? Double {
                                            annotationLongitude = longitude
                                            
                                            let annotation = MKPointAnnotation()
                                            annotation.title = annotationName
                                            annotation.subtitle = annotationNote
                                            let coordinate = CLLocationCoordinate2D(latitude: annotationLatitude, longitude: annotationLongitude)
                                            annotation.coordinate = coordinate
                                            let span = MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.005)
                                            let region = MKCoordinateRegion(center: coordinate, span: span)
                                            mapView.setRegion(region, animated: true)
                                            
                                            mapView.addAnnotation(annotation)
                                            nameTextfield.text = annotationName
                                            noteTextfield.text = annotationNote
                                        }
                                    }
                                }
                            }
                        }
                    }
                } catch {
                    print("HATA")
                }
            }
        }
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation{
            return nil
        }
        let reusedId = "benimAnnotation"
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: "reusedId")
        
        if pinView == nil {
            pinView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: reusedId)
            pinView?.canShowCallout = true
            pinView?.tintColor = .red
            
            let button = UIButton(type: .detailDisclosure)
            pinView?.rightCalloutAccessoryView = button
        } else {
            pinView?.annotation = annotation
        }
        return pinView
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        var requestLocation = CLLocation(latitude: annotationLatitude, longitude: annotationLongitude)
        CLGeocoder().reverseGeocodeLocation(requestLocation) {(placemarkArr, hata) in
            if let placemarks = placemarkArr{
                if placemarks.count > 0 {
                    let yeniPlacemark = MKPlacemark(placemark: placemarks[0])
                    let item = MKMapItem(placemark: yeniPlacemark)
                    item.name = self.annotationName
                    
                    let launchOptions = [MKLaunchOptionsDirectionsModeKey : MKLaunchOptionsDirectionsModeDriving]
                    item.openInMaps(launchOptions: launchOptions)
                }
                
            }
        }
    }
}



