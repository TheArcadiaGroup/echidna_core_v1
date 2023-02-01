// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity 0.6.12;

import "./Setup.sol";

contract EchidnaUniswap is Setup {
    function echidnaPendingFeesCorrectlyAndCorrectBalance(address receiver)
        public
        payable
    {
        core.setContractStartTimestamp(block.timestamp);
        try core.addLiquidity{value: msg.value}(true) {
            /* not reverted */
            core.setContractStartTimestamp(1000);
            try core.addLiquidityToUniswapCORExWETHPair() {
                /* not reverted */
                try core.claimLPTokens() {
                    /* not reverted */
                    try core.setFeeDistributor(address(coreVault)) {
                        /* not reverted */
                        uint256 pendingRewardsBefore = coreVault
                            .pendingRewards();
                        uint256 balCoreVaultBefore = core.balanceOf(
                            address(coreVault)
                        );
                        uint256 balBefore = core.balanceOf(address(this));
                        try core.transfer(receiver, balBefore) {
                            /* not reverted */
                            uint256 pendingRewardsAfter = coreVault
                                .pendingRewards();
                            uint256 balAfter = core.balanceOf(
                                address(coreVault)
                            );
                            assert(
                                pendingRewardsAfter.sub(pendingRewardsBefore) ==
                                    balBefore.div(100)
                            );
                            assert(
                                balAfter.sub(balBefore) == balBefore.div(100)
                            );
                        } catch {
                            assert(false);
                        }
                    } catch {
                        assert(false);
                    }
                } catch {
                    assert(false);
                }
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

    function echidnaSetFeeMultiplier(uint8 fee) public {
        try feeApprover.setFeeMultiplier(fee) {
            /* not reverted */
        } catch {
            assert(false);
        }
        assert(feeApprover.feePercentX100() == fee);
    }

    function echidnaSetFeeDistributor(address feeDistributor) public {
        try core.setFeeDistributor(feeDistributor) {
            /* not reverted */
        } catch {
            assert(false);
        }
        assert(core.feeDistributor() == feeDistributor);
        try core.setFeeDistributor(address(coreVault)) {
            /* not reverted */
        } catch {
            assert(false);
        }
    }

    function echidnaCalculateFees(address feeDistributor) public {
        try core.setFeeDistributor(feeDistributor) {
            /* not reverted */
        } catch {
            assert(false);
        }
        assert(core.feeDistributor() == feeDistributor);
        try core.setFeeDistributor(address(coreVault)) {
            /* not reverted */
        } catch {
            assert(false);
        }
    }
}
