//SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.5.0 <0.9.0;

contract AuctionCreator{
    Auction[] public auctions;

    function createAuction() public{
        Auction newAuction = new Auction(msg.sender);
        auctions.push(newAuction);
    }
}


contract Auction {
    address payable public owner;
    uint256 public startblock;
    uint256 public endblock;
    string public ipfshash;

    enum State {
        Started,
        Running,
        Ended,
        Cancelled
    }
    State public auctionState;

    uint256 public highestbinding_bid;
    address payable public highestBidder;

    mapping(address => uint256) public bids;

    uint256 bidIncrement;

    receive() external payable{}

    constructor(address eoa) {
        owner = payable(eoa);
        auctionState = State.Running;
        startblock = block.number;
        endblock = startblock + 40320;
        ipfshash = "";
        bidIncrement = 100;
    }

    //modifer is used to have a common conditions at one place and use it whenever needed
    //used to remove redundent code
    modifier notOwner() {
        require(msg.sender != owner);
        _; //mandatory to end modifer with _;
    }

    modifier onlyOwner() {
        require(msg.sender == owner);
        _; //mandatory to end modifer with _;
    }

    modifier afterStart() {
        require(block.number >= startblock);
        _;
    }

    modifier beforeEnd() {
        require(block.number <= endblock);
        _;
    }

    function min(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a <= b) {
            return a;
        } else {
            return b;
        }
    }

    function cancelAuction() public onlyOwner{
        auctionState = State.Cancelled;
    }



    function placeBid() public payable notOwner afterStart beforeEnd {
        require(auctionState == State.Running);
        require(msg.value >= 0.01 ether);

        uint256 currentBid = bids[msg.sender] + msg.value;
        require(currentBid > highestbinding_bid);

        bids[msg.sender] = currentBid;
        if (currentBid <= bids[highestBidder]) {
            highestbinding_bid = min(
                currentBid + bidIncrement,
                bids[highestBidder]
            );
        } else {
            highestbinding_bid = min(
                currentBid,
                bids[highestBidder] + bidIncrement
            );
            highestBidder = payable(msg.sender);
        }
    }

    function finaliseAuction() public{
        require(auctionState == State.Cancelled || block.number > endblock);
        require(msg.sender == owner || bids[msg.sender] > 0);

        address payable recipient;
        uint value;

        if(auctionState == State.Cancelled) {
            recipient = payable(msg.sender);
            value = bids[msg.sender];
        } else { //auction ended
            if(msg.sender == owner) { //recipient is owner
                recipient = owner;
                value = highestbinding_bid;            
                } else{ 
                    //this is a bidder
                    if(msg.sender == highestBidder){
                        recipient = highestBidder;
                        value = bids[highestBidder] - highestbinding_bid;
                    } else {
                        //this is neither owner nor highestBidder
                        recipient = payable(msg.sender);
                        value = bids[msg.sender];
                    }
                }
        }
        //reset the bids of receipient
        bids[recipient] = 0;
        recipient.transfer(value);

    }

}
