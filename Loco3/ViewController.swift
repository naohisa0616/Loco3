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
import GooglePlaces

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
//        GMSCameraPositionで緯度経度を取得
        let camera = GMSCameraPosition.camera(withLatitude: 35.665751, longitude: 139.728687, zoom: 6.0)
//        mapViewのインスタンスを生成
        let mapView = GMSMapView.map(withFrame: CGRect.zero, camera: camera)
//        位置情報の変化を受け取ってlocationManager(_ manage, didUpdateLocations locations:) を実行
        mapView.delegate = self
//        mapViewを表示
        view = mapView
    }
        
    func setupLocationManager() {
        locationManager = CLLocationManager()
        guard let locationManager = locationManager else { return }

        locationManager.requestWhenInUseAuthorization()

//        ユーザから「アプリ使用中の位置情報取得」の許可が得られた場合のみ、マネージャの設定を行います。
        let status = CLLocationManager.authorizationStatus()
//        管理マネージャが位置情報を更新するペースをdistanceFilterプロパティにメートル単位で設定します。
        if status == .authorizedWhenInUse {
            locationManager.distanceFilter = 10
//        startUpdatingLocation()メソッドで、位置情報の取得を開始しています。
            locationManager.startUpdatingLocation()
        }
     }
    
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
//                ここでdelegateに返すのか否か
            }

            func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
                if (status == .authorizedWhenInUse) {
                    // Show dialog to ask user to allow getting location data
                    locationManager.requestWhenInUseAuthorization()
                    locationManager.delegate = self
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
