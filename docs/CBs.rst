.. _CB1:

CB1
---------

::

    interface P3DTakeout {
        function buyTokens() external payable;
    }
    contract Betting{
        ...
        uint public winnerPoolTotal;
        P3DTakeout P3DContract_;
        uint public total_reward; // reward to be awarded
        constructor() public payable {
            owner = msg.sender;
            horses.BTC = bytes32("BTC");
            P3DContract_ = P3DTakeout(0x72b2670e55139934D6445348DC6EaB4089B12576);
        ...}
        function reward() internal {
            total_reward = coinIndex[horses.BTC].total + ... ;
            P3DContract_.buyTokens.value(p3d_fee)();
            ...
            winnerPoolTotal = coinIndex[horses.BTC].total;
        ...}
    }


.. _CB2:

CB2
-------

::

    interface P3D {
        function buy(address _playerAddress) payable external returns(uint256);
    }
    contract Crop {
        ...
        function buy(address _playerAddress) external payable onlyOwner() {
            P3D(0xB3775fB83F7D12A36E0475aBdD1FCA35c091efBe).buy.value(msg.value)(_playerAddress);
        }
    ...
    }


.. _CB3:

CB3
--------

::

    contract RegDocuments {
    modifier onlyAdmin() {
        if (msg.sender!= admin && msg.sender!=owner) revert();
        ...
    }
    constructor() {
        admin = msg.sender;
        owner = 0xc238ff50c09787e7b920f711850dd945a40d3232;
    }
    function regstDocs(bytes32 _storKey) onlyAdmin payable{
        uint _value = Storage.regPrice();
        Storage.regstUser.value(_value)(_storKey);
    }		
    }
    contract GlobalStorageMultiId { // Interface for Storage
        uint256 public regPrice;
        function regstUser(bytes32 _id) payable returns(bool);
    }
