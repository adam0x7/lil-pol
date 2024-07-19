// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

contract Berachef is OwnableUpgradeable {

    struct CuttingBoard {
        uint64 id;
        Weights[] weights;
    }

    struct Weights {
        address reciever;
        uint96 percentageNumber;
    }

    mapping (bytes32 valPubKey => CuttingBoard) activeCuttingBoards;
    mapping (bytes32 valPubKey => CuttingBoard) queuedCuttingBoards;
    mapping (address reciever => bool) isFriendsOfChef;
    CuttingBoard defaultCuttingBoard;


    constructor() {

    }
}
