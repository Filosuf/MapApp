//
//  ViewController.swift
//  MapApp
//
//  Created by Filosuf on 28.12.2022.
//

import UIKit
import MapKit

final class ViewController: UIViewController {
    // MARK: - Properties
    private let mapView = MKMapView()
    private let locationManager = CLLocationManager()
    private lazy var alertPresenter  = AlertPresenter(viewController: self)
    private var pins = [MKPointAnnotation]()

    // MARK: - LifeCicle
    override func viewDidLoad() {
        super.viewDidLoad()
        checkUserLocationPermissions()
        locationManager.startUpdatingLocation()
        locationManager.delegate = self
        configureMapView()
        view = mapView
    }

    // MARK: - Methods
    private func configureMapView() {
        mapView.delegate = self
        mapView.showsCompass = true
        mapView.showsScale = true
        mapView.showsUserLocation = true
        let longTapGesture = UILongPressGestureRecognizer(target: self, action: #selector(longTap))
        mapView.addGestureRecognizer(longTapGesture)
    }

    @objc private func longTap(sender: UIGestureRecognizer){
        if sender.state == .began {
            let locationInView = sender.location(in: mapView)
            let locationOnMap = mapView.convert(locationInView, toCoordinateFrom: mapView)
            let numOfPin = pins.count + 1
            alertPresenter.showAction(message: "#\(numOfPin)") { [weak self] action in
                guard let self = self else { return }
                switch action {
                case .addPin:
                    self.addPoint(location: locationOnMap, title: "Pin #\(numOfPin)")
                case .newRoute:
                    if self.checkUserLocationPermissions() {
                        self.newRoute(destination: locationOnMap)
                    }
                case .removeAll:
                    self.removeAllPins()
                }
            }
        }
    }

    private func checkUserLocationPermissions() -> Bool {
        print(locationManager.authorizationStatus)
        locationManager.requestWhenInUseAuthorization()
        if self.locationManager.authorizationStatus == .authorizedWhenInUse {
            return true
        } else {
            alertPresenter.showRequestAuthorization { [weak self] in
                self?.goToSettings()
            }
            return false
        }
    }

    ///Переход в настройки приложения
    private func goToSettings() {
        if let appSettings = URL(string: UIApplication.openSettingsURLString), UIApplication.shared.canOpenURL(appSettings) {
            UIApplication.shared.open(appSettings)
        }
    }

    private func addPoint(location: CLLocationCoordinate2D, title: String){
        let annotation = MKPointAnnotation()
        annotation.coordinate = location
        annotation.title = title
        pins.append(annotation)
        mapView.addAnnotation(annotation)
    }

    private func removeAllPins() {
        mapView.removeAnnotations(pins)
    }


    ///Проложить маршрут от текущего местоположения
    private func newRoute(destination: CLLocationCoordinate2D) {
        removeAllRoute()
        let request = MKDirections.Request()

        guard let sourceCoordinate = locationManager.location?.coordinate else { return }
        let sourcePlaceMark = MKPlacemark(coordinate: sourceCoordinate)
        request.source = MKMapItem(placemark: sourcePlaceMark)

        let destinationPlaceMark = MKPlacemark(coordinate: destination)
        request.destination = MKMapItem(placemark: destinationPlaceMark)

        request.transportType = .any

        let directions = MKDirections(request: request)
        directions.calculate { [weak self] response, error in
            guard let response = response else { return }

            let route = response.routes[0]
            self?.mapView.addOverlay(route.polyline, level: .aboveRoads)
        }
    }

    ///Удаление всех маршрутов
    private func removeAllRoute() {
        mapView.removeOverlays(mapView.overlays)
    }
}

// MARK: - CLLocationManagerDelegate
extension ViewController: CLLocationManagerDelegate {

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else { return }

        let region = MKCoordinateRegion(center: location.coordinate, span: MKCoordinateSpan(latitudeDelta: 1, longitudeDelta: 1))
        mapView.setRegion(region, animated: true)
    }
}
// MARK: - MKMapViewDelegate
extension ViewController: MKMapViewDelegate {

    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(overlay: overlay)
        renderer.strokeColor = .blue
        renderer.lineWidth = 5
        return renderer
    }
}
