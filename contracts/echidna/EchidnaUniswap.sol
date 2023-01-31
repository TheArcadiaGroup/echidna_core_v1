// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity 0.6.12;

import "./Setup.sol";

contract EchidnaUniswap is Setup {
    function echidnaPendingFeesCorrectlyAndCorrectBalance(uint256 amount) public payable {
        // assert(address(this).balance == ethAmount);

        // uint delay = 7 days;
        // if(block.timestamp >= core.getContractStartTimestamp() + delay) {

        // }
        // assert(false);
        try core.setContractStartTimestamp(1000) {
            /* not reverted */
        } catch {
            assert(false);
        }

        try core.addLiquidity{value: msg.value}(true) {
            /* not reverted */
        } catch Error(string memory reason) {
            assert(
                keccak256(abi.encode(reason)) ==
                    keccak256(abi.encode("Liquidity Generation Event over"))
            );
        }

        try core.addLiquidityToUniswapCORExWETHPair() {
            /* not reverted */
        } catch Error(string memory reason) {
            assert(
                keccak256(abi.encode(reason)) ==
                    keccak256(abi.encode("Liquidity generation onging"))
            );
        }

        try core.claimLPTokens() {
            /* not reverted */
        } catch {
            assert(false);
        }

        try core.setFeeDistributor(address(coreVault)) {
            /* not reverted */
        } catch {
            assert(false);
        }
        uint256 pendingRewardsBefore = coreVault.pendingRewards();
        uint256 balBefore = core.balanceOf(address(coreVault));

        try core.transfer(address(this), 1) {
            /* not reverted */
        } catch {
            assert(false);
        }
        uint256 pendingRewardsAfter = coreVault.pendingRewards();
        uint256 balAfter = core.balanceOf(address(coreVault));
        assert(pendingRewardsAfter.sub(pendingRewardsBefore) == 10);
        assert(balAfter.sub(balBefore) == 10);
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
