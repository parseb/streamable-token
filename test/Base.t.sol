// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/ERC3525streamable.sol";

contract ERC3525STest is Test {
    ERC3525streamable E3252S;
    address deployer;
    address notDeployer;

    function setUp() public {
        deployer = address(16);
        notDeployer = address(160001);

        vm.prank(deployer);
        E3252S = new ERC3525streamable();
    }

    // function testSetsOwner() public {
    //     assertTrue(E3252S.owner() == deployer, "default owner not deployer");
    // }
}
