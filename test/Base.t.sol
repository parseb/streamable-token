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

    address beneficiary1;
    address beneficiary2;
    address beneficiary3;

    function setUp() public {
        deployer = address(16);
        notDeployer = address(160001);
        totalMint = 1_000_000 * 1 ether;

        beneficiary1 = address(64);
        beneficiary2 = address(128);
        beneficiary3 = address(156);

        vm.prank(deployer);
        ERC20S = new ERC20Streamable(name,symbol,18, totalMint);
    }

    function testDeployed() public {
        assertTrue(
            keccak256((abi.encodePacked(ERC20S.name()))) == keccak256(abi.encodePacked(name)), "not expected name"
        );

        assertTrue(ERC20S.totalSupply() == totalMint, "inconsistent total balance");
    }

    function testProveStream() public {
        uint256 amtPerSec = 1 ether / 2;
        skip(100);
        vm.prank(deployer);
        uint256 startBalance = ERC20S.startStream(beneficiary1, amtPerSec, 10);
        Stream[] memory streams;
        streams = ERC20S.getUserStreams(beneficiary1);
        assertTrue(streams.length > 0, "no stream");
        assertTrue(ERC20S.balanceOf(beneficiary1) == 0, "balance not 0");
        // skip(1);
        assertTrue(startBalance == ERC20S.balanceOf(deployer), "0 sec passed balance changed");
        assertTrue(0 == ERC20S.balanceOf(beneficiary1), "baneficiary has balance");
        skip(1);
        assertTrue(ERC20S.balanceOf(beneficiary1) == amtPerSec, "invalid balance after 1 sec | 1");
        assertTrue(ERC20S.balanceOf(deployer) == startBalance - amtPerSec, "invalid balance after 1 sec | 2");
        skip(1);
        assertTrue(ERC20S.balanceOf(beneficiary1) == amtPerSec * 2, "invalid balance after 1 sec | 1.2");
        assertTrue(ERC20S.balanceOf(deployer) == startBalance - amtPerSec * 2, "invalid balance after 1 sec | 2.2");
        skip(1);
        assertTrue(ERC20S.balanceOf(beneficiary1) == amtPerSec * 3, "invalid balance after 1 sec | 1.3");
        assertTrue(ERC20S.balanceOf(deployer) == startBalance - amtPerSec * 3, "invalid balance after 1 sec | 2.3");
        skip(5345);
        assertTrue(ERC20S.balanceOf(beneficiary1) == amtPerSec * 10, "invalid balance after 1 sec | 1.44");
        assertTrue(ERC20S.balanceOf(deployer) == startBalance - amtPerSec * 10, "invalid balance after 1 sec | 2.44");

        console.log("######----- test prove Stream -----#######");
    }
}
