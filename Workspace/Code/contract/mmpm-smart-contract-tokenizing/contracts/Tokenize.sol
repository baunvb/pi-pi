// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "./libraries/OwnerOperator.sol";
import "./TokenHTC.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "./interfaces/ITokenMint.sol";

contract Tokenize is OwnerOperator {
    using SafeMath for uint256;

    /* ========== STATE VARIABLES ========== */
    uint256 private constant RATE_PRECISION = 1e9;
    mapping(address => uint256) public token_price; // price SCP/token (HTC, SCC, XZC)
    mapping(address => address) public token_address;

    constructor() {}

    function addToken(address token ) external onlyOperator {
        token_address[token] = token;
    }

    function setTokenPrice(address token, uint256 price) external onlyOperator {
        require(token_address[token] != address(0), "Token not exits");
        token_price[token] = price;
    }

    // swap from SPC to token
    function swapSpcToToken(address token) payable external {
        require(msg.value > 0, "Not positive input");
        address _token_addres = token_address[token];
        require(_token_addres != address(0), "Token not exits");
        uint256 price = token_price[token];
        uint256 output_amount = msg.value.mul(price);
        ITokenMint(token).mint(msg.sender, output_amount);
    }
}