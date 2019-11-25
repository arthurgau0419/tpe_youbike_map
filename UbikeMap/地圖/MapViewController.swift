//
//  MapViewController.swift
//  UbikeMap
//
//  Created by Kao Ming-Hsiu on 2019/11/25.
//  Copyright © 2019 ObiCat. All rights reserved.
//

import UIKit
import MapKit
import RxSwift
import RxCocoa
import RxMKMapView

class MapViewController: UIViewController {
    
    typealias ViewModel = MapViewModel
    
    let disposeBag = DisposeBag()
    
    var viewModel: ViewModel!
    
    @IBOutlet weak var reloadButton: UIBarButtonItem!
    
    @IBOutlet weak var mapView: MKMapView!
    
    var currentLoading: UIViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.delegate = self
//        mapView.register(StationAnnotationView.self, forAnnotationViewWithReuseIdentifier: "StationAnnotationView")
        
        mvvmViewDidload()
    }
}

extension MapViewController {
    @objc
    dynamic
    func moveToMapItem(id: String) {}
}

extension MapViewController: MVVM {
    
    func provideInput() -> MapViewModel.Input {
        return .init(
            reloadEvent: Observable.merge(
                reloadButton.rx.tap.asObservable(),
                rx.methodInvoked(#selector(viewWillAppear(_:))).map { _ in Void()}
            ),
            moveToItemEvent: rx.methodInvoked(#selector(moveToMapItem(id:)))
                .flatMap { Observable.from(optional: $0[0] as? String) },
            itemSelected: mapView.rx.didSelectAnnotationView
                .flatMap { Observable.from(optional: $0.annotation as? MapItemType) },
            itemDetailSelected: mapView.rx.annotationViewCalloutAccessoryControlTapped
                .flatMap { Observable.from(optional: $0.0.annotation as? MapItemType)                    
            }
        )
    }
    
    func bindingOutput(_ output: MapViewModel.Output) {
        
        output.stations
            .map { $0 as [MKAnnotation] }
            .drive(mapView.rx.annotations)
            .disposed(by: disposeBag)
        
        output.loading
            .asDriver(onErrorJustReturn: false)
            .drive(onNext: { [weak self] (loading) in
                if loading {
                    self?.currentLoading = navigator.present("loading")
                } else {
                    self?.currentLoading?.dismiss(animated: true, completion: nil)
                    self?.currentLoading = nil
                }
            })
            .disposed(by: disposeBag)
        
        output.moveToPoint
            .asDriver(onErrorJustReturn: MKCoordinateRegion())
            .drive(onNext: { [unowned self] (region) in
                self.mapView.setRegion(region, animated: false)
            })
            .disposed(by: disposeBag)
        
        output.addFavoriteAlert
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { (item) in
                let alc = UIAlertController.init(title: "我的最愛", message: nil, preferredStyle: .alert)
                alc.addAction(.init(title: item.我的最愛 ? "移除": "加入", style: item.我的最愛 ? .destructive: .default, handler: { (_) in
                    item.我的最愛 = !item.我的最愛
                }))
                alc.addAction(.init(title: "取消", style: .cancel, handler: nil))
                navigator.present(alc)
            })
            .disposed(by: disposeBag)
        
        output.selectItem
            .flatMap { [unowned self] item in
                Observable.from(optional: self.mapView.annotations.first(where: { ($0 as? MapItemType)?.id == item.id }))
            }
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { [unowned self] (item) in
                self.mapView.selectAnnotation(item, animated: true)
            })
            .disposed(by: disposeBag)
        
    }
}

// MARK: MKMapViewDelegate

class StationAnnotationView: MKPinAnnotationView {
    
    
    
}

extension MapViewController: MKMapViewDelegate {
    
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let reuseIdentifier = "StationAnnotationView"
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseIdentifier)

        if annotationView == nil {
            annotationView = StationAnnotationView(annotation: annotation, reuseIdentifier: reuseIdentifier)
            annotationView?.canShowCallout = true
            let label = UILabel()
            label.numberOfLines = 0
            label.font = UIFont.systemFont(ofSize: 18)
            annotationView?.detailCalloutAccessoryView = label
            
            annotationView?.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
            

        }
        
        annotationView?.annotation = annotation
        
        if
            let label = annotationView?.detailCalloutAccessoryView as? UILabel,
            let mapItem = annotation as? MapItem {
            label.text = """
            總停車格: \(mapItem.總停車格)
            目前數量: \(mapItem.目前車輛數量)
            空位數量: \(mapItem.空位數量)
            """
        }



        return annotationView
    }
    
}
