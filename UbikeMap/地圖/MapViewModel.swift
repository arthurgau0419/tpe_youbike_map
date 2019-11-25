//
//  MapViewModel.swift
//  UbikeMap
//
//  Created by Kao Ming-Hsiu on 2019/11/25.
//  Copyright © 2019 ObiCat. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import Moya
import struct MapKit.MKCoordinateRegion
import MapKit

class MapViewModel: ViewModelType {
    
    struct Input {
        let reloadEvent: Observable<Void>
        let moveToItemEvent: Observable<String>
        let itemSelected: Observable<MapItemType>
        let itemDetailSelected: Observable<MapItemType>
    }
    
    struct Output {
        let stations: Driver<[MapItemType]>
        let moveToPoint: Observable<MKCoordinateRegion>
        let addFavoriteAlert: Observable<MapItemType>
        let selectItem: Observable<MapItemType>
        let loading: Observable<Bool>
    }
    
    let stations: [UbikeStation]
    
    let reloadStationProvider = MoyaProvider<UBikeService>()
    
    private let backgroundScheduler = ConcurrentDispatchQueueScheduler(qos: .background)
    
    func transform(input: MapViewModel.Input) -> MapViewModel.Output {
        
        let loading = PublishSubject<Bool>()
        
        let stations = input.reloadEvent
            .flatMap { [unowned self] _ in
                self.reloadStationProvider.rx.request(.init())
                    .observeOn(self.backgroundScheduler)
                    .map(DynamicKeyContainer<UbikeStation>.self, atKeyPath: "retVal", using: UBikeService.decoder)
                    .map { $0.items }
                    .asObservable()
                    .do(onSubscribe: {
                        loading.onNext(true)
                    }, onDispose: {
                        loading.onNext(false)
                    })
            }
            .retry()
            .startWith(self.stations)
            .observeOn(backgroundScheduler)
            .map { stations in stations.map { MapItem(station: $0) as MapItemType } }
            .share(replay: 1, scope: .forever)
        
        let moveToItem = input.moveToItemEvent
            .observeOn(backgroundScheduler)
            .flatMap { id -> Observable<MapItemType> in
                stations.flatMap { stations in
                    Observable.from(optional: stations.first(where: {$0.id == id}))
                    }.take(1)
            }
            .share(replay: 1, scope: .forever)
        
        let currentItem = Observable.merge(input.itemSelected, moveToItem)
            .distinctUntilChanged { lhs, rhs in lhs.id == rhs.id }
            .share(replay: 1, scope: .forever)
        
        let inititalRegion = stations.take(1)
            .map { stations -> MKMapRect in
                var points = stations.map { $0.coordinate }
                let rect: MKMapRect
                if let firstPoint = points.popLast() {
                    rect = MKMapRect(origin: MKMapPoint(firstPoint), size: .init(width: 0, height: 0))
                } else {
                    rect = .init(origin: .init(), size: .init())
                }
                return points.reduce(rect, { (rect, coordinate) -> MKMapRect in
                    rect.union(
                        MKMapRect(origin: MKMapPoint(coordinate), size: MKMapSize(width: 0, height: 0))
                    )
                })
            }
            .map { rect -> MKCoordinateRegion in
                return MKCoordinateRegion(rect)
            }
        
        return MapViewModel.Output(
            stations: stations.asDriver(onErrorJustReturn: []),
            moveToPoint: Observable.merge(
                inititalRegion,
                moveToItem.map { item in MKCoordinateRegion(center: item.coordinate, latitudinalMeters: 1000, longitudinalMeters: 1000) }
                ),
            addFavoriteAlert: input.itemDetailSelected,
            selectItem: Observable.combineLatest(stations, currentItem)
                .observeOn(backgroundScheduler)
                .flatMap { (stations, current) -> Observable<MapItemType> in
                    return Observable.from(optional: stations.first(where: { $0.id == current.id }))
                }
                .delay(2, scheduler: MainScheduler.instance)
                .share(replay: 1, scope: .forever),
            loading: loading.asObservable()
        )
    }
    
    init(stations: [UbikeStation]) {
        self.stations = stations
    }
}
