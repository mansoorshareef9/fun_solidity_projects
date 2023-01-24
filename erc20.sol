// ERC - ethereum request for comments
// EIP - ethereum improvement proposal


//SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.5.0 <0.9.0;
// EIP-20: ERC-20 Token Standard
// https://eips.ethereum.org/EIPS/eip-20
// -----------------------------------------
 
interface ERC20Interface {
    //mandatory ones are first 3
    function totalSupply() external view returns (uint);
    function balanceOf(address tokenOwner) external view returns (uint balance);
    function transfer(address to, uint tokens) external returns (bool success);
    
    function allowance(address tokenOwner, address spender) external view returns (uint remaining);
    function approve(address spender, uint tokens) external returns (bool success);
    function transferFrom(address from, address to, uint tokens) external returns (bool success);
    
    event Transfer(address indexed from, address indexed to, uint tokens);
    event Approval(address indexed tokenOwner, address indexed spender, uint tokens);
}

contract Cryptos is ERC20Interface {

    
    string public name = "zombie";
    string public symbol = "ZOMB";
    uint public decimans = 18; //18 the most used value
    uint public override totalSupply;

    address public founder;
    mapping(address => uint ) public balences;
    //balences[address] 

    mapping(address => mapping(address => uint)) allowed; //first address is owner, second address is mostly contract uint is token count
    //a (owner) b(spender) == 100 tokens
    //allowed[a][b] = 100;

    constructor(){
        totalSupply = 1000000;
        founder = msg.sender;
        balences[founder] = totalSupply;
    }

    function balanceOf(address tokenOwner) public view override returns (uint balance){
        return balences[tokenOwner];
    }

    function transfer(address to, uint tokens) public override returns (bool success){
        require(balences[msg.sender] >= tokens);

        balences[to] += tokens;
        balences[msg.sender] -= tokens;

        emit Transfer(msg.sender, to, tokens);   
        return true;     
    }

    function allowance(address tokenOwner, address spender) view public override returns(uint){
        return allowed[tokenOwner][spender];
    }

    function approve(address spender, uint tokens) public override returns (bool success){
        require(balences[msg.sender] >= tokens);
        require(tokens > 0);

        allowed[msg.sender] [spender] = tokens;
        emit Approval(msg.sender, spender, tokens);
        return true;
    }

    function transferFrom(address from, address to, uint tokens) external override returns (bool success){
        require(allowed[from][msg.sender] >= tokens);
        require(balences[from] >= tokens);

        balences[from] -= tokens;
        allowed[from][msg.sender] -= tokens; //allowance reduced after transfer
        balences[to] += tokens;
        emit  Transfer(from, to, tokens);

        return true;

    }



    




}