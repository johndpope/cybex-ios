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
      self.tableView.reloadData()
    }, onError: nil, onCompleted: nil, onDisposed: nil)
  }
}

extension YourPortfolioViewController : UITableViewDataSource,UITableViewDelegate{
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    guard let data = UserManager.shared.balances.value else {
      return 0
    }
    return data.count
  }
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: String.init(describing: YourPortfolioCell.self), for: indexPath) as! YourPortfolioCell
    let data = UserManager.shared.balances.value
    cell.setup(data?[indexPath.row], indexPath: indexPath)
    return cell
  }
}
