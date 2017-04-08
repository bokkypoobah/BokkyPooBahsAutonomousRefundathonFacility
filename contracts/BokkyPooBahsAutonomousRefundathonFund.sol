pragma solidity ^0.4.8;

// ----------------------------------------------------------------------------------------------
// BokkyPooBah's Autonomous Refundathon Fund Token Contract 
//
// Based on Vlad's Safe Token Sale Mechanism Contract
// - https://medium.com/@Vlad_Zamfir/a-safe-token-sale-mechanism-8d73c430ddd1
//
// NOTE that this contract has not been security tested
//
// Enjoy. (c) Bok Consulting Pty Ltd 2017. The MIT Licence.
// ----------------------------------------------------------------------------------------------


contract Owned {
    address public owner;
    event OwnershipTransferred(address indexed _from, address indexed _to);

    function Owned() {
        owner = msg.sender;
    }

    modifier onlyOwner {
        if (msg.sender != owner) throw;
        _;
    }

    function transferOwnership(address newOwner) onlyOwner {
        OwnershipTransferred(owner, newOwner);
        owner = newOwner;
    }
}


// ERC Token Standard #20 Interface - https://github.com/ethereum/EIPs/issues/20
contract ERC20Token is Owned {
    uint256 _totalSupply = 0;

    // Balances for each account
    mapping(address => uint256) balances;

    // Owner of account approves the transfer of an amount to another account
    mapping(address => mapping (address => uint256)) allowed;

    // Get the total token supply
    function totalSupply() constant returns (uint256 totalSupply) {
        totalSupply = _totalSupply;
    }

    // Get the account balance of another account with address _owner
    function balanceOf(address _owner) constant returns (uint256 balance) {
        return balances[_owner];
    }

    // Send _value amount of tokens to address _to
    function transfer(address _to, uint256 _amount) returns (bool success) {
        if (balances[msg.sender] >= _amount 
            && _amount > 0
            && balances[_to] + _amount > balances[_to]) {
            balances[msg.sender] -= _amount;
            balances[_to] += _amount;
            Transfer(msg.sender, _to, _amount);
            return true;
        } else {
            return false;
        }
    }

    // Allow _spender to withdraw from your account, multiple times, up to the _value amount.
    // If this function is called again it overwrites the current allowance with _value.
    // this function is required for some DEX functionality
    function approve(address _spender, uint256 _amount) returns (bool success) {
        allowed[msg.sender][_spender] = _amount;
        Approval(msg.sender, _spender, _amount);
        return true;
    }

    // Spender of tokens transfer an amount of tokens from the token owner's 
    // balance to the spender's account. The owner of the tokens must already
    // have approve(...)-d this transfer
    function transferFrom(
        address _from,
        address _to,
        uint256 _amount
    ) returns (bool success) {
        if (balances[_from] >= _amount
            && allowed[_from][msg.sender] >= _amount
            && _amount > 0
            && balances[_to] + _amount > balances[_to]) {
            balances[_from] -= _amount;
            allowed[_from][msg.sender] -= _amount;
            balances[_to] += _amount;
            Transfer(_from, _to, _amount);
            return true;
        } else {
            return false;
        }
    }

    // Returns the amount of tokens approved by the owner that can be transferred
    // to the spender's account
    function allowance(address _owner, address _spender) constant returns (uint256 remaining) {
        return allowed[_owner][_spender];
    }
    
    // Triggered when tokens are transferred.
    event Transfer(address indexed _from, address indexed _to, uint256 _value);

    // Triggered whenever approve(address _spender, uint256 _value) is called.
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
}


