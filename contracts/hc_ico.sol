pragma solidity ^0.4.16;

contract HarambeCoin {
  uint public totalSupply;
  function balanceOf(address who) public constant returns (uint);
  function allowance(address owner, address spender) public constant returns (uint);
  function transfer(address to, uint value) public returns (bool ok);
  function transferFrom(address from, address to, uint value) public returns (bool ok);
  function approve(address spender, uint value) public returns (bool ok);
  function mintToken(address to, uint256 value) public returns (uint256);
  function changeTransfer(bool allowed) public;
}


contract ProjectHarambe {
    address private ETHWalletKy;
    address private ETHWalletBr;
    address private ETHWalletJa;
    address private ETHWalletCh;
    address private ETHWalletHarambe;

    uint public totalMinted;
    uint public deadline;
    uint public exchangeRate;

    HarambeCoin public harambeCoin;
    mapping(address => uint256) public balanceOf;
    bool public isFunding;

    event ReleaseTokens(address from, uint256 amount);
    event Contribution(address from, uint256 amount);


    /**
     * Constrctor function
     *
     * Setup the owner
     */
    function Crowdsale(
        uint etherCostOfEachToken,
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
        exchangeRate = etherCostOfEachToken * 1 ether;

        harambeCoin = HarambeCoin(tokenAddress);
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

        ETHWalletHarambe.transfer(msg.value);
        harambeCoin.mintToken(msg.sender, amount);
        Contribution(msg.sender, amount);
    }


    modifier afterDeadline() {
        if (now >= deadline) {
            _;
        }
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
