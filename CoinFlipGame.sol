pragma solidity ^0.8.11;

contract CoinFlipGame {
    struct bet {
        uint256 betAmount;
        uint8 betOption;
    }
    address payable public dealer;
    address payable public player;
    uint256 public funds;
    uint256 public remainingBalance;
    uint256 public reward;
    bool public ongoingGame = false;
    bool public ongoingBet = false;
    bet public currentBet;
    event betPlaced(uint256 betAmount, uint8 betOption, address byPlayer);
    event coinFlipped(uint256 flipResult);

    constructor() {
        dealer = payable(msg.sender);
        remainingBalance = dealer.balance;
    }

    function depositFunds() public payable {
        funds = msg.value;
        player = payable(msg.sender);
        ongoingGame = true;
    }

    /// @notice The player places an amount of ETH in order to play
    function placeBet(uint256 betAmount, uint8 betOption) public {
        require(msg.sender == player);
        require(ongoingGame);
        require(!ongoingBet);
        require(betAmount <= funds);
        require(remainingBalance >= 2 * betAmount);
        ongoingBet = true;
        funds -= betAmount;
        currentBet = bet(betAmount, betOption);
        emit betPlaced(betAmount, betOption, msg.sender);
    }

    function random() private view returns (uint256) {
        return uint256(keccak256(abi.encode(block.timestamp)));
    }

    function flipCoin() public {
        require(msg.sender == dealer);
        require(ongoingBet);
        uint256 flipResult = random() % 2;
        ongoingBet = false;
        require(flipResult == currentBet.betOption);
        reward += 2 * currentBet.betAmount;
        remainingBalance -= reward;
        emit coinFlipped(flipResult);
        require(funds == 0 || remainingBalance == 0);
        player.transfer(reward);
        ongoingGame = false;
    }
}
