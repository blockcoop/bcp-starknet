%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.cairo.common.uint256 import Uint256, uint256_lt, uint256_eq
from starkware.cairo.common.alloc import alloc
from starkware.cairo.common.bool import TRUE
from starkware.cairo.common.math import assert_lt, assert_le
from starkware.cairo.common.math_cmp import is_le
from starkware.starknet.common.syscalls import (get_caller_address, get_block_timestamp)

from openzeppelin.token.erc20.library import ERC20


struct Task:
    member creator: felt
    member details: felt
    member voting_deadline: felt
    member task_deadline: felt
end

@storage_var
func coop_initiator() -> (address: felt):
end

@storage_var
func initial_mint() -> (value: felt):
end

@storage_var
func quorum() -> (value: felt):
end

@storage_var
func supermajority() -> (value: felt):
end

@storage_var
func members_count() -> (count: felt):
end

@storage_var
func members(index: felt) -> (account: felt):
end

@storage_var
func tasks_count() -> (count: felt):
end

@storage_var
func tasks(index: felt) -> (task: Task):
end

# vote:- 0:not_voted, 1:yes, 2:no
@storage_var
func votes(task_id: felt, account: felt) -> (vote: felt):
end

@storage_var
func yes_votes(task_id: felt) -> (count: felt):
end

@storage_var
func no_votes(task_id: felt) -> (count: felt):
end

# task status:- 0:proposed, 1:not_accepted, 2:cancelled, 3:started, 4:failed, 5:completed
@storage_var
func task_status(task_id: felt) -> (status: felt):
end


@constructor
func constructor{
    syscall_ptr : felt*,
    pedersen_ptr : HashBuiltin*,
    range_check_ptr,
}(name_ : felt, symbol_ : felt, initial_mint_: felt, coop_initiator_: felt, quorum_: felt, supermajority_: felt):
    assert_lt(supermajority_, 100)
    assert_lt(quorum_, 100)
    coop_initiator.write(coop_initiator_)
    initial_mint.write(initial_mint_)
    quorum.write(quorum_)
    supermajority.write(supermajority_)
    ERC20.initializer(name_, symbol_, 18)
    let (current_count) = members_count.read()
    members_count.write(value=current_count + 1)
    members.write(current_count + 1, coop_initiator_)
    ERC20._mint(coop_initiator_, Uint256(initial_mint_, 0))
    return ()
end

@view
func name{
        syscall_ptr : felt*,
        pedersen_ptr : HashBuiltin*,
        range_check_ptr
    }() -> (value: felt):
    let (value) = ERC20.name()
    return (value)
end

@view
func symbol{
        syscall_ptr : felt*,
        pedersen_ptr : HashBuiltin*,
        range_check_ptr
    }() -> (value: felt):
    let (value) = ERC20.symbol()
    return (value)
end

@view
func totalSupply{
        syscall_ptr : felt*,
        pedersen_ptr : HashBuiltin*,
        range_check_ptr
    }() -> (totalSupply: Uint256):
    let (totalSupply: Uint256) = ERC20.total_supply()
    return (totalSupply)
end

@view
func decimals{
        syscall_ptr : felt*,
        pedersen_ptr : HashBuiltin*,
        range_check_ptr
    }() -> (decimals: felt):
    let (decimals) = ERC20.decimals()
    return (decimals)
end

@view
func balanceOf{
        syscall_ptr : felt*,
        pedersen_ptr : HashBuiltin*,
        range_check_ptr
    }(account: felt) -> (balance: Uint256):
    let (balance: Uint256) = ERC20.balance_of(account)
    return (balance)
end

@view
func allowance{
        syscall_ptr : felt*,
        pedersen_ptr : HashBuiltin*,
        range_check_ptr
    }(owner: felt, spender: felt) -> (remaining: Uint256):
    let (remaining: Uint256) = ERC20.allowance(owner, spender)
    return (remaining)
end

