//
//  GameModel.swift
//  cybexMobile
//
//  Created by DKM on 2018/12/7.
//  Copyright © 2018 Cybex. All rights reserved.
//

import Foundation
import JavaScriptCore
import SwiftyJSON
import cybex_ios_core_cpp
import PromiseKit

@objc protocol GameDelegate: JSExport {
    func login() -> String
    
    func redirected(_ url: String)
    func collect(_ account: String ,_ amount: String, _ asset: String, _ fee: String, _ feeAsset: String)
}

class GameModel: NSObject, GameDelegate {
    
    var context: JSContext?
    
    func login() -> String {
        if !UserManager.shared.isLocked {
            guard let accountName = UserManager.shared.name.value, let balances = UserManager.shared.balances.value else { return ""}
            var usdtAmount: Decimal = 0
            var cybAmount: Decimal = 0
            if let balance = balances.filter({ return $0.assetType == AssetConfiguration.USDT}).first,
                let usdtInfo = appData.assetInfo[balance.assetType] {
                usdtAmount = balance.balance.decimal() / pow(10, usdtInfo.precision)
            }
            if let cybBalance = balances.filter({ return $0.assetType == AssetConfiguration.CYB }).first,
                let cybInfo = appData.assetInfo[cybBalance.assetType] {
                cybAmount = cybBalance.balance.decimal() / pow(10, cybInfo.precision)
            }
            let expiration = Date().timeIntervalSince1970 + AppConfiguration.TransactionExpiration
            let signer = BitShareCoordinator.getRecodeLoginOperation(accountName,
                                                                     asset: "",
                                                                     fundType: "",
                                                                     size: Int32(0),
                                                                     offset: Int32(0),
                                                                     expiration: Int32(expiration))!
            let a = ["op": [
                "accountName": accountName,
                "expiration": Int32(expiration)
                ],
                     "signer": JSON(parseJSON: signer)["signer"].stringValue,
                     "balance": usdtAmount.stringValue,
                     "fee_balance": cybAmount.stringValue] as [String : Any]
            return JSON(a).rawString() ?? ""
        }
        
        NotificationCenter.default.post(name: NSNotification.Name.init("lockAccount"), object: nil)
        return ""
    }
    
    func redirected(_ url: String) {
        NotificationCenter.default.post(name: NSNotification.Name.init("openURL"), object: ["url": url])
    }
    
    func collect(_ account: String ,_ amount: String, _ asset: String, _ fee: String, _ feeAsset: String) {
        let toAccount = account
        UserManager.shared.checkUserName(toAccount).done({[weak self] (exist) in
            main {
                if exist {
                    let requeset = GetFullAccountsRequest(name: toAccount) { (response) in
                        if let data = response as? FullAccount, let account = data.account {
                            getChainId { (id) in
                                let assetId = asset
                                let feeAmount = fee.decimal()
                                let feeAssetId = feeAsset
                                let requeset = GetObjectsRequest(ids: [ObjectID.dynamicGlobalPropertyObject.rawValue.snakeCased()]) { (infos) in
                                    if let infos = infos as? (block_id: String, block_num: String) {
                                        let amountDecimal = amount.decimal()
                                        guard let fromAccount = UserManager.shared.account.value else { return }
                                        let feeAmout = feeAmount
                                        let jsonstr =  BitShareCoordinator.getTransaction(Int32(infos.block_num)!,
                                                                                          block_id: infos.block_id,
                                                                                          expiration: Date().timeIntervalSince1970 + AppConfiguration.TransactionExpiration,
                                                                                          chain_id: id,
                                                                                          from_user_id: Int32(getUserId(fromAccount.id)),
                                                                                          to_user_id: Int32(getUserId(account.id)),
                                                                                          asset_id: Int32(getUserId(assetId)),
                                                                                          receive_asset_id: Int32(getUserId(assetId)),
                                                                                          amount: amountDecimal.int64Value,
                                                                                          fee_id: Int32(getUserId(feeAssetId)),
                                                                                          fee_amount: feeAmout.int64Value,
                                                                                          memo: "",
                                                                                          from_memo_key: fromAccount.memoKey,
                                                                                          to_memo_key: account.memoKey)
                                        
                                        let withdrawRequest = BroadcastTransactionRequest(response: { [weak self](data) in
                                            guard let `self` = self, let context = self.context else { return }
                                            main {
                                                context.objectForKeyedSubscript("collectCallback")?.call(withArguments: [String(describing: data) == "<null>" ? "0" : "1"])
                                            }
                                            }, jsonstr: jsonstr!)
                                        CybexWebSocketService.shared.send(request: withdrawRequest)
                                    }
                                }
                                CybexWebSocketService.shared.send(request: requeset)
                            }
                        }
                        else {
                            self?.context?.objectForKeyedSubscript("collectCallback")?.call(withArguments: ["2"])
                        }
                    }
                    CybexWebSocketService.shared.send(request: requeset)
                }
                else {
                    self?.context?.objectForKeyedSubscript("collectCallback")?.call(withArguments: ["2"])
                }
            }
        }).cauterize()
    }
}
