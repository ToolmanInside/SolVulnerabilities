## Vulnerable Code

```javascript
**Instance_1**
 function revokeHashPreSigned(
        bytes _signature,
        bytes32 _hashToRevoke,
        uint256 _gasPrice)
      public
    returns (bool)
    {
        uint256 gas = gasleft();
        address from = recoverRevokeHash(_signature, _hashToRevoke, _gasPrice);
        require(from != address(0), "Invalid signature provided.");
        
        bytes32 txHash = getRevokeHash(_hashToRevoke, _gasPrice);
        require(!invalidHashes[from][txHash], "Transaction has already been executed.");
        invalidHashes[from][txHash] = true;
        nonces[from]++;
        
        invalidHashes[from][_hashToRevoke] = true;
        
        if (_gasPrice > 0) {
            gas = 35000 + gas.sub(gasleft());
            require(_transfer(from, tx.origin, _gasPrice.mul(gas)), "Gas cost could not be paid.");  //Vulnerable position
        }
        
        emit HashRedeemed(txHash, from);
        return true;
    }
    
    
**Instance_2**
function approveAndCallPreSigned(
    bytes _signature,
    address _to, 
    uint256 _value,
    bytes _extraData,
    uint256 _gasPrice,
    uint256 _nonce) 
  public
returns (bool) 
{
    uint256 gas = gasleft();
    address from = recoverPreSigned(_signature, approveAndCallSig, _to, _value, _extraData, _gasPrice, _nonce);
    require(from != address(0), "Invalid signature provided.");

    bytes32 txHash = getPreSignedHash(approveAndCallSig, _to, _value, _extraData, _gasPrice, _nonce);
    require(!invalidHashes[from][txHash], "Transaction has already been executed.");
    invalidHashes[from][txHash] = true;
    nonces[from]++;

    if (_value > 0) require(_approve(from, _to, _value));
    ApproveAndCallFallBack(_to).receiveApproval(from, _value, address(this), _extraData);

    if (_gasPrice > 0) {
        gas = 35000 + gas.sub(gasleft());
        require(_transfer(from, tx.origin, _gasPrice.mul(gas)), "Gas cost could not be paid.");
    }

    emit HashRedeemed(txHash, from);
    return true;
}//out3401
```



## Exploit Code

```javascript
Contract Attack{
    address victim;
    function setVictimAddress(address _address){
        victim = _address;
    }
    function startAttack(){
        victimAddress.call(byte4(keccak256(“revokeHashPreSigned(bytes, bytes32, uint256)”)), ..., ..., ...);
        ...
    }
}
```



##  Sophisticated Vulnerability Description
Note the location of comment of vulnerability position. Due to the 'tx.origin' ,whoever call this victim's method such as "revokeHashPreSigned", 'tx.origin' do not change.so the location of comment of vulnerability position is possible always success.ps:"...." represent an appropriate parameter
