// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.4;

// Uncomment this line to use console.log
// import "hardhat/console.sol";

import "./Interfaces/IVeloRouter.sol";

contract Lock {
    uint public unlockTime;
    address payable public owner;

    event Withdrawal(uint amount, uint when);

    address WETH = 0x4200000000000000000000000000000000000006;
    address ROUTER = 0x9c12939390052919aF3155f41Bf4160Fd3666A6f;
    address USDC = 0x7F5c764cBc14f9669B88837ca1490cCa17c31607;

    IVeloRouter router = IVeloRouter(ROUTER);

    constructor(uint _unlockTime) payable {
        require(
            block.timestamp < _unlockTime,
            "Unlock time should be in the future"
        );

        unlockTime = _unlockTime;
        owner = payable(msg.sender);
    }

    function withdraw() public {
        // Uncomment this line, and the import of "hardhat/console.sol", to print a log in your terminal
        // console.log("Unlock time is %o and block timestamp is %o", unlockTime, block.timestamp);

        require(block.timestamp >= unlockTime, "You can't withdraw yet");
        require(msg.sender == owner, "You aren't the owner");

        emit Withdrawal(address(this).balance, block.timestamp);

        owner.transfer(address(this).balance);
    }

    function swapEth(
        address tokenOut,
        uint256 amountOutMin
    ) public payable returns (uint256 amountOut) {
        IVeloRouter.route[] memory routes;
        routes = new IVeloRouter.route[](1);
        routes[0].from = 0x4200000000000000000000000000000000000006;
        routes[0].to = tokenOut;
        routes[0].stable = false;

        uint256[] memory amounts = router.swapExactETHForTokens{
            value: msg.value
        }(amountOutMin, routes, address(this), block.timestamp);

        // /// Refund tokenIn when the expected minimum out is not met
        // if (amountOutMin > amounts[2]) {
        //     IERC20(tokenIn).transfer(msg.sender, amounts[0]);
        // }

        return amounts[1];
    }
}
