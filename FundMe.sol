// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";

//1.创建一个收款函数
//2.记录投资人并且查看
//3.在锁定期达到目标值，生产商可以提款
//4.在锁定期没有达到目标值，投资人在锁定期以后可以退款
contract FundMe {
    mapping(address => uint256) public funderToAmount;

    uint256 constant MINIMUN_VALUE = 10 * 10**18; //wei

    AggregatorV3Interface internal dataFeed;

    uint256 constant TARGET = 20 * 10**18;

    address owner;

    constructor() {
        // Sepolia test
        dataFeed = AggregatorV3Interface(
            0x694AA1769357215DE4FAC081bf1f309aDC325306
        );

        owner = msg.sender;
    }

    function fund() external payable {
        require(
            convertEthToUsd(msg.value) >= MINIMUN_VALUE,
            "You don't have enough money"
        );
        funderToAmount[msg.sender] = msg.value;
    }

    /**
     * Returns the latest answer.
     */
    function getChainlinkDataFeedLatestAnswer() public view returns (int256) {
        // prettier-ignore
        (
            /* uint80 roundID */,
            int answer,
            /*uint startedAt*/,
            /*uint timeStamp*/,
            /*uint80 answeredInRound*/
        ) = dataFeed.latestRoundData();
        return answer;
    }

    function convertEthToUsd(uint256 ethAmount)
        internal
        view
        returns (uint256)
    {
        uint256 ethPrice = uint256(getChainlinkDataFeedLatestAnswer());
        return (ethAmount * ethPrice) / (10**8);
    }

    function getFund() external {
        require(
            convertEthToUsd(address(this).balance) >= TARGET,
            "Target is not reached!"
        );
        require(
            msg.sender == owner,
            "this function can only be called by owner "
        );
        // transfer: transfer ETH and revert if tx failed
        // payable(msg.sender).transfer(address(this).balance);
        //send: transfer ETH and return false if failed
        // bool success = payable(msg.sender).send(address(this).balance);
        //call: transfer ETH with data retrun value of function and bool
        bool success;
        (success, ) = payable(msg.sender).call{value: address(this).balance}(
            ""
        );
    }

    function transferOwnership(address newOwner) public {
        require(
            msg.sender == owner,
            "this function can only be called by owner "
        );
        owner = newOwner;
    }

    function reFund() external {
        require(
            convertEthToUsd(address(this).balance) < TARGET,
            "Target is reached"
        );
        require(funderToAmount[msg.sender] != 0, "there is no fund for you ");
        bool success;
        (success, ) = payable(msg.sender).call{
            value: funderToAmount[msg.sender]
        }("");
        require(success, "transfer tx failed");
    }
}
