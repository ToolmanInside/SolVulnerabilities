## Vulnerable Code

```javascript
**Instance_1**
function buybackTypeOne() public {
        uint256 allowanceToken = token.allowance(msg.sender,this);
        require(allowanceToken != uint256(0));
        require(isInvestTypeOne(msg.sender));
        require(isBuyBackOne());
        require(balancesICOToken[msg.sender] >= allowanceToken);
        
        uint256 forTransfer = allowanceToken.mul(buyPrice).div(1e18).mul(3); //calculation Eth 100% in 3 year 
        require(totalFundsAvailable >= forTransfer);
        msg.sender.transfer(forTransfer);   //Vulnerable position_1
        totalFundsAvailable = totalFundsAvailable.sub(forTransfer);
        
        balancesICOToken[msg.sender] = balancesICOToken[msg.sender].sub(allowanceToken);
        token.transferFrom(msg.sender, this, allowanceToken;    //Vulnerable position_2
   }
   
**Instance_2**
function buybackTypeTwo() public {
        uint256 allowanceToken = token.allowance(msg.sender,this);
        require(allowanceToken != uint256(0));
        require(isInvestTypeTwo(msg.sender));
        require(isBuyBackTwo());
        require(balancesICOToken[msg.sender] >= allowanceToken);

        uint256 accumulated = percentBuyBackTypeTwo.mul(allowanceToken).div(100).mul(5).add(allowanceToken); // ~ 67%  of tokens purchased in 5 year
        uint256 forTransfer = accumulated.mul(buyPrice).div(1e18); //calculation Eth 
        require(totalFundsAvailable >= forTransfer);
        msg.sender.transfer(forTransfer);
        totalFundsAvailable = totalFundsAvailable.sub(forTransfer);

        balancesICOToken[msg.sender] = balancesICOToken[msg.sender].sub(allowanceToken);
        token.transferFrom(msg.sender, this, allowanceToken);
}//out10224
```



## Exploit Code

```javascript

```



##  Sophisticated Vulnerability Description

