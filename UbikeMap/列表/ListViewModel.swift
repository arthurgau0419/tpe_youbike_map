//
//  ListViewModel.swift
//  UbikeMap
//
//  Created by Kao Ming-Hsiu on 2019/11/25.
//  Copyright © 2019 ObiCat. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import Moya

class ListViewModel: ViewModelType {
    
    typealias ListSection = (String, [ListItemType])
    
    let reloadStationProvider = MoyaProvider<UBikeService>()
    
    let stations: [UbikeStation]
    
    private let backgroundScheduler = ConcurrentDispatchQueueScheduler(qos: .background)
    
    struct Input {
        let isFavorite: Observable<Bool>
        let reloadEvent: Observable<Void>
        let itemSelected: Observable<IndexPath>
        let showMapTap: Observable<ListItemType>
    }
    
    struct Output {
        let stations: Driver<[ListSection]>
        let showMapItem: Observable<String>
        let showAlert: Observable<(ListItemType, IndexPath)>
    }
    
    func transform(input: ListViewModel.Input) -> ListViewModel.Output {
        
        let stations = Observable.combineLatest(
            input.isFavorite,
            input.reloadEvent
                .flatMap { [unowned self] _ in
                    self.reloadStationProvider.rx.request(.init())
                        .observeOn(self.backgroundScheduler)
                        .map(DynamicKeyContainer<UbikeStation>.self, atKeyPath: "retVal", using: UBikeService.decoder)
                        .map { $0.items }
                        .asObservable()
                }
                .retry()
                .startWith(self.stations)
                .map { stations in stations.map { ListItem(station: $0) as ListItemType } }
            )
            .observeOn(self.backgroundScheduler)
            .map { (isFavorite, items) in
                items.filter { item in item.我的最愛 || !isFavorite }
            }
            .map { stations -> [(String, [ListItemType])] in
                Dictionary(grouping: stations, by: { $0.場站區域 })
                    .map { $0 }
                    .sorted(by: { (lhs, rhs) -> Bool in
                        lhs.key > rhs.key
                    })
                    .map { (key, values) -> (String, [ListItemType]) in
                        (key, values.sorted(by: { (lhs, rhs) -> Bool in
                            lhs.場站名稱 > rhs.場站名稱
                        }))
                }
            }
            .share(replay: 1, scope: .forever)
        
        return Output(
            stations: stations.asDriver(onErrorJustReturn: []),
            showMapItem: input.showMapTap.map { $0.id },
            showAlert: input.itemSelected
                .observeOn(self.backgroundScheduler)
                .flatMap { indexPath -> Observable<(ListItemType, IndexPath)> in
                    stations.map {$0[indexPath.section].1[indexPath.row]}.map { ($0, indexPath) }.take(1)
            }
        )
    }
    
    init(stations: [UbikeStation]) {
        self.stations = stations
    }
}
