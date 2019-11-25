//
//  ListViewController.swift
//  UbikeMap
//
//  Created by Kao Ming-Hsiu on 2019/11/25.
//  Copyright © 2019 ObiCat. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources

class ListViewController: UIViewController {
    
    typealias ViewModel = ListViewModel
    
    var viewModel: ViewModel!
    
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    
    @IBOutlet weak var reloadButton: UIBarButtonItem!
    
    @IBOutlet weak var tableView: UITableView!
    
    let disposeBag = DisposeBag()
    private let showMapAction = PublishSubject<ListItemType>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.estimatedRowHeight = 88.0
        self.tableView.rowHeight = UITableView.automaticDimension
        
        mvvmViewDidload()
    }
}

extension ListViewController: MVVM {
    
    func provideInput() -> ListViewController.ViewModel.Input {
        return ViewModel.Input(
            isFavorite: segmentedControl.rx.selectedSegmentIndex
                .map { $0 == 1}
                .asObservable(),
            reloadEvent: Observable.merge(
                reloadButton.rx.tap.asObservable(),
                rx.methodInvoked(#selector(viewWillAppear(_:))).map { _ in Void()}
            ),
            itemSelected: tableView.rx.itemSelected.asObservable(),
            showMapTap: showMapAction.asObservable()
        )
    }
    
    func bindingOutput(_ output: ListViewModel.Output) {
                
        let dataSource = RxTableViewSectionedReloadDataSource<SectionModel<String, ListItemType>>(configureCell: { (_, tableView, indexPath, item) -> UITableViewCell in
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "ListItemCell", for: indexPath) as? ListItemCell else { return UITableViewCell() }
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .short
            dateFormatter.timeStyle = .short
            
            cell.場站名稱.text = item.場站名稱.appending(item.我的最愛 ? "❤️" : "")
            cell.場站總停車格.text = "\(item.場站總停車格) 個"
            cell.場站目前車輛數量.text = "\(item.場站目前車輛數量) 個"
            cell.空位數量.text = "\(item.空位數量) 個"
            cell.地址.text = item.地址
            cell.資料更新時間.text = dateFormatter.string(from: item.資料更新時間)
            
            return cell
        }, titleForHeaderInSection: { (dataSource, section) -> String? in
            dataSource.sectionModels[section].identity
        }, sectionIndexTitles: { (dataSource) -> [String]? in
            return dataSource.sectionModels.map { String($0.identity.dropLast()) }
        })
        
        output.stations
            .map { groups -> [SectionModel<String, ListItemType>] in groups.map { SectionModel(model: $0.0, items: $0.1) } }
            .drive(tableView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
        
        output.showMapItem
            .map { (navigator, $0) }
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { (navigator, id) in
                navigator.open("select_map_item", context: id)
            })
            .disposed(by: disposeBag)
        
        output.showAlert
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { (item, indexPath) in
                var item = item
                let alc = UIAlertController(
                    title: item.場站名稱.appending(item.我的最愛 ? "(❤️)": ""),
                    message: "請選擇一個動作",
                    preferredStyle: .alert
                )
                alc.addAction(.init(title: item.我的最愛 ? "移除最愛": "加入最愛", style: item.我的最愛 ? .destructive: .default, handler: { [weak self] (_) in
                    item.我的最愛 = !item.我的最愛
                    self?.tableView.reloadRows(at: [indexPath], with: .none)
                }))
                alc.addAction(.init(title: "前往地圖", style: .default, handler: { [weak self] (_) in
                    self?.showMapAction.onNext(item)
                }))
                alc.addAction(.init(title: "取消", style: .cancel, handler: nil))
                navigator.present(alc)
            })
            .disposed(by: disposeBag)
        
        
    }
    
}

extension ListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}
