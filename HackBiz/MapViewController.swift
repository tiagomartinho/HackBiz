import UIKit
import MapKit

class MapViewController: UIViewController, MKMapViewDelegate {

    @IBOutlet weak var mapView: MKMapView! {
        didSet {
            mapView.delegate = self
        }
    }

    var tracks = [Waypoint]()

    var gpxURL: URL? {
        didSet {
            if let url = gpxURL {
                GPX.parse(url) { gpx in
                    if gpx != nil {
                        var coordinates = [CLLocationCoordinate2D]()
                        if let first = gpx?.tracks.first {
                            var track = first.fixes.first!
                            track.info = first.fixes.description
                            self.tracks.append(track)
//                            DispatchQueue.main.async {
//                                self.mapView.addAnnotation(track)
//                            }
                            for fixe in first.fixes {
                                coordinates.append(fixe.coordinate)
                            }
                        }
                        let myPolyline = MKPolyline(coordinates: &coordinates, count: coordinates.count)
                        DispatchQueue.main.async {
                            self.mapView.add(myPolyline)
                        }
                    }
                }
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        DispatchQueue.global(qos: .background).async {
            for i in 1...44 {
                let urlpath = Bundle.main.path(forResource: "\(i)", ofType: "gpx")
                self.gpxURL = NSURL.fileURL(withPath: urlpath!)
            }
        }
    }

    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if overlay is MKPolyline {
            let lineView = MKPolylineRenderer(overlay: overlay)
            if (overlay.title ?? "") == "RED" {
                lineView.strokeColor = #colorLiteral(red: 0.7450980544, green: 0.1568627506, blue: 0.07450980693, alpha: 1)
            } else {
                lineView.strokeColor = #colorLiteral(red: 0.05882352941, green: 0.6156862745, blue: 0.3450980392, alpha: 1)
            }
            return lineView
        }
        return MKOverlayRenderer()
    }

    func selectWaypoint(_ waypoint: Waypoint?) {
        if waypoint != nil {
            mapView.selectAnnotation(waypoint!, animated: true)
        }
    }

    @IBAction func longPressGesture(_ sender: UILongPressGestureRecognizer) {
        if sender.state == .began {
            let touchPoint = sender.location(in: mapView)
            let newCoordinates = mapView.convert(touchPoint, toCoordinateFrom: mapView)
            let annotation = MKPointAnnotation()
            annotation.coordinate = newCoordinates
        }
    }

    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "reuseIdentifier")
        annotationView.pinTintColor = #colorLiteral(red: 0.05882352941, green: 0.6156862745, blue: 0.3450980392, alpha: 1)
        annotationView.canShowCallout = true
        annotationView.rightCalloutAccessoryView = UIButton(type: .contactAdd)
        annotationView.leftCalloutAccessoryView = UIButton(frame: CGRect(x: 0, y: 0, width: 59, height: 59))
        return annotationView
    }

    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        if let thumbnailImageButton = view.leftCalloutAccessoryView as? UIButton {
            let image = #imageLiteral(resourceName: "italy")
            thumbnailImageButton.setImage(image, for: UIControlState())
        }
    }

    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        let location = CLLocation(latitude: (view.annotation?.coordinate.latitude)!,
                                   longitude: (view.annotation?.coordinate.longitude)!)
        let (waypoint1, waypoint2) = nearest(location: location, waypoints: tracks)
        let sourceLocation1 = CLLocationCoordinate2D(latitude: (waypoint1?.latitude)!,
                                                    longitude: (waypoint1?.longitude)!)
        let destinationLocation = location.coordinate
        let sourceLocation2 = CLLocationCoordinate2D(latitude: (waypoint2?.latitude)!,
                                                    longitude: (waypoint2?.longitude)!)
        drawRoute(sourceLocation: sourceLocation1, destinationLocation: destinationLocation)
        drawRoute(sourceLocation: destinationLocation, destinationLocation: sourceLocation2)
    }

    func drawRoute(sourceLocation: CLLocationCoordinate2D, destinationLocation: CLLocationCoordinate2D) {
        let sourcePlacemark = MKPlacemark(coordinate: sourceLocation, addressDictionary: nil)
        let destinationPlacemark = MKPlacemark(coordinate: destinationLocation, addressDictionary: nil)

        let sourceMapItem = MKMapItem(placemark: sourcePlacemark)
        let destinationMapItem = MKMapItem(placemark: destinationPlacemark)

        let sourceAnnotation = MKPointAnnotation()

        if let location = sourcePlacemark.location {
            sourceAnnotation.coordinate = location.coordinate
        }


        let destinationAnnotation = MKPointAnnotation()

        if let location = destinationPlacemark.location {
            destinationAnnotation.coordinate = location.coordinate
        }

//        self.mapView.showAnnotations([sourceAnnotation,destinationAnnotation], animated: true )

        let directionRequest = MKDirectionsRequest()
        directionRequest.source = sourceMapItem
        directionRequest.destination = destinationMapItem
        directionRequest.transportType = .walking

        let directions = MKDirections(request: directionRequest)
        directions.calculate {
            (response, error) -> Void in

            guard let response = response else {
                if let error = error {
                    print("Error: \(error)")
                }

                return
            }

            let route = response.routes[0]
            let polyline = route.polyline
            polyline.title = "RED"
            self.mapView.add(polyline, level: .aboveRoads)

            let rect = route.polyline.boundingMapRect
            self.mapView.setRegion(MKCoordinateRegionForMapRect(rect), animated: true)
        }
    }

    func nearest(location: CLLocation?,
                        waypoints: [Waypoint]) -> (Waypoint?,Waypoint?) {
        guard let location = location else { return (nil,nil) }

        var min = waypoints.first!
        for waypoint in waypoints {
            let location1 = CLLocation(latitude: waypoint.latitude,
                                       longitude: waypoint.longitude)
            let location2 = CLLocation(latitude: min.latitude,
                                       longitude: min.longitude)
            if location.distance(from: location1) < location.distance(from: location2) {
                min = waypoint
            }
        }

        var min2 = waypoints.first!
        for waypoint in waypoints {
            if waypoint != min {
                let location1 = CLLocation(latitude: waypoint.latitude,
                                           longitude: waypoint.longitude)
                let location2 = CLLocation(latitude: min2.latitude,
                                           longitude: min2.longitude)
                if location.distance(from: location1) < location.distance(from: location2) {
                    min2 = waypoint
                }
            }
        }

        return (min,min2)
    }
}
