// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract LilPol {
    IERC20 public bgt;

    struct CuttingBoard {
        uint64 startBlock;
        Weight[] weights;
    }

    struct Weight {
        address receiver;
        uint96 percentageNumerator;
    }

    struct Validator {
        address operator;
        uint256 boost;
    }

    address public governance;

    // BeraChef
    mapping(bytes => CuttingBoard) public activeCuttingBoards;
    mapping(bytes => CuttingBoard) public queuedCuttingBoards;
    mapping(address => bool) public isFriendOfTheChef;
    CuttingBoard public defaultCuttingBoard;
    uint8 public maxNumWeightsPerCuttingBoard;
    uint64 public cuttingBoardBlockDelay;

    CuttingBoard public defaultCuttingBoard;
    uint8 public maxNumWeightsPerCuttingBoard;
    uint64 public cuttingBoardBlockDelay;

    // BlockRewardController
    mapping(bytes => Validator) public validators;

    // BlockRewardController
    uint256 public baseRate;
    uint256 public rewardRate;
    uint256 public minBoostedRewardRate;

    uint256 public constant ONE_HUNDRED_PERCENT = 1e4;

    constructor(address _bgt,
            address _governance) {
        bgt = IERC20(_bgt);
        maxNumWeightsPerCuttingBoard = 10; // Example value
        cuttingBoardBlockDelay = 100; // Example value
        baseRate = 1e18; // Example value
        rewardRate = 2e18; // Example value
        minBoostedRewardRate = 5e17; // Example value
        governance = _governance;
    }

    modifier onlyGovernance() {
        require(msg.sender == governance, "Only governance");
        _;
    }

    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*              BERACHEF FUNCTIONS                            */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/
    function queueNewCuttingBoard(bytes calldata valPubkey, uint64 startBlock, Weight[] calldata weights) external {
        require(validators[valPubkey].operator == msg.sender, "Not authorized");
        require(startBlock > block.number + cuttingBoardBlockDelay, "Invalid start block");
        require(weights.length <= maxNumWeightsPerCuttingBoard, "Too many weights");

        uint96 totalWeight;
        for (uint i = 0; i < weights.length; i++) {
            require(isFriendOfTheChef[weights[i].receiver], "Not friend of chef");
            totalWeight += weights[i].percentageNumerator;
        }
        require(totalWeight == ONE_HUNDRED_PERCENT, "Invalid weights");

        queuedCuttingBoards[valPubkey] = CuttingBoard(startBlock, weights);
    }

    function activateQueuedCuttingBoard(bytes calldata valPubkey) external {
        CuttingBoard storage qcb = queuedCuttingBoards[valPubkey];
        require(qcb.startBlock != 0 && qcb.startBlock <= block.number, "Not ready");
        activeCuttingBoards[valPubkey] = qcb;
        delete queuedCuttingBoards[valPubkey];
    }

    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*              BLOCK REWARD CONTROLLER FUNCTIONS             */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/
    function processRewards(bytes calldata valPubkey) external returns (uint256) {
        uint256 reward = rewardRate;
        Validator storage validator = validators[valPubkey];

        // Apply boost
        reward = (reward * (100 + validator.boost)) / 100;
        if (reward < minBoostedRewardRate) reward = minBoostedRewardRate;

        // Mint base rate to operator
        bgt.mint(validator.operator, baseRate);

        // Mint reward for distribution
        bgt.mint(address(this), reward);

        distributeRewards(valPubkey, reward);

        return reward;
    }


    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*              DISTRIBUTOR FUNCTIONS                         */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    function distributeRewards(bytes calldata valPubkey, uint256 reward) internal {
        CuttingBoard storage cb = activeCuttingBoards[valPubkey];
        if (cb.weights.length == 0) {
            cb = defaultCuttingBoard;
        }

        for (uint i = 0; i < cb.weights.length; i++) {
            Weight memory weight = cb.weights[i];
            uint256 amount = (reward * weight.percentageNumerator) / ONE_HUNDRED_PERCENT;
            bgt.transfer(weight.receiver, amount);
        }
    }

    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*              BERACHAIN REWARDS VAULT FUNCTIONS             */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/
    function stake(uint256 amount) external {
        bgt.transferFrom(msg.sender, address(this), amount);
        // Staking logic here
    }

    function withdraw(uint256 amount) external {
        // Withdrawal logic here
        bgt.transfer(msg.sender, amount);
    }

    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*              Governance Functions                             */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/
    function setDefaultCuttingBoard(Weight[] calldata weights)  external onlyGovernance {
        defaultCuttingBoard = CuttingBoard(0, weights);
    }

    function updateFriendOfTheChef(address friend, bool isFriend) external onlyGovernance {

        isFriendOfTheChef[friend] = isFriend;
    }

    function setValidator(bytes calldata valPubkey, address operator) external {

        validators[valPubkey].operator = operator;
    }

    function mint(address to, uint256 amount) internal {
        (bool success, ) = address(bgt).call(abi.encodeWithSignature("mint(address,uint256)", to, amount));
        require(success, "Minting failed");
    }
}