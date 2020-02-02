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
    
        //緯度を取得
    //ここをクラス変数にして、「MAPのどこかをタップした時はその場所にカメラを移動し、追跡をOFFに」で緯度、経度を変更できるようにする。
    //    let latitude = location.coordinate.latitude
    let latitude:Double! = 0
        
    //ここをクラス変数で定義して（スコープの範囲が狭いので）、「MAPのどこかをタップした時はその場所にカメラを移動し、追跡をOFFに」で緯度、経度を変更できるようにする。
//        let longitude = location.coordinate.longitude
    let longitude:Double! = 0
    
//    位置情報の機能を管理する'CLLocationManager'クラスのインスタンスlocationManagerをViewControllerクラスのメンバプロパティとして宣言しておく
    var locationManager: CLLocationManager!
//    GMSMapView インスタンスを生成
    let camera = GMSCameraPosition()
    var mapView = GMSMapView(){
        didSet{
            mapView.camera = camera
            mapView.delegate = self
        }
    }
    
    var timerBool:Bool = true
    
    var googleMap : GMSMapView!
    
//    locationManagerオブジェクトの初期化は、setupLocationManager()メソッドを定義して行なっています。
    override func viewDidLoad() {
        super.viewDidLoad()
       setupLocationManager()
       setupMapView()
    }
    
    private func setupMapView(){
        view = mapView
        mapView.mapType = .normal
        mapView.isMyLocationEnabled = true
    }
        
    private func setupLocationManager() {
        locationManager = CLLocationManager()
        locationManager.delegate = self
        guard let locationManager = locationManager else { return }

        locationManager.requestWhenInUseAuthorization()

//        ユーザから「アプリ使用中の位置情報取得」の許可が得られた場合のみ、マネージャの設定を行います。
        let status = CLLocationManager.authorizationStatus()
//        管理マネージャが位置情報を更新するペースをdistanceFilterプロパティにメートル単位で設定します。
        if status == .authorizedWhenInUse {
            locationManager.distanceFilter = 1
//        startUpdatingLocation()メソッドで、位置情報の取得を開始しています。
            locationManager.startUpdatingLocation()
        }
     }
    
//    CLLocationCoordinate2D（経緯度）
    private func getPlaces(coordinate: CLLocationCoordinate2D) {

        let requestURLString = "https://map.yahooapis.jp/search/local/V1/localSearch?cid=d8a23e9e64a4c817227ab09858bc1330&dist=2&query=%E3%83%A9%E3%83%BC%E3%83%A1%E3%83%B3&appid=dj00aiZpPURMZ1RFbm94cDVJbyZzPWNvbnN1bWVyc2VjcmV0Jng9NmY-&output=json&sort=geo"
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
//        timerBool = false //追跡OFF
    //                ここでdelegateに返すのか否か
    }

    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if (status == .authorizedWhenInUse) {
            // Show dialog to ask user to allow getting location data
            locationManager.requestWhenInUseAuthorization()
            //locationManagerのデリゲートになる
            locationManager.delegate = self
        }
    }
  
    //MAPの赤いマーカーをタップした時はその場所にカメラを移動し、追跡をOFFに
    func tapredMarker(mapView: GMSMapView, didTapAtCoordinate coordinate: CLLocationCoordinate2D) {
        timerBool = false //追跡OFF
//            googleMap.animate(toLocation:coordinate)
//            googleMap.animateToLocation(coordinate) //カメラを現在地に
//            if let location = locations.first {
//
//            let latitude = location.coordinate.latitude
//            let longitude = location.coordinate.longitude
//            print("latitude: \(latitude)\nlongitude: \(longitude)")
//
//            }
    }
    
    //locationManager:didUpdateLocationsデリゲートメソッドで位置情報を受け取る
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
//      .firstで配列の先頭を取得する?
        if let location = locations.first {
            
            let latitude = location.coordinate.latitude
            let longitude = location.coordinate.longitude
            print("latitude: \(latitude)\nlongitude: \(longitude)")

            if(timerBool){
            
            let yourlocation = GMSCameraPosition.camera(withLatitude: latitude,
                                                        longitude: longitude,
                                                        zoom: 17)
            
            mapView.camera = yourlocation
        
            getPlaces(coordinate: location.coordinate)
            }
        }
    }
    
        //MAPの赤いマーカーをタップした時はその場所にカメラを移動し、追跡をOFFに
//        func tapredMarker(mapView: GMSMapView, didTapAtCoordinate coordinate: CLLocationCoordinate2D) {
//            timerBool = false //追跡OFF
////            googleMap.animate(toLocation:coordinate)
////            googleMap.animateToLocation(coordinate) //カメラを現在地に
////            if let location = locations.first {
////
////            let latitude = location.coordinate.latitude
////            let longitude = location.coordinate.longitude
////            print("latitude: \(latitude)\nlongitude: \(longitude)")
////
////            }
//        }
        
        //gesture（ピンチやズームなど）があった際は、追跡をOFFに
        func gestureView(mapView: GMSMapView, willMove gesture: Bool) {
            if gesture {
                timerBool = false //追跡OFF
            }
        }
}
