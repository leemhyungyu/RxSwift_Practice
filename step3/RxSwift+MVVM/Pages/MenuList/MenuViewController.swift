//
//  ViewController.swift
//  RxSwift+MVVM
//
//  Created by iamchiwon on 05/08/2019.
//  Copyright © 2019 iamchiwon. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class MenuViewController: UIViewController {
    // MARK: - Life Cycle

    let cellId = "MenuItemTableViewCell"

    
    let viewModel = MenuListViewModel()
    var disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        // item: 메뉴 하나
        // index: indexPath.row
        // cell: cellType
        
        viewModel.menuObservable
            .bind(to: tableView.rx.items(cellIdentifier: cellId, cellType: MenuItemTableViewCell.self)) { index, item, cell in
                cell.title.text = item.name
                cell.price.text = "\(item.price)"
                cell.count.text = "\(item.count)"
                
                cell.onChange = { [weak self] increase in
                    print("onChange")
                    self?.viewModel.changeCount(item: item, increase: increase)
                }
                
            }
            .disposed(by: disposeBag)
        
        /*
         
         UI에 대한 작업 특징
         - 항상 UI 쓰레드에서만 처리 (메인 쓰레드) -> .observeOn(MainScheduler.instance)
         - 에러가 발생할떄의 처리 -> .catchErrorJustReturn("")
         - 위의 두 개의 역할을 동시에 하는것이 .asDriver()임
         - Driver을 사용할 때는 데이터 전달을 drive()로 하면된다.
         
         */
        
        viewModel.itemsCount
            .map { "\($0)" }
            .asDriver(onErrorJustReturn: "")
//            .catchErrorJustReturn("")
//            .observeOn(MainScheduler.instance)
//            .bind(to: itemCountLabel.rx.text)
            .drive(itemCountLabel.rx.text)
            .disposed(by: disposeBag)
        
        // bind 사용 -> 순환참조 없이 subscribe의 onNext 사용 가능
        
        viewModel.totalPrice
            .map { $0.currencyKR() }
            .observeOn(MainScheduler.instance)
            .bind(to: totalPrice.rx.text)
            .disposed(by: disposeBag)
        
//        viewModel.totalPrice
//            .map { $0.currencyKR() }
//            .subscribe(onNext: { [weak self] in
//                self?.totalPrice.text = $0
//            })
//            .disposed(by: disposeBag)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let identifier = segue.identifier ?? ""
        if identifier == "OrderViewController",
            let orderVC = segue.destination as? OrderViewController {
            // TODO: pass selected menus
        }
    }

    func showAlert(_ title: String, _ message: String) {
        let alertVC = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertVC.addAction(UIAlertAction(title: "OK", style: .default))
        present(alertVC, animated: true, completion: nil)
    }

    // MARK: - InterfaceBuilder Links

    @IBOutlet var activityIndicator: UIActivityIndicatorView!
    @IBOutlet var tableView: UITableView!
    @IBOutlet var itemCountLabel: UILabel!
    @IBOutlet var totalPrice: UILabel!

    @IBAction func onClear() {
        
        viewModel.clearAllItemSelctions()
    }

    @IBAction func onOrder(_ sender: UIButton) {
        // TODO: no selection
        // showAlert("Order Fail", "No Orders")
//        performSegue(withIdentifier: "OrderViewController", sender: nil)
       
        viewModel.onOrder()
       
    }
}

//extension MenuViewController: UITableViewDataSource {
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return viewModel.menus.count
//    }
//
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let cell = tableView.dequeueReusableCell(withIdentifier: "MenuItemTableViewCell") as! MenuItemTableViewCell
//
//        let menu = viewModel.menus[indexPath.row]
//
//
//
//        return cell
//    }
//}
