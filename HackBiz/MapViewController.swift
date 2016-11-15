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
        let urlpath = Bundle.main.path(forResource: "tappa-01-dal-gran-s-bernardo-echevennoz", ofType: "gpx")
        gpxURL = NSURL.fileURL(withPath: urlpath!)
    }

    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if overlay is MKPolyline {
            let lineView = MKPolylineRenderer(overlay: overlay)
            lineView.strokeColor = UIColor.green
            return lineView
        }
        return MKOverlayRenderer()
    }
}
