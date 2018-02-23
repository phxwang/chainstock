pragma solidity ^0.4.18;

contract owned {
    address public owner;

    function owned() public {
        owner = msg.sender;
    }

    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }

    function transferOwnership(address newOwner) onlyOwner public {
        owner = newOwner;
    }
}

contract CopyRightContract is owned {
    string public authorName;
    address public author;
    string fileHash;
    string public previewFileHash;
    uint256 public price;
    string public title;
    string public description;
    string public keywords;
    
    mapping (address => uint256) private buyerAddresses;
    mapping (string => bool) private buyerNames;

    event Buy(address indexed buyerAddress, string  buyerName, uint256 price);
    event Transfer(address indexed to, uint256 amount);
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
        Buy(msg.sender, buyerName, msg.value);
        
        //9:1分成，作者拿9
        uint256 authorIncome = uint256(msg.value*9/10);
        uint256 ownerIncome = msg.value - authorIncome;
        
        //转账给作者
        author.transfer(authorIncome);
        Transfer(author, authorIncome);
        
        //转账给合约创建者（平台）
        owner.transfer(ownerIncome);
        Transfer(owner, ownerIncome);

        return _fileHash;
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