import UIKit

class MapViewController: UIViewController {

    var gpxURL: URL? {
        didSet {
            if let url = gpxURL {
                GPX.parse(url) { gpx in
                    if gpx != nil {

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
}
