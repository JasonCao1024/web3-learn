// SPDX-License-Identifier:MIT
pragma solidity ^0.8.20;

contract HelloWorld {

    /*
    1.storage
    2.memory
    4.calldata
    */

    struct Info {
        string phrase;
        uint256 id;
        address addr;
    }
    Info[] infos;
    mapping(uint256 => Info) infoMapping;
    string strVar = "Hello World";

    function sayHello(uint256 _id) public view returns (string memory) {
        Info memory info = infoMapping[_id];
        if (info.addr == address(0x0)) {
            return addInfo(strVar);
        } else {
            return addInfo(info.phrase);
        }
    }

    function setHelloWorld(string memory newString, uint256 _id) public {
        strVar = newString;
        Info memory info = Info(newString, _id, msg.sender);
        infoMapping[_id] = info;
    }

    function addInfo(string memory str) internal pure returns (string memory) {
        return string.concat(str, " from Jason's contract.");
    }
}
