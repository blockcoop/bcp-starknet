%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.cairo.common.math import assert_not_zero
from starkware.cairo.common.alloc import alloc
from starkware.starknet.common.syscalls import get_caller_address, deploy

@storage_var
func total_balance() -> (balance: felt):
end

@storage_var
func balance_of(account: felt) -> (balance: felt):
end

@storage_var
func name(account: felt) -> (value: felt):
end

@view
func get_total_balance{
    syscall_ptr : felt*,
    pedersen_ptr : HashBuiltin*,
    range_check_ptr,
}() -> (balance: felt):
    let (balance) = total_balance.read()
    return (balance)
end

@view
func get_balance{
    syscall_ptr : felt*,
    pedersen_ptr : HashBuiltin*,
    range_check_ptr,
}(account: felt) -> (balance: felt):
    let (balance) = balance_of.read(account)
    return (balance)
end

@view
func get_name{
    syscall_ptr : felt*,
    pedersen_ptr : HashBuiltin*,
    range_check_ptr,
}(account: felt) -> (value: felt):
    let (value) = name.read(account)
    return (value)
end

@external
func update_balance{
    syscall_ptr : felt*,
    pedersen_ptr : HashBuiltin*,
    range_check_ptr,
}(amount: felt):
    let (balance) = total_balance.read()
    let (account) = get_caller_address()

    balance_of.write(account, amount)
    total_balance.write(balance + amount)

    return ()
end

@external
func update_name{
    syscall_ptr : felt*,
    pedersen_ptr : HashBuiltin*,
    range_check_ptr,
}(name_: felt):
    let (account) = get_caller_address()
    name.write(account, name_)
    return ()
end

# Contract address: 0x02b009b31adc59ecd095d7453417610601082229dda81695c435db8b5f988375
# Transaction hash: 0x37c08d3c66d0fee0ac588cb1b7afabf175542b0ca90a69b1ac8e8d3d8b9ec2b