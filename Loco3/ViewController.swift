//
//  ViewController.swift
//  Loco3
//
//  Created by 宮崎直久 on 2019/11/18.
//  Copyright © 2019 宮崎直久. All rights reserved.
//

import UIKit
import CoreData
import GoogleMaps
import Alamofire
import SwiftyJSON
import CoreLocation

//CLLocationManagerDelegateプロトコルを採用
class ViewController: UIViewController, GMSMapViewDelegate, CLLocationManagerDelegate {
    
//    位置情報の機能を管理する'CLLocationManager'クラスのインスタンスlocationManagerをViewControllerクラスのメンバプロパティとして宣言しておく
    var locationManager: CLLocationManager!
//    GMSMapView インスタンスを生成
    var mapView: GMSMapView!

//    locationManagerオブジェクトの初期化は、setupLocationManager()メソッドを定義して行なっています。
    override func viewDidLoad() {
        super.viewDidLoad()
        setupLocationManager()
    }
        
    func setupLocationManager() {
        locationManager = CLLocationManager()
        guard let locationManager = locationManager else { return }

        locationManager.requestWhenInUseAuthorization()

//        ユーザから「アプリ使用中の位置情報取得」の許可が得られた場合のみ、マネージャの設定を行います。
//        管理マネージャが位置情報を更新するペースをdistanceFilterプロパティにメートル単位で設定します。
//        startUpdatingLocation()メソッドで、位置情報の取得を開始しています。
        let status = CLLocationManager.authorizationStatus()
        if status == .authorizedWhenInUse {
            locationManager.distanceFilter = 10
            locationManager.startUpdatingLocation()
        }
     }
//setupLocationManager()メソッド内で、許可ステータスが.authorizedWhenInUseの場合にViewControllerクラスが管理マネージャのデリゲート先になるようにします。
//     func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
//         let location = locations.first
//         let latitude = location?.coordinate.latitude
//         let longitude = location?.coordinate.longitude
//
//         print("latitude: \(latitude!)\nlongitude: \(longitude!)")
//     }
    
//        アプリの使用中に位置情報サービスを使用するユーザーの許可を要求します。
//        locationManager.requestWhenInUseAuthorization()
//        locationManager.delegate = self
//
////        位置情報サービスを使用するためのアプリの承認ステータスを返します。
////        戻り値：アプリが位置情報サービスの使用を許可されているかどうかを示す値。
//        let status = CLLocationManager.authorizationStatus()
////        authorizedWhenInUse:アプリが使用中のみ位置情報の取得が可能です。
////        CLLocationManagerのstartUpdatingLocation()メソッドで、位置情報の取得を開始できます。 （stopUpdatingLocation()で停止）
//        if status == .authorizedWhenInUse {
//            locationManager.startUpdatingLocation()
//        }
//
//
//        let camera = GMSCameraPosition.camera(withLatitude: 35.665751, longitude: 139.728687, zoom: 6.0)
//        let mapView = GMSMapView.map(withFrame: CGRect.zero, camera: camera)
//        mapView.delegate = self
//        view = mapView
    
   
    
//    CLLocationCoordinate2D（経緯度）
    func getPlaces(coordinate: CLLocationCoordinate2D) {

        let requestURLString = "https://map.yahooapis.jp/search/local/V1/localSearch?cid=d8a23e9e64a4c817227ab09858bc1330&dist=2&query=%E3%82%B3%E3%83%B3%E3%83%93%E3%83%8B&appid=dj00aiZpPURMZ1RFbm94cDVJbyZzPWNvbnN1bWVyc2VjcmV0Jng9NmY-&output=json&sort=geo"
            + "&lat=" + String(coordinate.latitude) + "&lon=" + String(coordinate.longitude)
        Alamofire.request(requestURLString).responseJSON { response in

            if let jsonObject = response.result.value {
                let json = JSON(jsonObject)
                let features = json["Feature"]
                // If json is .Dictionary
                for ( _ ,subJson):(String, JSON) in features {

                    let coordinate = subJson["Geometry"]["Coordinates"].stringValue.split(separator: ",")

                    let marker = GMSMarker()
                    marker.position = CLLocationCoordinate2D(latitude:Double(coordinate[1])!,longitude:Double(coordinate[0])!)
                    marker.title = subJson["Name"].stringValue
                    marker.snippet = subJson["Property"]["Address"].stringValue
                    marker.map = self.mapView

                }
            }
        }
    }

            func mapView(_ mapView: GMSMapView, didTapInfoWindowOf marker: GMSMarker) {
                print(marker)
            }

            func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
                if (status == .authorizedWhenInUse) {
                    // Show dialog to ask user to allow getting location data
                    locationManager.requestWhenInUseAuthorization()
                }
            }

            func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {

                if let location = locations.first {
                    let latitude = location.coordinate.latitude
                    let longitude = location.coordinate.longitude

                    print("latitude: \(latitude)\nlongitude: \(longitude)")

                    let yourlocation = GMSCameraPosition.camera(withLatitude: latitude,
                                                                longitude: longitude,
                                                                zoom: 15)
                    mapView.camera = yourlocation

                    getPlaces(coordinate: location.coordinate)
                }
            }
}
