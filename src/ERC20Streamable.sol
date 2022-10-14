// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "solmate/tokens/ERC20.sol";

struct Stream {
    address from;
    uint256[2] timeStartEnd;
    uint256 perSec;
}

contract ERC20Streamable is ERC20 {
    uint256 time0;
    address public c_c;
    mapping(bytes4 => bool) isSuspended;

    mapping(address => Stream[]) userStreams;

    constructor(string memory name_, string memory symbol_, uint8 decimals_, uint256 totalMint_)
        ERC20(name_, symbol_, decimals_)
    {
        time0 = block.timestamp;
        c_c = msg.sender;
        _mint(msg.sender, totalMint_);
    }

    /*//////////////////////////////////////////////////////////////
                               ERRORS
    //////////////////////////////////////////////////////////////*/

    error SuspendedFunction();

    /*//////////////////////////////////////////////////////////////
                               Events
    //////////////////////////////////////////////////////////////*/
    event functionSuspended(bytes4 fxSelect, bool afterFlipState);

    /*//////////////////////////////////////////////////////////////
                               Public Stream
    //////////////////////////////////////////////////////////////*/

    function startStream(address to_, uint256 amtPerSec_, uint256 units_) public returns (uint256 startBalance) {
        Stream memory S;
        S.from = msg.sender;
        S.perSec = amtPerSec_;
        S.timeStartEnd[0] = block.timestamp;
        if (units_ > 0) S.timeStartEnd[1] = block.timestamp + units_;

        userStreams[msg.sender].push(S);
        userStreams[to_].push(S);

        /// settle?

        return storedBalanceOf[msg.sender];
    }

    /*//////////////////////////////////////////////////////////////
                               Public Override
    //////////////////////////////////////////////////////////////*/

    function transfer(address to, uint256 amount) public virtual override returns (bool) {
        storedBalanceOf[msg.sender] -= amount;

        // Cannot overflow because the sum of all user
        // balances can't exceed the max uint256 value.
        unchecked {
            storedBalanceOf[to] += amount;
        }

        emit Transfer(msg.sender, to, amount);

        return true;
    }

    function balanceOf(address who_) public view returns (uint256 balance) {
        /// try magic
        Stream[] memory US = userStreams[who_];
        uint256 i;
        balance = storedBalanceOf[who_];
        for (i; i < US.length;) {
            uint256 amt;
            amt = US[i].timeStartEnd[1] <= block.timestamp
                ? US[i].timeStartEnd[1] - US[i].timeStartEnd[0]
                : block.timestamp - US[i].timeStartEnd[0];
            amt *= US[i].perSec;
            if (balance < amt) amt += balance;
            /// @dev

            balance = US[i].from == who_ ? balance - amt : balance + amt;
            unchecked {
                ++i;
            }
        }
    }

    function calculateElapsedWei() private returns (uint256) {}

    function transferFrom(address from, address to, uint256 amount) public virtual override returns (bool) {
        uint256 allowed = allowance[from][msg.sender]; // Saves gas for limited approvals.

        if (allowed != type(uint256).max) allowance[from][msg.sender] = allowed - amount;

        storedBalanceOf[from] -= amount;

        // Cannot overflow because the sum of all user
        // balances can't exceed the max uint256 value.
        unchecked {
            storedBalanceOf[to] += amount;
        }

        emit Transfer(from, to, amount);

        return true;
    }

    function approve(address spender, uint256 amount) public override returns (bool) {
        allowance[msg.sender][spender] = amount;

        emit Approval(msg.sender, spender, amount);
        return true;
    }

    /*//////////////////////////////////////////////////////////////
                               Internal Override
    //////////////////////////////////////////////////////////////*/

    function _mint(address to, uint256 amount) internal virtual override {
        totalSupply += amount;

        // Cannot overflow because the sum of all user
        // balances can't exceed the max uint256 value.
        unchecked {
            storedBalanceOf[to] += amount;
        }

        emit Transfer(address(0), to, amount);
    }

    function _burn(address from, uint256 amount) internal virtual override {
        storedBalanceOf[from] -= amount;

        // Cannot underflow because a user's balance
        // will never be larger than the total supply.
        unchecked {
            totalSupply -= amount;
        }

        emit Transfer(from, address(0), amount);
    }

    /*//////////////////////////////////////////////////////////////
                               View
    //////////////////////////////////////////////////////////////*/

    function getUserStreams(address user_) public view returns (Stream[] memory) {
        return userStreams[user_];
    }

    /*//////////////////////////////////////////////////////////////
                               Misc
    //////////////////////////////////////////////////////////////*/

    function flipSuspended(bytes4 funcSig_) public {
        require(msg.sender == c_c, "not command and control");
        isSuspended[funcSig_] = !isSuspended[funcSig_];
        emit functionSuspended(funcSig_, isSuspended[funcSig_]);
    }
}
