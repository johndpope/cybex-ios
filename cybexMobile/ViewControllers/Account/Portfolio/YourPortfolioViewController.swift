//
//  YourPortfolioViewController.swift
//  cybexMobile
//
//  Created DKM on 2018/5/16.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import ReSwift

class YourPortfolioViewController: BaseViewController {
  struct define {
    static let sectionHeaderHeight : CGFloat = 44.0
  }
  var data : [PortfolioData] = [PortfolioData]()
  
  var coordinator: (YourPortfolioCoordinatorProtocol & YourPortfolioStateManagerProtocol)?
  
  @IBOutlet weak var tableView: UITableView!
  override func viewDidLoad() {
    super.viewDidLoad()
    setupUI()
  }
  
  func setupUI(){
    self.localized_text = R.string.localizable.portfolioTitle.key.localizedContainer()
    let cell = String.init(describing: YourPortfolioCell.self)
    tableView.register(UINib.init(nibName: cell, bundle: nil), forCellReuseIdentifier: cell)
  }
  
  func commonObserveState() {
    coordinator?.subscribe(errorSubscriber) { sub in
      return sub.select { state in state.errorMessage }.skipRepeats({ (old, new) -> Bool in
        return false
      })
    }
    
    coordinator?.subscribe(loadingSubscriber) { sub in
      return sub.select { state in state.isLoading }.skipRepeats({ (old, new) -> Bool in
        return false
      })
    }
  }
  
  override func configureObserveState() {
    commonObserveState()
    
    UserManager.shared.balances.asObservable().skip(1).subscribe(onNext: {[weak self] (balances) in
      guard let `self` = self else { return }
      
      if let _ = UserManager.shared.balances.value{
        self.data = UserManager.shared.getPortfolioDatas()
      }
      self.tableView.reloadData()
    }, onError: nil, onCompleted: nil, onDisposed: nil).disposed(by: disposeBag)
    
    app_data.data.asObservable().distinctUntilChanged()
      .filter({$0.count == AssetConfiguration.shared.asset_ids.count})
      .subscribe(onNext: {[weak self] (s) in
        guard let `self` = self else { return }

        DispatchQueue.main.async {
          if let _ = UserManager.shared.balances.value{
            self.data = UserManager.shared.getPortfolioDatas()
          }
          self.tableView.reloadData()
        }
      }, onError: nil, onCompleted: nil, onDisposed: nil).disposed(by: disposeBag)
  }
  
}

extension YourPortfolioViewController : UITableViewDataSource,UITableViewDelegate{
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    
    return self.data.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: String.init(describing: YourPortfolioCell.self), for: indexPath) as! YourPortfolioCell
    
    cell.setup(self.data[indexPath.row], indexPath: indexPath)
    return cell
  }
  
  func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
    let lockupAssetsSectionView = LockupAssetsSectionView(frame: CGRect(x: 0, y: 0, width: self.view.width, height: define.sectionHeaderHeight))
    lockupAssetsSectionView.cybPriceTitle.locali = R.string.localizable.cyb_value.key.localized()
    return lockupAssetsSectionView
  }
  func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
    return define.sectionHeaderHeight
  }
}
