# ChainStock - 基于Ethereum和IPFS的去中心化版权交易平台

## 测试地址
- rinkeby: 0xee8e8dF50AB292475FCa8b751eD2F580Ba1f259A
- 访问方法参考 [demo link](https://phxwang.github.io/chainstock/demo.html)([demo source ](https://github.com/phxwang/chainstock/blob/master/docs/demo.html))
- 多IPFS网关访问：[ipfs.io](https://ipfs.io/ipfs/QmajKNF3bmTMhgjNhy8kZsuFRfZT5YFigZQMCpgju5pMZ5), [ipfs.infura.io](https://ipfs.infura.io/ipfs/QmajKNF3bmTMhgjNhy8kZsuFRfZT5YFigZQMCpgju5pMZ5), [eternum.io](https://www.eternum.io/ipfs/QmajKNF3bmTMhgjNhy8kZsuFRfZT5YFigZQMCpgju5pMZ5)

## 基础技术
* IPFS：存储图片
  * ~~用infura做网关：https://ipfs.infura.io/~~
  * ~~[api docs](https://github.com/ipfs/js-ipfs-api)(TODO: 调用会失败，待解决）~~
  * 使用[js-ipfs](https://github.com/ipfs/js-ipfs) （不是太稳定。。。，可能是因为墙的原因）
* Ethereum：处理交易，保存交易记录，支持简单的查询
  * 通过MetaMask调用网关([api docs](https://github.com/MetaMask/faq/blob/master/DEVELOPERS.md))
## 特色概念
 - 去中心化交易
   - 交易透明，不存在各种黑箱
   - 实时结算，供应方获得收益无延迟
   - 无中间商，降低交易成本，供应方获得更多收益，购买方获得更低价格
   - 版权清晰，购买方在购买后即可实时进行版权校验，供应方获得第一手授权信息
 - 去中心化存储/服务
   - 可以通过任意IPFS网关访问主页hash，永不宕机
   - 所有文件永久保存在IPFS上，通过任意IPFS网关可以获取，永不丢失
  
## 基本功能
### 上传
* 图片传到IPFS上，然后把fileHash传到Ethereum上注册版权
* 计算图片的去重hash并进行注册，防止重复上传（维权的算法）(TODO)
### 购买
* 输入文件合约地址和授权人姓名，购买后得到IPFS的fileHash
* 购买的费用10%进入register用于支持维护费用，及作为未来发token的准备金
### 版权查询
* 输入contractaddress和买家名称（地址），返回是否有记录
### 下载
* 输入通过购买得到的fileHash，通过IPFS的hash下载文件
### 自有token (TODO)
* 上传文件可以获得token
* 购买文件可以使用token或者ether
* token可以通过第三方交易所买入或卖出
### 搜索 (TODO)
* 需要一个中心化的服务器来进行搜索

## 模块设计
* 参考ENS的思路，把注册和版权合约分为两个模块
### CRCRegister 
* register(fileHash, previewFileHash, authorName, price) return fileContract
* list(from, length) return list[(contractAddress, previewFileHash)]
* listByAuthor(from, length) return list[(contractAddress, previewFileHash)]

### CopyRightContract
* CopyRightContract(fileHash, previewFileHash, authorAddress, authorName, price, title, description)
* buy(buyerName) return fileHash
* verifyBuyerName(buyerName)
* verifyBuyerAddress(buyerAddress)

## ChangeLog
- 2018-2-24 完成alpha0

## TODO
### alpha1
- 做一个好看的界面;解决ipfs的稳定性问题
### future
- 优化接口设计，减少tansaction的连续调用次数（一次要1分钟，太慢了）
- 发一个自有token，支持支付
