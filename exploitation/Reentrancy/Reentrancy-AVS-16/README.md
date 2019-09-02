## Vulnerable Code

```javascript
**Instance_1**
function withdrawEther() public {
        if (roundFailedToStart == true) {
            require(msg.sender.send(deals[msg.sender].sumEther));
        }
        if (msg.sender == operator) {
            require(projectWallet.send(ethForMilestone+postDisputeEth));
            ethForMilestone = 0;
            postDisputeEth = 0;
        }
        if (msg.sender == juryOnlineWallet) {
            require(juryOnlineWallet.send(etherAllowance));
            require(jotter.call.value(jotAllowance)(abi.encodeWithSignature("swapMe()")));   //Vulnerable position
            etherAllowance = 0;
            jotAllowance = 0;
        }
        if (deals[msg.sender].verdictForInvestor == true) {
            require(msg.sender.send(deals[msg.sender].sumEther - deals[msg.sender].etherUsed));
        }
    }
    
    
**Instance_2**
function withdrawEther() public {
        if (msg.sender == juryOperator) {
            require(juryOnlineWallet.send(etherAllowance));
            //require(jotter.call.value(jotAllowance)(abi.encodeWithSignature("swapMe()")));
            etherAllowance = 0;
            jotAllowance = 0;
        }
}//out6943
```



## Exploit Code

```javascript

```



##  Sophisticated Vulnerability Description

