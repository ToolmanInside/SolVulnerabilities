## Vulnerable Code

```javascript
**Instance_1**
constructor(uint256 openingTime, uint256 closingTime) public {
    // solium-disable-next-line security/no-block-members
    require(openingTime >= block.timestamp);    //Vulnerable position
    require(closingTime >= openingTime);

    _openingTime = openingTime;
    _closingTime = closingTime;
  }
  
  
**Instance_2**
constructor(uint256 _openingTime, uint256 _closingTime) public {  //different code
    // solium-disable-next-line security/no-block-members
    require(_openingTime >= block.timestamp);
    require(_closingTime >= _openingTime);

    openingTime = _openingTime;
    closingTime = _closingTime;
}
```



## Exploit Code

```javascript

```



##  Sophisticated Vulnerability Description
Note the location of comment of vulnerability position.As we all know manners can change the value of block.timestamp.To a certain extent, the location of comment of vulnerability position is danger
