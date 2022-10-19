pragma solidity ^0.5.0;

import "github.com/provable-things/ethereum-api/contracts/solc-v0.5.x/provableAPI.sol";

contract BitcoinPrice is usingProvable {
    string public GET_BITCOIN_PRICE_QUERY = "json(https://api.coingecko.com/api/v3/coins/markets?vs_currency=usd&order=market_cap_desc&per_page=1&page=1&sparkline=false).0.current_price";

    event LogNewProvableQuery(string description);
    event LogNewProvableResult(string result);

    mapping (bytes32 => bool) public pendingQueries;
    string public result;

    constructor() public payable {
    }

    function __callback(bytes32 _myid, string memory _result) public {
        require(msg.sender == provable_cbAddress());
        require (pendingQueries[_myid] == true);

        result = _result;
        emit LogNewProvableResult(_result);

        delete pendingQueries[_myid];
    }

    function retrieveBitcoinPrice() public payable {
        if (provable_getPrice("URL") > msg.value) {
            revert("Provable query was NOT sent, please add some ETH to cover for the query fee!");
        } else {
            emit LogNewProvableQuery("Provable query was sent, standing by for the answer...");
            bytes32 queryId = provable_query("URL", GET_BITCOIN_PRICE_QUERY);
            pendingQueries[queryId] = true;
        }
    }
}