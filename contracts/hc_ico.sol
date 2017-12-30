pragma solidity ^0.4.16;

interface HarambeCoin {
    function mintToken(address to, uint256 value) public returns (uint256);
}


contract ProjectHarambe {
    address private ETHWalletKy;
    address private ETHWalletBr;
    address private ETHWalletJa;
    address private ETHWalletCh;
    address private ETHWalletHarambe;

    uint public totalMinted;
    uint public deadline;
    uint public etherCost;
    uint public exchangeRate;

    HarambeCoin public harambeCoin;
    mapping(address => uint256) public balanceOf;
    bool public isFunding;
    uint256 public decimals = 18;

    //event ReleaseTokens(address from, uint256 amount);
    event Contribution(address from, uint256 amount);


    /**
     * Constrctor function
     *
     * Setup the owner
     */
    function ProjectHarambe(
        uint cost,
        address tokenAddress
    ) public {
        ETHWalletKy = 0x0;
        ETHWalletBr = 0x0;
        ETHWalletJa = 0x0;
        ETHWalletCh = 0x0;
        ETHWalletHarambe = 0x0;

        isFunding = true;
        totalMinted = 0;

        /* The ICO will run for 31 days (the length of January) */
        deadline = now + 744 * 60 minutes;

        /* Exchange rate */
        etherCost = cost * 1 ether;
        exchangeRate = 1 / etherCost;

        harambeCoin = HarambeCoin(tokenAddress);
    }

    // default function
    // converts ETH to TOKEN and holds new token to be sent
    function () external payable {
        require(msg.value > 0);
        require(isFunding);

        uint256 amount = msg.value * exchangeRate;

        totalMinted += amount;

        //ETHWalletHarambe.transfer(msg.value);
        harambeCoin.mintToken(msg.sender, amount);
        balanceOf[msg.sender] += amount;
        Contribution(msg.sender, amount);
    }

    // CONTRIBUTE FUNCTION
    // converts ETH to TOKEN and holds new token to be sent
    function contribute() external payable {
        require(msg.value > 0);
        require(isFunding);

        uint256 amount = msg.value * exchangeRate;

        totalMinted += amount;

        //ETHWalletHarambe.transfer(msg.value);
        harambeCoin.mintToken(msg.sender, amount);
        balanceOf[msg.sender] += amount;
        Contribution(msg.sender, amount);
    }

    modifier afterDeadline() {
        if (now >= deadline) {
            _;
        }
    }
    
    /**
     * Returns total supply of the contract
     */
    function totalMinted() constant public returns (uint256 total){
        return totalMinted;
    }

    /**
     * Returns balance of particular address of account
     */
    function balanceOf() constant public returns (uint256 balance) {
        return balanceOf[msg.sender];
    }

    /**
     * Check if goal was reached
     *
     * Checks if the goal or time limit has been reached and ends the campaign
     */
    function checkGoalReached() public afterDeadline {
        //if (amountRaised >= fundingGoal){
        //    fundingGoalReached = true;
        //    GoalReached(beneficiary, amountRaised);
        //}
        isFunding = false;
    }

}
