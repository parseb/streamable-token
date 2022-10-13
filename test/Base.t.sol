// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/ERC20Streamable.sol";

contract ERC20StreamableInitTest is Test {
    ERC20Streamable ERC20S;
    address deployer;
    address notDeployer;

    string name = "StreamableToken";
    string symbol = "StrT";
    uint256 totalMint;

    function setUp() public {
        deployer = address(16);
        notDeployer = address(160001);
        totalMint = 1_000_000 * 1 ether;

        vm.prank(deployer);
        ERC20S = new ERC20Streamable(name,symbol,18, totalMint);
    }

    function testDeployed() public {
        assertTrue(
            keccak256((abi.encodePacked(ERC20S.name()))) == keccak256(abi.encodePacked(name)), "not expected name"
        );

        assertTrue(ERC20S.totalSupply() == totalMint, "inconsistent total balance");
    }
}