contract BokkyPooBahsAutonomousRefundathonFund is ERC20Token {

    // ------ Token information ------
    string public constant symbol = "BARF";
    string public constant name = "BokkyPooBah Autonomous Refundathon Fund";
    uint8 public constant decimals = 18;


    /*
    // ------ Propose and activate proposalPeriod below ------
    uint256 public proposalPeriod = 7 days;
    uint256 public proposedProposalPeriod;
    uint256 public activateProposedProposalPeriodAfter;

    function ownerProposeProposalPeriod(uint256 _proposedProposalPeriod) onlyOwner {
        proposedProposalPeriod = _proposedProposalPeriod;
        activateProposedProposalPeriodAfter = now + proposalPeriod;
        ProposalPeriodProposed(proposedProposalPeriod, activateProposedProposalPeriodAfter);
    }
    event ProposalPeriodProposed(uint256 proposedProposalPeriod, uint256 activationAfter);

    function activateProposedProposalPeriod() onlyOwner {
        if (now <= activateProposedProposalPeriodAfter) throw;
        proposalPeriod = proposedProposalPeriod;
        activateProposedProposalPeriodAfter = 0;
        ProposalPeriodActivated(proposalPeriod);
    }
    event ProposalPeriodActivated(uint256 proposalPeriod);
    */

    // Members buy tokens from this contract at this price
    function uint256 buyPrice() {
        return 105 * 10**16; // Starting off at 1.05 ETH per token
    }
    
    // Members sell tokens to this contract at this price
    function uint256 sellPrice() {
        return 95 * 10**16; // Starting off at 0.95 ETH per token
        
    }


    /*
    // ------ Propose and activate buyPrice and sellPrice below ------
    // Contract sells at buyPrice, members buy at buyPrice
    // Contract buys at sellPrice, members sell at sellPrice
    // buyPrice must be higher that sellPrice
    uint256 public buyPrice = 105 * 10**16; // Starting off at 1.05 ETH per token
    uint256 public sellPrice = 95 * 10**16; // Starting off at 0.95 ETH per token
    uint256 public proposedBuyPrice;
    uint256 public proposedSellPrice;
    uint256 public activateProposedBuyAndSellPriceAfter;

    function ownerProposeBuyAndSellPrice(
        uint256 _proposedBuyPrice, 
        uint256 _proposedSellPrice
    ) onlyOwner {
        if (_proposedBuyPrice == 0 || _proposedSellPrice == 0) throw;
        if (_proposedBuyPrice < _proposedSellPrice) throw;
        proposedBuyPrice = _proposedBuyPrice;
        proposedSellPrice = _proposedSellPrice;
        activateProposedBuyAndSellPriceAfter = now + proposalPeriod;
        BuyAndSellPriceProposed(proposedBuyPrice, proposedSellPrice, 
            activateProposedBuyAndSellPriceAfter);
    }
    event BuyAndSellPriceProposed(uint256 buyPrice, uint256 sellPrice, 
        uint256 activationAfter);

    function activateProposedBuyAndSellPrice() onlyOwner {
        if (now < activateProposedBuyAndSellPriceAfter) throw;
        buyPrice = proposedBuyPrice;
        sellPrice = proposedSellPrice;
        activateProposedBuyAndSellPriceAfter = 0;
        BuyAndSellPriceActivated(buyPrice, sellPrice);
    }
    event BuyAndSellPriceActivated(uint256 buyPrice, uint256 sellPrice);
    */

    /*
    // ------ Propose and activate buyPrice and sellPrice below ------
    uint256 public withdrawn;
    uint256 public proposedWithdrawal;
    uint256 public withdrawalActiveAfter;

    function ownerProposeWithdrawal(uint256 _proposedWithdrawal) onlyOwner {
        proposedWithdrawal = _proposedWithdrawal;
        withdrawalActiveAfter = now + proposalPeriod;
        WithdrawalProposed(proposedWithdrawal, withdrawalActiveAfter);
    }
    event WithdrawalProposed(uint256 proposedWithdrawal, uint256 withdrawalActiveAfter);

    function ownerWithdrawOld(uint256 amount) onlyOwner {
        if (now < withdrawalActiveAfter) throw;
        if ((withdrawn + amount) > proposedWithdrawal) throw;
        withdrawn += amount;
        if (!owner.send(amount)) throw;
        WithdrawnOld(amount, proposedWithdrawal - withdrawn);
    }
    event WithdrawnOld(uint256 amount, uint256 remainingWithdrawal);
    */

    // ------ Owner Withdrawal ------
    
    function amountOfEthersOwnerCanWithdraw() constant returns (uint256) {
        uint256 etherBalance = this.balance;
        uint256 ethersSupportingTokens = _totalSupply * sellPrice() / 1 ether;
        if (etherBalance > ethersSupportingTokens) {
            return etherBalance - ethersSupportingTokens;
        } else {
            return 0;
        }
    }
    
    function ownerWithdraw(uint256 amount) onlyOwner {
        uint256 maxWithdrawalAmount = amountOfEthersOwnerCanWithdraw();
        if (amount > maxWithdrawalAmount) {
            amount = maxWithdrawalAmount;
        }
        if (!owner.send(amount)) throw;
        Withdrawn(amount, maxWithdrawalAmount - amount);
    }
    event Withdrawn(uint256 amount, uint256 remainingWithdrawal);
    
    
    // ------ Member Buy and Sell tokens below ------
    function () payable {
        memberBuyToken();    
    }

    function memberBuyToken() payable {
        if (msg.value > 0) {
            uint tokens = msg.value * buyPrice() / 1 ether;
            _totalSupply += tokens;
            balances[msg.sender] += tokens;
            MemberBoughtToken(msg.sender, msg.value, this.balance, tokens, _totalSupply,
                buyPrice());
        }
    }
    // TODO: Remix does not handle address indexed. Add back in later
    event MemberBoughtToken(address buyer, uint256 ethers, uint256 newEtherBalance, 
        uint256 tokens, uint256 newTotalSupply, uint256 buyPrice);

    function amountOfTokensMemberCanSell() constant returns (uint256) {
        uint256 result = 0;
        uint256 membersTokens = balances[msg.sender];
        if (membersTokens > 0) {
            uint256 amountOfTokensContractCanSell = this.balance * 1 ether / sellPrice();
            if (amountOfTokensContractCanSell > membersTokens) {
                result = membersTokens;
            } else {
                result = amountOfTokensContractCanSell;
            }
        }
        return result;
    }

    function memberSellToken(uint256 amountOfTokens) {
        uint256 _amountOfTokensMemberCanSell = amountOfTokensMemberCanSell();
        if (amountOfTokens > _amountOfTokensMemberCanSell) throw;
        balances[msg.sender] -= amountOfTokens;
        _totalSupply -= amountOfTokens;
        uint256 ethersToSend = amountOfTokens * sellPrice() / 1 ether;
        if (!msg.sender.send(ethersToSend)) throw;
        MemberSoldToken(msg.sender, ethersToSend, this.balance, amountOfTokens,
            _totalSupply, sellPrice());
    }
    // TODO: Remix does not handle address indexed. Add back in later
    event MemberSoldToken(address seller, uint256 ethers, uint256 newEtherBalance, 
        uint256 tokens, uint256 newTotalSupply, uint256 sellPrice);


    // ------ Information function ------
    function currentEtherBalance() constant returns (uint256) {
        return this.balance;
    }

    function currentTokenBalance() constant returns (uint256) {
        return _totalSupply;
    }
}
