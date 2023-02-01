// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity 0.6.12;

import "./Setup.sol";

contract EchidnaLGE2 is Setup {
    function echidnaCreatePairLiquidityGeneration() public payable {
        core.setContractStartTimestamp(block.timestamp);
        try core.addLiquidity{value: msg.value}(true) {
            /* not reverted */
            core.setContractStartTimestamp(1000);
            try core.addLiquidityToUniswapCORExWETHPair() {
                /* not reverted */
            } catch Error(string memory reason) {
                assert(
                    keccak256(abi.encode(reason)) ==
                        keccak256(
                            abi.encode("Liquidity generation already finished")
                        )
                );
            }
        } catch Error(string memory reason) {
            assert(
                keccak256(abi.encode(reason)) ==
                    keccak256(abi.encode("Liquidity Generation Event over"))
            );
        }
    }
}
