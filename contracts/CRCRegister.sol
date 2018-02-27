pragma solidity ^0.4.18;

import "./owned.sol";
import "./CopyRightContract.sol";
import "./ChainStockToken.sol";
import "./SafeMath.sol";

contract CRCTokenReserve is owned{
    //token address
    address public tokenAddress;
    
    event SetTokenAddress(address tokenAddress);
    event AwardToken(address author, uint256 tokenAwarded, uint256 reservedTokenAmount, uint256 totalSupply);
    event Buy(address buyer, uint256 value, uint256 tokenAmount, uint256 buyPrice, address tokenAddress);
    event Sell(address seller, uint256 tokenAmount, uint256 value, uint256 sellPrice, address tokenAddress);
    event GetPrice(uint256 total, uint256 reservedToken, uint256 reservedEth, uint256 marketToken, uint256 price);

    //返回的price是每CST的Wei价格
    function getPrice() public returns(uint256 price) {
        ChainStockToken cst = ChainStockToken(tokenAddress);
        uint256 totalSupply = cst.totalSupply();
        uint256 tokenBalance = cst.balanceOf(this);
        assert(totalSupply - tokenBalance > 0);
        price = uint256(this.balance * 10**18 * 20 / (totalSupply - tokenBalance));
        GetPrice(totalSupply, tokenBalance, this.balance, totalSupply - tokenBalance ,price);
        return price;
    }

    //买入token，价格等于ethbalance*20/tokenCount
    function buy() payable public {
        ChainStockToken cst = ChainStockToken(tokenAddress);
        
        uint256 buyPrice = getPrice();
        uint256 amount = uint256(msg.value * 10**18 / buyPrice);            // calculates the amount

        cst.transfer(msg.sender, amount);              // makes the transfers
        Buy(msg.sender, msg.value, amount, buyPrice, tokenAddress);
    }

    //卖出token
    //TODO: 需要有每个人的兑付限制，防止恶意挤兑
    function receiveApproval(address _from, uint256 _amount, address _token, bytes _extraData) public {
        require(tokenAddress == _token);

        ChainStockToken cst = ChainStockToken(tokenAddress);
        uint256 sellPrice = getPrice();
        uint256 value = _amount * sellPrice / 10**18;            // calculates the amount

        assert(cst.balanceOf(_from) >= _amount);
        assert(cst.allowance(_from, this) >= _amount);
        assert(this.balance >= value);

        cst.transferFrom(_from, this, _amount);              // makes the transfers
        _from.transfer(value);
        Sell(_from, _amount, value, sellPrice, tokenAddress);
    }

    //奖励token，单位是CST
    function awardToken(address _author, uint256 tokenCount) internal{
        //上传一个文件发一个token
        ChainStockToken cst = ChainStockToken(tokenAddress);
        uint256 tokenAwarded = tokenCount * 10 ** uint256(cst.decimals());
        assert(cst.balanceOf(this) >= tokenAwarded);
        cst.transfer(msg.sender, tokenAwarded);
        AwardToken(_author, tokenAwarded, cst.balanceOf(this), cst.totalSupply());
    }

    function setTokenAddress(address _tokenAddress) public onlyOwner{
        tokenAddress = _tokenAddress;
        SetTokenAddress(tokenAddress);
    }
}

contract CRCRegister is owned, CRCTokenReserve{
    //all contracts
    address[] public fileContracts;
    //contract => author
    mapping(address => address) public contractAuthor;
    //author => contracts[]
    mapping(address => address[]) public authorContracts;
    

    event Register(address indexed author, string authorName, uint256 price, address indexed crContract);
    event Paied(address from, uint256 amount);
    event UpdateContractInfo(address indexed crContract, string title, string description, string keywords, string previewFileHash);
    
    function CopyRightContractRegister() public {
        //fileContracts = new address[](0);
    }

    /*
    注册新的文件hash和价格(ETH)
    TODO:针对fileHash去重
    */
    function register(
        string fileHash, 
        string authorName, 
        uint256 price) 
        public returns(address _fileContract){
        address crc = address(new CopyRightContract(fileHash, msg.sender, authorName, price));

        fileContracts.push(crc);
        contractAuthor[crc] = msg.sender; 

        authorContracts[msg.sender].push(crc);

        awardToken(msg.sender, 1);
        Register(msg.sender, authorName, price, crc);
        return crc;
    }

    function updateContractInfo (
        address crContract, 
        string title, 
        string description, 
        string keywords, 
        string previewFileHash) public{
        require(msg.sender == contractAuthor[crContract]);
        CopyRightContract crc = CopyRightContract(crContract);
        crc.setMetaInfo(title, description,keywords, previewFileHash);
        UpdateContractInfo(crContract,title,description,keywords,previewFileHash);
    }

    /*
    获得版权合约的列表，不超过20条
    */
    function list(uint256 start, uint256 length, bool reverse) constant public 
        returns(address[] _fileContracts) {
        require(start >= 0 && start < fileContracts.length);
        require(length >=0 && length <= 20);
        if(length > fileContracts.length - start) length = fileContracts.length - start;

        address[] memory results =  new address[](length);
        for(uint256 i=0; i<length; i=i+1) {
            uint256 index = start + i;
            if(reverse) {
                index = fileContracts.length - index - 1;
            }
            results[i] = fileContracts[index];
        }
        return results;
    }

    /*
    获得某个作者的版权合约列表，不超过20条
    */
    function listByAuthor(address author, uint256 start, uint256 length) constant public 
        returns(address[] _fileContracts) {
        address[] memory contracts = authorContracts[author];

        require(start >= 0 && start < contracts.length);
        require(length >=0 && length <= 20);
        if(length > contracts.length - start) length = contracts.length - start;

        address[] memory results =  new address[](length);
        for(uint8 i=0; i<length; i=i+1) {
            results[i] = contracts[start+i];
        }
        return results;
    }

    function() payable public {
        Paied(msg.sender, msg.value);
    }
}