// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;
import {OwnableUpgradeable} from "@openzeppelin/contracts-upgradeable/";
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
    uint8 maxNumWeightsPerCuttingBoard;
    address[] valOperators;

    /// @notice The delay in blocks before a new cutting board can go into effect.
    uint64 public cuttingBoardBlockDelay;


    constructor() {
        _disableInitializers();
    }

    modifier onlyOperator(bytes calldata valPubKey) {
        require(valOperators[valPubKey], "onlyOperator: not an operator");
    }

    function initialize(
                        address _governance,
                        address _beaconDepositContract,
                        uint8 _maxNumWeightsPerCuttingBoard) external initializer {
        __Ownable_init(_governance);

        maxNumWeightsPerCuttingBoard = _maxNumWeightsPerCuttingBoard;
    }

    //questions how are the managing the queue?
    //questions how are they tracking the blocks?
    //how do we write the modifier in such a way to only be modifiiable by validator?

    function queueNewCuttingBoard(bytes calldata valPubKey,
                                    uint64 startBlock
                                    Weight[] calldata weights) external onlyOperator(valPubKey) {

        if (startBlock <= block.number + cuttingBoardDelay) {
                revert();
        }

        CuttingBoard storage qcb = queuedCuttingBoards[valPubKey];

        Weights[] storage storageWeights = qcb.weights;
        for (uint i = 0; i < weights.length; i++) {
                storageWeights.push(weights[i]);
        }

        unchecked {
            i++;
        }

    }
}
