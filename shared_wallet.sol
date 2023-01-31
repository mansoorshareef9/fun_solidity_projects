//SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.5.0 <0.9.0;

contract SharedWallet {
    address public admin;
    mapping (address => uint256) public allowances;
    uint256 public spendingTime;

    constructor() {
        admin = msg.sender;
        spendingTime  = block.timestamp + 5;
    }

    modifier onlyAdmin() {
        require(msg.sender == admin);
        _;
    }

    receive() external payable onlyAdmin{}

    function getBalance() public view returns(uint){
        return address(this).balance;
    }

    function setAllowance(address payable _address, uint _value) public onlyAdmin{
        require(_value < address(this).balance);
        allowances[_address] = _value;
    }
    
    function getAllowance() public view returns(uint){
        return allowances[msg.sender];
    }

    function getFunds(uint _value) public  {
        require(block.timestamp < spendingTime, "TIME OVER");
        require(allowances[msg.sender] > 0, "IMPOSTER");
        require(_value <= allowances[msg.sender]);
        uint getbal = getBalance();
        require(getbal >=allowances[msg.sender], "NO SUFFICIENT BALANCE");
        
        payable(msg.sender).transfer(_value);
        allowances[msg.sender] -= _value;

    }

    function getback() public onlyAdmin{
        require(block.timestamp > spendingTime);
        payable(admin).transfer(address(this).balance);
    }

    
}
