import UIKit
import MapKit

class MapViewController: UIViewController, MKMapViewDelegate {

    @IBOutlet weak var mapView: MKMapView! {
        didSet {
            mapView.delegate = self
        }
    }

    var gpxURL: URL? {
        didSet {
            if let url = gpxURL {
                GPX.parse(url) { gpx in
                    if gpx != nil {
                        var coordinates = [CLLocationCoordinate2D]()
                        if let first = gpx?.tracks.first {
                            self.addWaypoints([first.fixes.first!])
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
        for i in 1...44 {
            let urlpath = Bundle.main.path(forResource: "\(i)", ofType: "gpx")
            gpxURL = NSURL.fileURL(withPath: urlpath!)
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

    func addWaypoints(_ waypoints: [GPX.Waypoint]) {
        mapView?.addAnnotations(waypoints)
        mapView?.showAnnotations(waypoints, animated: true)
    }

    func selectWaypoint(_ waypoint: GPX.Waypoint?) {
        if waypoint != nil {
            mapView.selectAnnotation(waypoint!, animated: true)
        }
    }
}
