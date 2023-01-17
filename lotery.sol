//SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.5.0 <0.9.0;

contract Lottery {
    //state variables
    address payable[] public players;
    address public manager;

    constructor() {
        manager = msg.sender;
        players.push(payable(manager));
    }

    receive() external payable {
        //to receive eth
        require(msg.sender != manager, "Manager can not participate");
        require(msg.value == 1 ether, "min amount is 0.1ETH");
        players.push(payable(msg.sender)); //adding it to players array and also declaring eth sent addresses as payable because we need to send eth to them later on
    }

    function getBalance() public view returns (uint256) {
        require(msg.sender == manager, "you are not a MANAGER");
        return address(this).balance;
    }

    function random() public view returns (uint256) {
        //generate random number, do not use in real scenario, to generate random check chainlink docs.
        return
            uint256(
                keccak256(
                    abi.encodePacked(
                        block.difficulty,
                        block.timestamp,
                        players.length
                    )
                )
            );
    }

    function pickWinner() public {
        require(msg.sender == manager, "YOU ARE NOT A MANAGER");
        require(players.length >= 3);

        uint256 r = random();
        address payable winner;
        uint256 index = r % players.length;
        winner = players[index];
        payable(manager).transfer(getBalance() / uint256(10)); //manager gets 10% of total amount
        winner.transfer(getBalance());
        players = new address payable[](0); //resetting the lottery after sending funds to first round winner.
    }
}
