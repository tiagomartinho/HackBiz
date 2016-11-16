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
                            DispatchQueue.main.async {
                                self.mapView.addAnnotation(track)
                            }
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
            lineView.strokeColor = #colorLiteral(red: 0.05882352941, green: 0.6156862745, blue: 0.3450980392, alpha: 1)
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
        return annotationView
    }

    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        let location = CLLocation(latitude: (view.annotation?.coordinate.latitude)!,
                                   longitude: (view.annotation?.coordinate.longitude)!)
        let waypoint = nearest(location: location, waypoints: tracks)
        let sourceLocation = CLLocationCoordinate2D(latitude: (waypoint?.latitude)!, longitude: (waypoint?.longitude)!)
        let destinationLocation = location.coordinate

        let sourcePlacemark = MKPlacemark(coordinate: sourceLocation, addressDictionary: nil)
        let destinationPlacemark = MKPlacemark(coordinate: destinationLocation, addressDictionary: nil)

        let sourceMapItem = MKMapItem(placemark: sourcePlacemark)
        let destinationMapItem = MKMapItem(placemark: destinationPlacemark)

        let sourceAnnotation = MKPointAnnotation()
        sourceAnnotation.title = "Times Square"

        if let location = sourcePlacemark.location {
            sourceAnnotation.coordinate = location.coordinate
        }


        let destinationAnnotation = MKPointAnnotation()
        destinationAnnotation.title = "Empire State Building"

        if let location = destinationPlacemark.location {
            destinationAnnotation.coordinate = location.coordinate
        }

        self.mapView.showAnnotations([sourceAnnotation,destinationAnnotation], animated: true )

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
            self.mapView.add((route.polyline), level: .aboveRoads)

            let rect = route.polyline.boundingMapRect
            self.mapView.setRegion(MKCoordinateRegionForMapRect(rect), animated: true)
        }
    }

    func nearest(location: CLLocation?,
                        waypoints: [Waypoint]) -> Waypoint? {
        guard let location = location else { return nil }

        return waypoints.min { w1, w2 in
                let location1 = CLLocation(latitude: w1.latitude,
                                           longitude: w1.longitude)
                let location2 = CLLocation(latitude: w2.latitude,
                                           longitude: w2.longitude)
                return location.distance(from: location1) < location.distance(from: location2)
        }
    }
}
