pragma solidity ^0.4.18;

import "./owned.sol";
import "./CRCRegister.sol";
import "./ChainStockToken.sol";

contract CopyRightContract is owned, tokenRecipient {
    string public authorName;
    address public author;
    string fileHash;
    string public previewFileHash;
    uint256 public price; //以ETH Wei定价
    string public title;
    string public description;
    string public keywords;
    
    mapping (address => uint256) private buyerAddresses;
    mapping (string => bool) private buyerNames;

    event Buy(address indexed buyerAddress, string  buyerName, uint256 price, string fileHash);
    event BuyWithToken(address indexed buyerAddress, string  buyerName, uint256 tokenAmount, uint256 tokenPrice, uint256 ethAmount, uint256 price, uint discountPrice, string fileHash);
    event Transfer(address indexed buyerAddress, address indexed to, uint256 amount);
    event TransferToken(address indexed buyerAddress, address indexed to, uint256 amount);
    event GetFile(address indexed buyerAddress, string fileHash);

    function CopyRightContract(
        string _fileHash,
        address _authorAddress,
        string _authorName,
        uint _price
        ) public {
        fileHash = _fileHash;
        author = _authorAddress;
        authorName = _authorName;
        price = _price;
    }

    function setMetaInfo(
        string _title, 
        string  _description, 
        string _keywords, 
        string _previewFileHash) 
        public onlyOwner{
        title = _title;
        description = _description;
        keywords = _keywords;
        previewFileHash = _previewFileHash;
    }

    function setAuthor(address _authorAddress) public onlyOwner{
        author = _authorAddress;
    }

    
    function buy(string buyerName) payable public returns(string _fileHash) {
        require(msg.value >= price);
        buyerAddresses[msg.sender] = msg.value;
        buyerNames[buyerName] = true;
        Buy(msg.sender, buyerName, msg.value, fileHash);
        
        //9:1分成，作者拿9
        uint256 authorIncome = uint256(msg.value*9/10);
        uint256 ownerIncome = msg.value - authorIncome;
        
        //转账给作者
        author.transfer(authorIncome);
        Transfer(msg.sender, author, authorIncome);
        
        //转账给合约创建者（平台）
        owner.transfer(ownerIncome);
        Transfer(msg.sender, owner, ownerIncome);

        return fileHash;
    }

    function receiveApproval(address _from, uint256 _value, address _token, bytes _extraData) public {
        //查找token地址
        CRCRegister register = CRCRegister(owner);
        address tokenAddress = register.tokenAddress();
        assert(tokenAddress == _token);

        ChainStockToken cst = ChainStockToken(tokenAddress);
        
        //查询token汇率
        uint256 tokenPrice = register.getPrice();
        uint256 ethValue = uint256(_value * tokenPrice/10**18);
        uint256 discountPrice = price*9/10;
        //用token买打九折
        assert(ethValue >= discountPrice);

        //9:1分成，作者拿9
        uint256 authorIncome = uint256(_value*9/10);
        uint256 ownerIncome = _value - authorIncome;

        assert(cst.balanceOf(_from) >= _value);
        
        //转账给作者
        cst.transferFrom(_from, author, authorIncome);
        TransferToken(_from, author, authorIncome);
        
        //转账给合约创建者（平台）
        cst.transferFrom(_from, owner, ownerIncome);
        TransferToken(_from, owner, ownerIncome);

        buyerAddresses[_from] = ethValue;
        string memory buyerName = string(_extraData);
        buyerNames[buyerName] = true;
        BuyWithToken(_from, buyerName, _value, tokenPrice, ethValue, price, discountPrice, fileHash);
    }
    
    function getFile() public returns(string _fileHash) {
        require(buyerAddresses[msg.sender] != 0);
        GetFile(msg.sender, fileHash);
        return fileHash;
    }
    
    function verifyBuyerName(string _buyerName) public constant returns(bool verified){
        return buyerNames[_buyerName];
    }
    
    function verifyBuyerAddress(address _buyerAddress) public constant returns(bool verified){
        return buyerAddresses[_buyerAddress] != 0;
    }
}