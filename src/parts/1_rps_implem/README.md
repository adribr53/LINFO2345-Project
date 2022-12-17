# [LINFO2345] Project : Random Peer Sampling in ERLANG
# PART 1 : Random Peer Sampling Implementation


## About the project
This project use **escript** to run the erlang application with arguments directly in the terminal.

Make sure you have **escript** correcty installed in your computer (normally installed with erlang itself) before running the program.


## How to compile

To compile the project use the command:

```
make build
```

OR

```
erlc log.erl node.erl view.erl
```


## How to run

To run the program, you can use these commands:

```
make run
```

OR

```
escript runner.erl N_NODE VIEW_FRAC SUBSET_FRAC LOG_FILE WAIT_TIME
```

WHERE:

- `N_NODE` is the total number of node in the network,
- `VIEW_FRAC` is the percentage of nodes present in the view of each node (allows to calculate the size of the view according to `N_NODE`) [0:1]
- `SUBSET_FRAC` is the percentage of nodes in each view which will be shared at the neighboring nodes. [0:1]
- `LOG_FILE` is the name of the logging file.
- `WAIT_TIME` is the time during which the program will run before closing.
