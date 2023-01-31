// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity 0.6.12;

import "./Setup.sol";

contract EchidnaLGE is Setup {
    function echidnaDepositOfNothing() public {
        assert(address(core).balance == 0);
        assert(core.balanceOf(address(core)) == 10000e18);
        try core.addLiquidity{value: 0}(true) {
            /* not reverted */
        } catch Error(string memory reason) {
            assert(
                keccak256(abi.encode(reason)) ==
                    keccak256(abi.encode("Liquidity Generation Event over"))
            );
        }
        assert(address(core).balance == 0);
        assert(core.balanceOf(address(core)) == 10000e18);
        assert(core.ethContributed(address(this)) == 0);
    }

    function echidnaAddLiquidity(uint256 amount) public {
        uint256 balETHBefore = address(core).balance;
        uint256 ethContributedBefore = core.ethContributed(address(this));
        assert(core.balanceOf(address(core)) == 10000e18);
        try core.addLiquidity{value: amount}(true) {
            /* not reverted */
        } catch Error(string memory reason) {
            assert(
                keccak256(abi.encode(reason)) ==
                    keccak256(abi.encode("Liquidity Generation Event over"))
            );
        }
        uint256 balETHAfter = address(core).balance;
        assert(balETHAfter.sub(balETHBefore) == amount);
        assert(core.balanceOf(address(core)) == 10000e18);
        uint256 ethContributedAfter = core.ethContributed(address(this));
        assert(ethContributedAfter.sub(ethContributedBefore) == amount);
    }

    function echidnaCreatePairLiquidityGeneration() public payable {
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
    }

    function echidnaSetStrategyContractOrDistributionContractAllowance(
        uint256 amount
    ) public {
        try
            coreVault.setStrategyContractOrDistributionContractAllowance(
                address(core),
                amount,
                address(core)
            )
        {
            assert(false);
        } catch Error(string memory reason) {
            assert(
                keccak256(abi.encode(reason)) ==
                    keccak256(
                        abi.encode("Governance setup grace period not over")
                    )
            );
        }
    }

    function echidnaSetStrategyContractOrDistributionContractAllowance_NotSuperAdmin(
        uint256 amount
    ) public {
        UserMock user = new UserMock();
        try user.setStrategyContractOrDistributionContractAllowance(
                address(coreVault),
                address(core),
                amount,
                address(core)
            )
        {
            // assert(false);
        } catch Error(string memory reason) {
            assert(
                keccak256(abi.encode(reason)) ==
                    keccak256(
                        abi.encode("Super admin : caller is not super admin.")
                    )
            );
        }
    }
}
