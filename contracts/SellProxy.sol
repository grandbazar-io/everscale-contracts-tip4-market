pragma ton-solidity =0.58.1;

pragma AbiHeader expire;
pragma AbiHeader time;
pragma AbiHeader pubkey;

import "@itgold/everscale-tip/contracts/access/OwnableExternal.sol";
import "@itgold/everscale-tip/contracts/TIP4_1/interfaces/ITIP4_1NFT.sol";
import "@itgold/everscale-tip/contracts/TIP4_1/interfaces/INftChangeManager.sol";
import "./interfaces/ISellProxy.sol";
import "./interfaces/ISellRoot.sol";
import "./interfaces/ISell.sol";
import "./interfaces/IWhiteListManagement.sol";
import "@grandbazar-io/everscale-tip4-contracts/contracts/interfaces/INftCreated.sol";
import "@grandbazar-io/everscale-tip4-contracts/contracts/NftBulk.sol";

contract SellProxy is
	OwnableExternal,
	ISellProxy,
	INftChangeManager,
	INftCreated
{
	address _sellRoot;

	address _withdrawalAddress;

	uint128 _methodsCallsFee = 0.1 ever;

	constructor(
		uint256 ownerPubkey,
		address sellRoot,
		address withdrawalAddress
	) public OwnableExternal(ownerPubkey) {
		tvm.accept();

		_sellRoot = sellRoot;
		_withdrawalAddress = withdrawalAddress;
	}

	function onNftCreated(
		uint256 id,
		address owner,
		address manager,
		address collection,
		address sendGasTo,
		TvmCell payload
	) external virtual override internalMsg {
		if (
			manager != address(this)
		) {
			tvm.rawReserve(0, 4);
			ITIP4_1NFT(msg.sender).changeManager{
				value: 0,
				flag: 128,
				bounce: true
			}(owner, sendGasTo, emptyMap);
		} else {
			tvm.rawReserve(0, 4);

			(uint128 price, uint128 deployPrice) = payload.toSlice().decode(
				uint128,
				uint128
			);
			TvmBuilder payloadBuilder;
			payloadBuilder.store(price);

			mapping(address => ITIP4_1NFT.CallbackParams) callbacks;
			callbacks[_sellRoot] = ITIP4_1NFT.CallbackParams(
				deployPrice,
				payloadBuilder.toCell()
			);

			ITIP4_1NFT(msg.sender).changeManager{
				value: 0,
				flag: 128,
				bounce: true
			}(_sellRoot, sendGasTo, callbacks);
		}
	}

	function cancelSale(address offer) external virtual onlyOwner externalMsg {
		ISell(offer).cancelOrder{
			value: _methodsCallsFee,
			bounce: true,
			flag: 0
		}();
	}

	function cancelSaleAndReturnManagement(address offer)
		external
		virtual
		onlyOwner
		externalMsg
	{
		mapping(address => ITIP4_1NFT.CallbackParams) callbacks;
		TvmCell emptyCell;
		callbacks[address(this)] = ITIP4_1NFT.CallbackParams(
			_methodsCallsFee,
			emptyCell
		);
		ISell(offer).cancelOrderWithCallbacks{
			value: _methodsCallsFee * 2,
			bounce: true,
			flag: 0
		}(callbacks);
	}

	function onNftChangeManager(
		uint256 id,
		address owner,
		address oldManager,
		address newManager,
		address collection,
		address sendGasTo,
		TvmCell payload
	) external virtual override {
		_returnManagement(id, owner, newManager, collection);
	}

	function returnManagementToOwner(address nft)
		external
		virtual
		onlyOwner
		externalMsg
	{
		ITIP4_1NFT(nft).getInfo{
			value: _methodsCallsFee,
			bounce: true,
			flag: 0,
			callback: SellProxy.returnManagementCallback
		}();
	}

	function returnManagementCallback(
		uint256 id,
		address owner,
		address manager,
		address collection
	) external virtual internalMsg {
		_returnManagement(id, owner, manager, collection);
	}

	function _returnManagement(
		uint256 id,
		address owner,
		address manager,
		address collection
	) internal virtual {
		require(address(this) == manager, 100);
		tvm.rawReserve(0, 4);

		TIP4_1Nft(msg.sender).changeManager{value: 0, flag: 128, bounce: true}(
			owner,
			owner,
			emptyMap
		);
	}

	function setSellRoot(address addr) external virtual externalMsg onlyOwner {
		_sellRoot = addr;
	}

	function setMethodsCallsFee(uint128 value) external virtual onlyOwner {
		_methodsCallsFee = value;
	}

	function getFeesInfo()
		external
		view
		virtual
		returns (uint128 methodsCallsFee)
	{
		return (_methodsCallsFee);
	}

	function sellRootAddress()
		external
		view
		virtual
		responsible
		returns (address addr)
	{
		return {value: 0, flag: 64, bounce: false} (_sellRoot);
	}

	modifier onlyWithdrawalAddress() {
		require(
			msg.sender == _withdrawalAddress,
			BaseErrors.message_sender_is_not_my_owner
		);
		_;
	}
}
