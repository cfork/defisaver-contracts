pragma solidity ^0.5.0;
pragma experimental ABIEncoderV2;

import "../ProtocolInterface.sol";
import "./ISoloMargin.sol";
import "../../interfaces/ERC20.sol";
import "../../constants/ConstantAddresses.sol";
import "../../DS/DSAuth.sol";

contract DydxSavingsProtocol is ProtocolInterface, ConstantAddresses, DSAuth {


    ISoloMargin public soloMargin;
    ERC20 public dai;
    address public savingsProxy;

    uint daiMarketId = 1;

    constructor() public {
        soloMargin = ISoloMargin(SOLO_MARGIN_ADDRESS);
        dai = ERC20(MAKER_DAI_ADDRESS);
    }

    function addSavingsProxy(address _savingsProxy) public auth {
        savingsProxy = _savingsProxy;
    }

    function deposit(address _user, uint _amount) public {
        require(msg.sender == _user);

        Account.Info[] memory accounts = new Account.Info[](1);
        accounts[0] = getAccount(_user, 0);

        Actions.ActionArgs[] memory actions = new Actions.ActionArgs[](1);
        Types.AssetAmount memory amount = Types.AssetAmount({
            sign: true,
            denomination: Types.AssetDenomination.Wei,
            ref: Types.AssetReference.Delta,
            value: _amount
        });

        actions[0] = Actions.ActionArgs({
            actionType: Actions.ActionType.Deposit,
            accountId: 0,
            amount: amount,
            primaryMarketId: daiMarketId,
            otherAddress: _user,
            secondaryMarketId: 0, //not used
            otherAccountId: 0, //not used
            data: "" //not used
        });

        soloMargin.operate(accounts, actions);
    }

    function withdraw(address _user, uint _amount) public {
        require(msg.sender == _user);

        Account.Info[] memory accounts = new Account.Info[](1);
        accounts[0] = getAccount(_user, 0);

        Actions.ActionArgs[] memory actions = new Actions.ActionArgs[](1);
        Types.AssetAmount memory amount = Types.AssetAmount({
            sign: false,
            denomination: Types.AssetDenomination.Wei,
            ref: Types.AssetReference.Delta,
            value: _amount
        });

        actions[0] = Actions.ActionArgs({
            actionType: Actions.ActionType.Withdraw,
            accountId: 0,
            amount: amount,
            primaryMarketId: daiMarketId,
            otherAddress: _user,
            secondaryMarketId: 0, //not used
            otherAccountId: 0, //not used
            data: "" //not used
        });

        soloMargin.operate(accounts, actions);
    }

    function getWeiBalance(address _user, uint _index) public view returns(Types.Wei memory) {

        Types.Wei[] memory weiBalances;
        (,,weiBalances) = soloMargin.getAccountBalances(getAccount(_user, _index));

        return weiBalances[daiMarketId];
    }

    function getParBalance(address _user, uint _index) public view returns(Types.Par memory) {
        Types.Par[] memory parBalances;
        (,parBalances,) = soloMargin.getAccountBalances(getAccount(_user, _index));

        return parBalances[daiMarketId];
    }

    function getAccount(address _user, uint _index) public view returns(Account.Info memory) {
        Account.Info memory account = Account.Info({
            owner: _user,
            number: _index
        });

        return account;
    }
}
