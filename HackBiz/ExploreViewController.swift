import UIKit
import Koloda
import CoreLocation
import MapKit
import SafariServices

class ExploreViewController: UIViewController{

    @IBOutlet weak var kolodaView: KolodaView!

    var dataSource: [Place] = {
        var names = ["Bassiano",
                     "Castel Gandolfo",
                     "Fondi",
                     "Formia",
                     "Giulianello",
                     "Itri",
                     "Nemi",
                     "Priverno"]

        var links = ["https://it.wikipedia.org/wiki/Bassiano",
                     "https://it.wikipedia.org/wiki/Castel_Gandolfo",
                     "https://it.wikipedia.org/wiki/Fondi",
                     "https://it.wikipedia.org/wiki/Formia",
                     "https://it.wikipedia.org/wiki/Giulianello",
                     "https://it.wikipedia.org/wiki/Itri",
                     "https://it.wikipedia.org/wiki/Nemi",
                     "https://it.wikipedia.org/wiki/Priverno"]

        var coordinates = [CLLocationCoordinate2D(latitude: 44, longitude: 10.233333),
                                             CLLocationCoordinate2D(latitude: 43.85, longitude: 10.516667),
                                             CLLocationCoordinate2D(latitude: 45.05, longitude: 9.433333),
                                             CLLocationCoordinate2D(latitude: 43.318333, longitude: 11.331389),
                                             CLLocationCoordinate2D(latitude: 42.675278, longitude: 11.873056),
                                             CLLocationCoordinate2D(latitude: 42.225278, longitude: 12.19),
                                             CLLocationCoordinate2D(latitude: 42.088333, longitude: 12.2775),
                                             CLLocationCoordinate2D(latitude: 45.45, longitude: 8.616667)]

        var array: [Place] = []
        for index in 0..<8 {
            let image = UIImage(named: "\(index + 1)")!
            let place = Place(name: names[index],
                              image: image,
                              link: links[index],
                              coordinate: coordinates[index])
            array.append(place)
        }
        return array
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        kolodaView.dataSource = self
        kolodaView.delegate = self
    }

    @IBAction func addToJourney(_ sender: Any) {
        kolodaView.swipe(SwipeResultDirection.right)
    }

    @IBAction func ignore(_ sender: Any) {
        kolodaView.swipe(SwipeResultDirection.left)
    }
}

struct Place {
    let name: String
    let image: UIImage
    let link: String
    var coordinate: CLLocationCoordinate2D
}

extension ExploreViewController: KolodaViewDelegate {
    func kolodaDidRunOutOfCards(_ koloda: KolodaView) {
        kolodaView.resetCurrentCardIndex()
    }

    func koloda(_ koloda: KolodaView, didSelectCardAt index: Int) {
        let svc = SFSafariViewController(url: URL(string: dataSource[Int(index)].link)!)
        self.present(svc, animated: true, completion: nil)
    }

    func koloda(_ koloda: KolodaView, didSwipeCardAt index: Int, in direction: SwipeResultDirection) {
        if direction == SwipeResultDirection.right {
            if let maps = tabBarController?.viewControllers?.first as? MapViewController {
                let annotation = MKPointAnnotation()
                annotation.coordinate = dataSource[Int(index)].coordinate
                annotation.title = "A"
                maps.mapView.addAnnotation(annotation)
            }
        }
    }
}

extension ExploreViewController: KolodaViewDataSource {

    func kolodaNumberOfCards(_ koloda:KolodaView) -> Int {
        return dataSource.count
    }

    func koloda(_ koloda: KolodaView, viewForCardAt index: Int) -> UIView {
        let imageView = UIImageView(image: dataSource[Int(index)].image)
        imageView.contentMode = UIViewContentMode.scaleAspectFit
        return imageView
    }

    func koloda(_ koloda: KolodaView, viewForCardOverlayAt index: Int) -> OverlayView? {
        return Bundle.main.loadNibNamed("ExampleOverlayView",
                                                  owner: self, options: nil)?[0] as? ExampleOverlayView
    }
}
