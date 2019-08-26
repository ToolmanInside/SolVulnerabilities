## Vulnerable Code

```javascript
**Instance_1**
function getState() public constant returns (State) {
    if(finalized) return State.Finalized;
    else if (address(finalizeAgent) == 0) return State.Preparing;
    else if (!finalizeAgent.isSane()) return State.Preparing;
    else if (!pricingStrategy.isSane(address(this))) return State.Preparing;
    else if (block.timestamp < startsAt) return State.PreFunding;             //Vulnerable position
    else if (block.timestamp <= endsAt && !isCrowdsaleFull()) return State.Funding;  //Vulnerable position
    else if (isMinimumGoalReached()) return State.Success;
    else return State.Failure;
  }
  
  
**Instance_2**
function getState() public view returns (State) {
    if(finalized) return State.Finalized;
    else if (address(finalizeAgent) == 0) return State.Preparing;
    else if (!finalizeAgent.isSane()) return State.Preparing;
    else if (!pricingStrategy.isSane()) return State.Preparing;  //code different
    else if (block.timestamp < startsAt) return State.PreFunding;
    else if (block.timestamp <= endsAt && !isCrowdsaleFull()) return State.Funding;
    else if (isMinimumGoalReached()) return State.Success;
    else return State.Failure;
}
```



## Exploit Code

```javascript

```



##  Sophisticated Vulnerability Description
Note the location of comment of vulnerability position.As we all know manners can change the value of block.timestamp.To a certain extent, the location of comment of vulnerability position is danger.
