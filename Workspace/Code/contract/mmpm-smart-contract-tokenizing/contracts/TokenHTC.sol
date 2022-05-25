// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

import "./libraries/OwnerOperator.sol";

contract TokenHTC is OwnerOperator, ERC20, Pausable {
    using SafeMath for uint256;

    // max amount token: 1 billion
    uint256 public constant cap = 1000000000 ether;
    mapping(address => uint256) public minters; // minter's address => minter's max cap
    mapping(address => uint256) public minters_minted;

    /* ========== Modifiers =============== */
    modifier onlyMinter() {
        require(minters[msg.sender] > 0, "Only minter can interact");
        _;
    }

    constructor() OwnerOperator() Pausable() ERC20("HTC", "HTC") {}

    /**
     * @dev Pauses all token transfers. See {Pausable-_pause}.
     */
    function pause() external virtual onlyOwner {
        _pause();
    }

    /**
     * @dev Unpauses all token transfers. See {Pausable-_unpause}.
     */
    function unpause() external virtual onlyOwner {
        _unpause();
    }

    /**
     * @dev See {ERC20-_beforeTokenTransfer}.
     */
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual override {
        super._beforeTokenTransfer(from, to, amount);
        require(!paused(), "TokenHTC: token transfer while paused");
        if (from == address(0)) {
            // When minting tokens
            require(totalSupply().add(amount) <= cap, "TokenHTC: cap exceeded");
        }
    }

    function setMinter(address _account, uint256 _minterCap) external operatorOrOwner {
        require(_account != address(0), "invalid address");
        require(
            minters_minted[_account] <= _minterCap,
            "Minter already minted a larger amount than new cap"
        );
        minters[_account] = _minterCap;
    }

    /**
     * @dev Creates `amount` new tokens for `to`. See {ERC20-_mint}.
     */
    function mint(address _recipient, uint256 _amount) public onlyMinter {
        minters_minted[_msgSender()] = minters_minted[_msgSender()].add(
            _amount
        );
        require(
            minters[_msgSender()] >= minters_minted[_msgSender()],
            "Minting amount exceeds minter cap"
        );
        _mint(_recipient, _amount);
    }

    /**
     * @dev Destroys `amount` tokens from the caller. See {ERC20-_burn}.
     */
    function burn(uint256 amount) external virtual {
        _burn(msg.sender, amount);
    }
}