@view
func coopInitiator{
        syscall_ptr : felt*,
        pedersen_ptr : HashBuiltin*,
        range_check_ptr
    }() -> (initiator: felt):
    let (initiator) = coop_initiator.read()
    return (initiator)
end

@view
func initialMint{
        syscall_ptr : felt*,
        pedersen_ptr : HashBuiltin*,
        range_check_ptr
    }() -> (value: felt):
    let (value) = initial_mint.read()
    return (value)
end

@view
func getQuorum{
        syscall_ptr : felt*,
        pedersen_ptr : HashBuiltin*,
        range_check_ptr
    }() -> (value: felt):
    let (value) = quorum.read()
    return (value)
end

@view
func getSupermajority{
        syscall_ptr : felt*,
        pedersen_ptr : HashBuiltin*,
        range_check_ptr
    }() -> (value: felt):
    let (value) = supermajority.read()
    return (value)
end

@view
func getMembers{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}() -> (array_len: felt, array: felt*):
    alloc_locals
    let (array_len) = members_count.read()
    let (local array : felt*) = alloc()
    array_values(array_len, array)
    return (array_len, array)
end

func array_values{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(array_len : felt, array : felt*):
    if array_len == 0:
        return ()
    end

    let (item) = members.read(array_len)
    assert [array] = item

    return array_values(array_len - 1, array + 1)
end

@view
func getTaskCount{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}() -> (count: felt):
    let (count) = tasks_count.read()
    return (count)
end

@view
func getTask{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(task_id: felt) -> (task: Task):
    let (count) = tasks_count.read()
    assert_le(task_id, count)
    let (task) = tasks.read(task_id)
    return (task)
end

@view
func getTaskStatus{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(task_id: felt) -> (status: felt):
    let (count) = tasks_count.read()
    assert_le(task_id, count)
    let (status) = task_status.read(task_id)
    return (status)
end

@view
func isVoted{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(task_id: felt, account: felt) -> (voted: felt):
    let (count) = tasks_count.read()
    assert_le(task_id, count)
    let (vote) = votes.read(task_id, account)
    if vote == 0:
        return (0)
    else:
        return (1)
    end
end

#
# Externals
#

# @external
# func transfer{
#         syscall_ptr : felt*,
#         pedersen_ptr : HashBuiltin*,
#         range_check_ptr
#     }(recipient: felt, amount: Uint256) -> (success: felt):
#     ERC20.transfer(recipient, amount)
#     return (TRUE)
# end

# @external
# func transferFrom{
#         syscall_ptr : felt*,
#         pedersen_ptr : HashBuiltin*,
#         range_check_ptr
#     }(
#         sender: felt,
#         recipient: felt,
#         amount: Uint256
#     ) -> (success: felt):
#     ERC20.transfer_from(sender, recipient, amount)
#     return (TRUE)
# end

@external
func approve{
        syscall_ptr : felt*,
        pedersen_ptr : HashBuiltin*,
        range_check_ptr
    }(spender: felt, amount: Uint256) -> (success: felt):
    ERC20.approve(spender, amount)
    return (TRUE)
end

@external
func increaseAllowance{
        syscall_ptr : felt*,
        pedersen_ptr : HashBuiltin*,
        range_check_ptr
    }(spender: felt, added_value: Uint256) -> (success: felt):
    ERC20.increase_allowance(spender, added_value)
    return (TRUE)
end

@external
func decreaseAllowance{
        syscall_ptr : felt*,
        pedersen_ptr : HashBuiltin*,
        range_check_ptr
    }(spender: felt, subtracted_value: Uint256) -> (success: felt):
    ERC20.decrease_allowance(spender, subtracted_value)
    return (TRUE)
end

@external
func join_coop{
    syscall_ptr: felt*,
    pedersen_ptr: HashBuiltin*,
    range_check_ptr
}():
    alloc_locals
    let (local address) = get_caller_address()
    let (balance: Uint256) = ERC20.balance_of(address)
    let (is_new) = uint256_eq(Uint256(0, 0), balance)
    assert is_new = 1
    let (count) = members_count.read()
    members_count.write(count + 1)
    members.write(count + 1, address)
    let (_initial_mint) = initial_mint.read()
    ERC20._mint(address, Uint256(_initial_mint, 0))
    return ()
end

@external
func create_task{
    syscall_ptr: felt*,
    pedersen_ptr: HashBuiltin*,
    range_check_ptr
}(details_: felt, voting_deadline_: felt, task_deadline_: felt):
    alloc_locals
    let (current_time) = get_block_timestamp()
    assert_lt(current_time, voting_deadline_)
    assert_lt(voting_deadline_, task_deadline_)
    let (local address) = get_caller_address()
    
    let task = Task(
        creator=address,
        details=details_,
        voting_deadline=voting_deadline_,
        task_deadline=task_deadline_,
    )

    let (count) = tasks_count.read()
    tasks.write(count + 1, task)
    tasks_count.write(count + 1)
    return ()
end

@external
func vote_for_task{
    syscall_ptr: felt*,
    pedersen_ptr: HashBuiltin*,
    range_check_ptr
}(task_id: felt, vote: felt):
    alloc_locals
    assert (vote - 0) * (vote - 1) = 0
    let (task) = tasks.read(task_id)
    let (status) = task_status.read(task_id)
    assert status = 0
    let (address) = get_caller_address()
    let (balance: Uint256) = ERC20.balance_of(address)
    let (is_member) = uint256_lt(Uint256(0, 0), balance)
    assert is_member = 1
    tempvar syscall_ptr = syscall_ptr
    let (count) = tasks_count.read()
    assert_le(task_id, count)
    let (current_vote) = votes.read(task_id, address)
    assert current_vote = 0
    let (current_time) = get_block_timestamp()
    assert_lt(current_time, task.voting_deadline)
    
    votes.write(task_id, address, vote)
    if vote == 0:
        let (vote_count) = no_votes.read(task_id)
        no_votes.write(task_id, vote_count + 1)
    else:
        let (vote_count) = yes_votes.read(task_id)
        yes_votes.write(task_id, vote_count + 1)
    end
    return ()
end

@external
func process_voting{
    syscall_ptr: felt*,
    pedersen_ptr: HashBuiltin*,
    range_check_ptr
}(task_id: felt):
    alloc_locals
    let (task) = tasks.read(task_id)
    let (status) = task_status.read(task_id)
    assert status = 0
    let (current_time) = get_block_timestamp()
    assert_lt(task.voting_deadline, current_time)
    let (address) = get_caller_address()
    assert address = task.creator

    let (mem_count) = members_count.read()
    let (quorum_) = quorum.read()
    let min_votes = mem_count * quorum_

    let (yes) = yes_votes.read(task_id)
    let (local no) = no_votes.read(task_id)

    let (eligible) = is_le(min_votes, (yes+no)*100)
    if eligible == 1:
        let (win) = is_le(no, yes + 1)
        if win == 1:
            task_status.write(task_id, 3)
        else:
            task_status.write(task_id, 2)
        end
    else:
        task_status.write(task_id, 1)
    end

    return ()
end

@external
func process_task{
    syscall_ptr: felt*,
    pedersen_ptr: HashBuiltin*,
    range_check_ptr
}(task_id: felt, isCompleted: felt):
    assert (isCompleted - 0) * (isCompleted - 1) = 0
    let (task) = tasks.read(task_id)
    let (current_time) = get_block_timestamp()
    assert_lt(task.task_deadline, current_time)
    let (address) = get_caller_address()
    assert address = task.creator

    if isCompleted == 1:
        task_status.write(task_id, 5)
    else:
        task_status.write(task_id, 4)
    end
    return ()
end

# task status:- 0:proposed, 1:not_accepted, 2:cancelled, 3:started, 4:failed, 5:completed

# Contract class hash: 0xd458fce34237633ac741c11baba5990c7d21c507132b824410ea40ad5bd750