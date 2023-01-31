// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity 0.6.12;

import "./Setup.sol";

contract EchidnaCoreVault is Setup {
    function echidnaAdd(
        uint256 _allocPoint,
        IERC20 _token,
        bool _withUpdate,
        bool _withdrawable
    ) public {
        uint256 poolLengthBefore = coreVault.poolLength();
        if (_allocPoint == 0) _allocPoint = 100;
        try coreVault.add(_allocPoint, _token, _withUpdate, _withdrawable) {
            /* not reverted */
        } catch Error(string memory reason) {
            assert(
                keccak256(abi.encode(reason)) ==
                    keccak256(abi.encode("Error pool already added"))
            );
        }
        uint256 poolLengthAfter = coreVault.poolLength();
        assert(poolLengthAfter == poolLengthBefore.add(1));
    }

    function echidnaAdd_NotOwner(
        uint256 _allocPoint,
        IERC20 _token,
        bool _withUpdate,
        bool _withdrawable
    ) public {
        uint256 poolLengthBefore = coreVault.poolLength();
        UserMock user = new UserMock();
        try user.add(address(coreVault), _allocPoint, _token, _withUpdate, _withdrawable) {
            assert(false);
        } catch Error(string memory reason) {
            assert(
                keccak256(abi.encode(reason)) ==
                    keccak256(abi.encode("Ownable: caller is not the owner"))
            );
        }
        uint256 poolLengthAfter = coreVault.poolLength();
        assert(poolLengthAfter == poolLengthBefore);
    }

    function echidnaSet(
        uint256 _pid,
        uint256 _allocPoint,
        bool _withUpdate
    ) public {
        uint256 poolLength = coreVault.poolLength();
        try coreVault.add(100, token, true, true) {
            /* not reverted */
        } catch {
            assert(false);
        }
        uint256 poolLengthAfter = coreVault.poolLength();
        assert(poolLengthAfter == poolLength.add(1));
        try coreVault.set(poolLength, _allocPoint, _withUpdate) {
            /* not reverted */
        } catch {
            assert(false);
        }  
    }

    function echidnaSet_NotOwner(
        uint256 _pid,
        uint256 _allocPoint,
        bool _withUpdate
    ) public {
        UserMock user = new UserMock();
        uint256 poolLength = coreVault.poolLength();
        try coreVault.add(100, token, true, true) {
            /* not reverted */
        } catch {
            assert(false);
        }
        uint256 poolLengthAfter = coreVault.poolLength();
        assert(poolLengthAfter == poolLength.add(1));
        try user.set(address(coreVault), poolLength, _allocPoint, _withUpdate) {
            assert(false);
        } catch Error(string memory reason) {
            assert(
                keccak256(abi.encode(reason)) ==
                    keccak256(abi.encode("Ownable: caller is not the owner"))
            );
        } 
    }

    function echidnaSetDevFee(uint16 _devFee) public {
        _devFee = _devFee % 1000;
        try coreVault.setDevFee(_devFee) {
            /* not reverted */
        } catch {
            assert(false);
        }
    }

    function echidnaSetDevFee_Revert(uint16 _devFee) public {
        if (_devFee <= 1000) {
            _devFee = _devFee + 1001;
        }
        try coreVault.setDevFee(_devFee) {
            assert(false);
        } catch Error(string memory reason) {
            /* reverted */
            assert(
                keccak256(abi.encode(reason)) ==
                    keccak256(abi.encode("Dev fee clamped at 10%"))
            );
        }
    }

    function echidnaDeposit(uint256 _amount) public {
        ERC20Mock token = new ERC20Mock("Test", "Test");
        try token.mint(address(this), _amount) {
            /* not reverted */
        } catch {
            assert(false);
        }
        uint256 poolLength = coreVault.poolLength();
        uint256 balBefore = token.balanceOf(address(this));
        assert(balBefore == _amount);
        try coreVault.add(100, token, true, true) {
            /* not reverted */
        } catch {
            assert(false);
        }
        uint256 poolLengthAfter = coreVault.poolLength();
        assert(poolLengthAfter == poolLength.add(1));
        token.approve(address(coreVault), _amount);
        try coreVault.deposit(poolLength, _amount) {
            /* not reverted */
        } catch {
            assert(false);
        }
        uint256 balAfter = token.balanceOf(address(this));
        assert(balAfter == 0);
    }

    function echidnaDeposit_Revert_MissingApprove(uint256 _amount) public {
        ERC20Mock token = new ERC20Mock("Test", "Test");
        try token.mint(address(this), _amount) {
            /* not reverted */
        } catch {
            assert(false);
        }
        uint256 poolLength = coreVault.poolLength();
        uint256 balBefore = token.balanceOf(address(this));
        assert(balBefore == _amount);
        try coreVault.add(100, token, true, true) {
            /* not reverted */
        } catch {
            assert(false);
        }
        uint256 poolLengthAfter = coreVault.poolLength();
        assert(poolLengthAfter == poolLength.add(1));
        try coreVault.deposit(poolLength, _amount) {
            // assert(false);
        } catch Error(string memory reason) {
            // assert(
            //     keccak256(abi.encode(reason)) ==
            //         keccak256(abi.encode('ERC20: transfer amount exceeds allowance'))
            // );
        }
        uint256 balAfter = token.balanceOf(address(this));
        assert(balAfter == 0);
    }

    function echidnaDepositFor(uint256 _amount) public {
        ERC20Mock token = new ERC20Mock("Test", "Test");
        UserMock depositFor = new UserMock();
        try token.mint(address(this), _amount) {
            /* not reverted */
        } catch {
            assert(false);
        }
        uint256 poolLength = coreVault.poolLength();
        uint256 balBefore = token.balanceOf(address(this));
        assert(balBefore == _amount);
        try coreVault.add(100, token, true, true) {
            /* not reverted */
        } catch {
            assert(false);
        }
        uint256 poolLengthAfter = coreVault.poolLength();
        assert(poolLengthAfter == poolLength.add(1));
        try token.approve(address(coreVault), _amount) {
            /* not reverted */
        } catch {
            assert(false);
        }
        try coreVault.depositFor(address(depositFor), poolLength, _amount) {
            assert(false);
        } catch Error(string memory reason) {
            // assert(
            //     keccak256(abi.encode(reason)) ==
            //         keccak256(abi.encode('ERC20: transfer amount exceeds allowance'))
            // );
        }
        uint256 balAfter = token.balanceOf(address(this));
        assert(balAfter == 0);
        try
            depositFor.withdrawCallback(address(coreVault), poolLength, _amount)
        {
            /* not reverted */
        } catch {
            assert(false);
        }
        uint256 balDepositFor = token.balanceOf(address(depositFor));
        assert(balDepositFor == _amount);
    }

    function echidnaDepositFor_Revert_MissingApprove(uint256 _amount) public {
        ERC20Mock token = new ERC20Mock("Test", "Test");
        UserMock depositFor = new UserMock();
        try token.mint(address(this), _amount) {
            /* not reverted */
        } catch {
            assert(false);
        }
        uint256 poolLength = coreVault.poolLength();
        uint256 balBefore = token.balanceOf(address(this));
        assert(balBefore == _amount);
        try coreVault.add(100, token, true, true) {
            /* not reverted */
        } catch {
            assert(false);
        }
        uint256 poolLengthAfter = coreVault.poolLength();
        assert(poolLengthAfter == poolLength.add(1));
        try coreVault.depositFor(address(depositFor), poolLength, _amount) {
            assert(false);
        } catch Error(string memory reason) {
            // assert(
            //     keccak256(abi.encode(reason)) ==
            //         keccak256(abi.encode('ERC20: transfer amount exceeds allowance'))
            // );
        }
        uint256 balAfter = token.balanceOf(address(this));
        assert(balAfter == 0);
        try
            depositFor.withdrawCallback(address(coreVault), poolLength, _amount)
        {
            /* not reverted */
        } catch {
            assert(false);
        }
        uint256 balDepositFor = token.balanceOf(address(depositFor));
        assert(balDepositFor == _amount);
        revert();
    }

    function echidnaWithdraw(uint256 _amount) public {
        ERC20Mock token = new ERC20Mock("Test", "Test");
        try token.mint(address(this), _amount) {
            /* not reverted */
        } catch {
            assert(false);
        }
        uint256 poolLength = coreVault.poolLength();
        uint256 balBefore = token.balanceOf(address(this));
        assert(balBefore == _amount);
        try coreVault.add(100, token, true, true) {
            /* not reverted */
        } catch {
            assert(false);
        }
        uint256 poolLengthAfter = coreVault.poolLength();
        assert(poolLengthAfter == poolLength.add(1));
        try token.approve(address(coreVault), _amount) {
            /* not reverted */
        } catch {
            assert(false);
        }
        try coreVault.deposit(poolLength, _amount) {
            // assert(false);
        } catch Error(string memory reason) {
            // assert(
            //     keccak256(abi.encode(reason)) ==
            //         keccak256(abi.encode('ERC20: transfer amount exceeds allowance'))
            // );
        }
        uint256 balAfter = token.balanceOf(address(this));
        assert(balAfter == 0);
        try coreVault.withdraw(poolLength, _amount) {
            /* not reverted */
        } catch {
            assert(false);
        }
        uint256 balAfterWithdraw = token.balanceOf(address(this));
        assert(balAfterWithdraw == _amount);
    }

    function echidnaWithdrawFrom(uint256 _amount) public {
        ERC20Mock token = new ERC20Mock("Test", "Test");
        UserMock depositFor = new UserMock();
        try token.mint(address(this), _amount) {
            /* not reverted */
        } catch {
            assert(false);
        }
        uint256 poolLength = coreVault.poolLength();
        uint256 balBefore = token.balanceOf(address(this));
        assert(balBefore == _amount);
        try coreVault.add(100, token, true, true) {
            /* not reverted */
        } catch {
            assert(false);
        }
        uint256 poolLengthAfter = coreVault.poolLength();
        assert(poolLengthAfter == poolLength.add(1));
        try token.approve(address(coreVault), _amount) {
            /* not reverted */
        } catch {
            assert(false);
        }
        try coreVault.depositFor(address(depositFor), poolLength, _amount) {
            assert(false);
        } catch Error(string memory reason) {
            // assert(
            //     keccak256(abi.encode(reason)) ==
            //         keccak256(abi.encode('ERC20: transfer amount exceeds allowance'))
            // );
        }
        uint256 balAfter = token.balanceOf(address(this));
        assert(balAfter == 0);
        try depositFor.setAllowanceForPoolTokenCallback(
            address(coreVault),
            address(this),
            poolLength,
            _amount
        ) {
            /* not reverted */
        } catch {
            assert(false); 
        }
        try coreVault.withdrawFrom(address(depositFor), poolLength, _amount) {
            /* not reverted */
        } catch {
            assert(false); 
        }
        uint256 balAfterWithdraw = token.balanceOf(address(this));
        assert(balAfterWithdraw == _amount);
    }

    function echidnaWithdrawFrom_Revert_MissingSetAllowanceForPoolTokenCallback(
        uint256 _amount
    ) public {
        ERC20Mock token = new ERC20Mock("Test", "Test");
        UserMock depositFor = new UserMock();
        try token.mint(address(this), _amount) {
            /* not reverted */
        } catch {
            assert(false);
        }
        uint256 poolLength = coreVault.poolLength();
        uint256 balBefore = token.balanceOf(address(this));
        assert(balBefore == _amount);
        try coreVault.add(100, token, true, true) {
            /* not reverted */
        } catch {
            assert(false);
        }
        uint256 poolLengthAfter = coreVault.poolLength();
        assert(poolLengthAfter == poolLength.add(1));
        try token.approve(address(coreVault), _amount) {
            /* not reverted */
        } catch {
            assert(false);
        }
        try coreVault.depositFor(address(depositFor), poolLength, _amount) {
            assert(false);
        } catch Error(string memory reason) {
            // assert(
            //     keccak256(abi.encode(reason)) ==
            //         keccak256(abi.encode('ERC20: transfer amount exceeds allowance'))
            // );
        }
        uint256 balAfter = token.balanceOf(address(this));
        assert(balAfter == 0);
        try coreVault.withdrawFrom(address(depositFor), poolLength, _amount) {
            assert(false); 
        } catch {
            /* reverted */
        }
        uint256 balAfterWithdraw = token.balanceOf(address(this));
        assert(balAfterWithdraw == _amount);
    }

    function echidnaWithdrawFrom_Revert_SetAllowanceForPoolTokenCallback_Less(
        uint256 _amount
    ) public {
        ERC20Mock token = new ERC20Mock("Test", "Test");
        UserMock depositFor = new UserMock();
        try token.mint(address(this), _amount) {
            /* not reverted */
        } catch {
            assert(false);
        }
        uint256 poolLength = coreVault.poolLength();
        uint256 balBefore = token.balanceOf(address(this));
        assert(balBefore == _amount);
        try coreVault.add(100, token, true, true) {
            /* not reverted */
        } catch {
            assert(false);
        }
        uint256 poolLengthAfter = coreVault.poolLength();
        assert(poolLengthAfter == poolLength.add(1));
        try token.approve(address(coreVault), _amount) {
            /* not reverted */
        } catch {
            assert(false);
        }
        try coreVault.depositFor(address(depositFor), poolLength, _amount) {
            assert(false);
        } catch Error(string memory reason) {
            // assert(
            //     keccak256(abi.encode(reason)) ==
            //         keccak256(abi.encode('ERC20: transfer amount exceeds allowance'))
            // );
        }
        uint256 balAfter = token.balanceOf(address(this));
        assert(balAfter == 0);
        try depositFor.setAllowanceForPoolTokenCallback(
            address(coreVault),
            address(this),
            poolLength,
            _amount
        ) {
            /* not reverted */
        } catch {
            assert(false); 
        }
        try coreVault.withdrawFrom(address(depositFor), poolLength, _amount) {
            assert(false); 
        } catch {
            /* reverted */
        }
        uint256 balAfterWithdraw = token.balanceOf(address(this));
        assert(balAfterWithdraw == _amount);
    }
}
