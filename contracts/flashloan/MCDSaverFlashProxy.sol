pragma solidity ^0.5.7;

import "../mcd/saver_proxy/MCDSaverProxy.sol";

contract ManagerLike {
    function ilks(uint) public view returns (bytes32);
}

contract MCDSaverFlashProxy is MCDSaverProxy {

    Manager public constant manager = Manager(MANAGER_ADDRESS);

    function actionWithLoan(
        uint[6] memory _data,
        uint _loanAmount,
        address _joinAddr,
        address _exchangeAddress,
        bytes memory _callData,
        bool isRepay
    ) public {

        // payback the CDP debt with loan amount
        address owner = getOwner(manager, _data[0]);
        // bytes32 ilkk = ManagerLike(0x1476483dD8C35F25e568113C5f70249D3976ba21).ilks(277);
        // paybackDebt(_data[0], manager.ilks(_data[0]), _loanAmount, owner);

        if (isRepay) {
            repay(_data, _joinAddr, _exchangeAddress, _callData);
        } else {
            boost(_data, _joinAddr, _exchangeAddress, _callData);
        }

        uint daiDrawn = 0;

        // repay the flash loan
        // uint daiDrawn = drawDai(_data[0], manager.ilks(_data[0]), _loanAmount);

        require(daiDrawn >= _loanAmount, "Loan debt to big for CDP");

        // ERC20(DAI_ADDRESS).transfer(address(NEW_IDAI_ADDRESS), _loanAmount);
    }

    function() external payable {}

}
