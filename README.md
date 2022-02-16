# Challenge #12 - Climber

There's a secure vault contract guarding 10 million DVT tokens. The vault is upgradeable, following the UUPS pattern.

The owner of the vault, currently a timelock contract, can withdraw a very limited amount of tokens every 15 days.

On the vault there's an additional role with powers to sweep all tokens in case of an emergency.

On the timelock, only an account with a "Proposer" role can schedule actions that can be executed 1 hour later.

Your goal is to empty the vault.

# Solution

The exploit here is related to the fact that in the ClimberTimelock contract, in the `execute` function, the

```
for (uint8 i = 0; i < targets.length; i++) {
    targets[i].functionCallWithValue(dataElements[i], values[i]);
}
```

loop is located before the function that verify if operationis ready for execution `require(getOperationState(id) == OperationState.ReadyForExecution);`

1/ calling the update delay function we will change the delay to 0.

2/ we will change proposer role of timelock contract to the timelock contract itself in order to then be able to add our call to the execute function as ReadyForExecution.

3/ Timelock contract is owner of the vault contract, using this exploit will be able to change ownership of the vault contract in order to be able then to upgrade it with our attacker address

4/ Upgrade with a proxy that let you change the sweeper and sweep the fund with the address of your wish
