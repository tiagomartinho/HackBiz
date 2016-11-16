import UIKit
import Koloda
import CoreLocation
import MapKit
import SafariServices

class ExploreViewController: UIViewController{

    @IBOutlet weak var kolodaView: KolodaView!

    var dataSource: [Place] = {
        var names = ["Seravezza",
                     "Lucca",
                     "Castel San Giovanni",
                     "Siena",
                     "Grotte di Castro",
                     "Bassano Romano",
                     "Anguillara Sabazia",
                     "Novara"]

        var descriptions = ["",
                     "",
                     "",
                     "",
                     "",
                     "",
                     "",
                     ""]

        var links = ["https://it.wikipedia.org/wiki/Seravezza",
                     "https://it.wikipedia.org/wiki/Lucca",
                     "https://it.wikipedia.org/wiki/Castel_San_Giovanni",
                     "https://it.wikipedia.org/wiki/Siena",
                     "https://it.wikipedia.org/wiki/Grotte_di_Castro",
                     "https://it.wikipedia.org/wiki/Bassano_Romano",
                     "https://it.wikipedia.org/wiki/Anguillara_Sabazia",
                     "https://it.wikipedia.org/wiki/Novara"]

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
            let smallImage = UIImage(named: "\(index + 1)small")!
            let place = Place(name: names[index],
                              subtitle: descriptions[index],
                              image: image,
                              smallImage: smallImage,
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

class Place: NSObject {
    let name: String
    let subtitle: String?
    let image: UIImage
    let smallImage: UIImage
    let link: String
    var coordinate: CLLocationCoordinate2D

    init(name: String, subtitle: String, image: UIImage, smallImage: UIImage, link: String, coordinate: CLLocationCoordinate2D) {
        self.name = name
        self.subtitle = subtitle
        self.image = image
        self.smallImage = smallImage
        self.link = link
        self.coordinate = coordinate
    }
}

extension Place: MKAnnotation {
    var title: String? { return name }
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
                maps.mapView.addAnnotation(dataSource[Int(index)])
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
