//SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.5.0 <0.9.0;

contract SharedWallet {
    address public admin;
    // mapping to store the allowance value for each address
    mapping (address => uint256) public allowances;
    uint256 public spendingTime;
    
    constructor() {
        admin = msg.sender;
        spendingTime  = block.timestamp + 5;
    }

    // modifier to check if the caller is the admin
    modifier onlyAdmin() {
        require(msg.sender == admin);
        _;
    }

    // for the admin to load funds
    receive() external payable onlyAdmin{} 

    // function to check balance of the contract
    function getBalance() public view returns(uint){
        return address(this).balance;
    }

    // function to set the allowance for an address
    function setAllowance(address payable _address, uint _value) public onlyAdmin{
        require(_value < address(this).balance);
        allowances[_address] = _value;
    }
    
    // function to get the allowance of the calling address
    function getAllowance() public view returns(uint){
        return allowances[msg.sender];
    }

    // function to allow an address to get funds
    function getFunds(uint _value) public  {
        // checks if the spending time is not over
        require(block.timestamp < spendingTime, "TIME OVER");
        // checks if the calling address has a non-zero allowance
        require(allowances[msg.sender] > 0, "IMPOSTER");
        // checks if the requested amount is not more than the allowance
        require(_value <= allowances[msg.sender]);
        // get the balance of the contract
        uint getbal = getBalance();
        // checks if the contract has sufficient balance
        require(getbal >=allowances[msg.sender], "NO SUFFICIENT BALANCE");
        
        payable(msg.sender).transfer(_value);
        allowances[msg.sender] -= _value;

    }

    // function for the admin to get back the funds
    function getback() public onlyAdmin{
        require(block.timestamp > spendingTime);
        // transfers the balance of the contract to the admin
        payable(admin).transfer(address(this).balance);
    }

    
}
