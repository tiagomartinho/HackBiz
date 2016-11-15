import UIKit
import Koloda
import CoreLocation

class ExploreViewController: UIViewController{

    @IBOutlet weak var kolodaView: KolodaView!

    var dataSource: [Place] = {
        var links = ["https://it.wikipedia.org/wiki/Museum_of_Fine_Arts_(Boston)"]
        var coordinates = [CLLocationCoordinate2D(latitude: 45.869000,
                                                  longitude: 7.170561)]
        var array: [Place] = []
        for index in 0..<1 {
            let image = UIImage(named: "Card_like_\(index + 1)")!
            let place = Place(image: image,
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
    let image: UIImage
    let link: String
    var coordinate: CLLocationCoordinate2D
}

extension ExploreViewController: KolodaViewDelegate {
    func kolodaDidRunOutOfCards(koloda: KolodaView) {
    }

    func koloda(_ koloda: KolodaView, didSelectCardAt index: Int) {
        UIApplication.shared.openURL(URL(string: dataSource[Int(index)].link)!)
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

    func koloda(koloda: KolodaView, viewForCardOverlayAtIndex index: Int) -> OverlayView? {
        return Bundle.main.loadNibNamed("OverlayView",
                                                  owner: self, options: nil)?[0] as? OverlayView
    }
}
