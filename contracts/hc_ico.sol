pragma solidity ^0.4.16;

interface token {
    function transfer(address receiver, uint amount);
}


contract HarambeCoin {
  uint public totalSupply;
  function balanceOf(address who) constant returns (uint);
  function allowance(address owner, address spender) constant returns (uint);
  function transfer(address to, uint value) returns (bool ok);
  function transferFrom(address from, address to, uint value) returns (bool ok);
  function approve(address spender, uint value) returns (bool ok);
  function mintToken(address to, uint256 value) returns (uint256);
  function changeTransfer(bool allowed);
}


contract ProjectHarambe {
    address public beneficiary;
    uint public amountRaised;
    uint public deadline;
    uint public price;
    token public tokenReward;
    mapping(address => uint256) public balanceOf;
    bool crowdsaleClosed = false;

    event GoalReached(address recipient, uint totalAmountRaised);
    event FundTransfer(address backer, uint amount, bool isContribution);


    /**
     * Constrctor function
     *
     * Setup the owner
     */
    function Crowdsale(
        uint etherCostOfEachToken,
        address tokenAddress
    ) {
        ETHWalletKy = 0x0;
        ETHWalletBr = 0x0;
        ETHWalletJa = 0x0;
        ETHWalletCh = 0x0;
        ETHWalletHarambe = 0x0;

        /* The ICO will run for 31 days (the length of January) */
        deadline = now + 744 * 60 minutes;

        /* Exchange rate */
        exchangeRate = etherCostOfEachToken * 1 ether;

        //tokenReward = token(addressOfTokenUsedAsReward);

        token = HarambeCoin(tokenAddress);
    }

    // CONTRIBUTE FUNCTION
    // converts ETH to TOKEN and sends new TOKEN to the sender
    function contribute() external payable {
        require(msg.value>0);
        require(isFunding);
        //require(block.number <= endBlock);
        uint256 amount = msg.value * exchangeRate;
        uint256 total = totalMinted + amount;
        //require(total<=maxMintable);
        totalMinted += total;
        ETHWallet.transfer(msg.value);
        Token.mintToken(msg.sender, amount);
        Contribution(msg.sender, amount);
    }


    modifier afterDeadline() {
        if (now >= deadline) {
            _;
        }
    }
    

    // update the ETH/COIN rate
    function updateRate(uint256 rate) external {
        require(msg.sender==creator);
        require(isFunding);
        exchangeRate = rate;
    }

    /**
     * Check if goal was reached
     *
     * Checks if the goal or time limit has been reached and ends the campaign
     */
    function checkGoalReached() afterDeadline {
        //if (amountRaised >= fundingGoal){
        //    fundingGoalReached = true;
        //    GoalReached(beneficiary, amountRaised);
        //}
        crowdsaleClosed = true;
    }

}
