pragma solidity ^0.4.18;

import "./CopyRightContract.sol";


contract CRCRegister {
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
    注册新的文件hash和价格
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

        Register(msg.sender, authorName, price, crc);
        return crc;
    }

    function updateContractInfo(
        address crContract, 
        string title, 
        string description, 
        string keywords, 
        string previewFileHash) {
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
        address[] contracts = authorContracts[author];

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