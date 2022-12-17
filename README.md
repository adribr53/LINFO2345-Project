# [LINFO2345] Project : Random Peer Sampling in ERLANG
# Developer Section


## About the project
This project use **escript** to run the erlang application with arguments directly in the terminal.

Make sure you have **escript** correcty installed in your computer (normally installed with erlang itself) before running the program.


## How to compile

To compile the project, use the command:

```
make build
```


## How to run

To run the program (First Part), you can use the command:

```
make run1
```

To run the program (Second Part), you can use the command:

```
make run2
```


### Run without Makefile (Or modify variables directly)

```
escript src/parts/2_byzantine_nodes_problem/runner.erl N_NODE BYZ_FRAC VIEW_FRAC SUBSET_FRAC LOG_FILE WAIT_TIME
```

WHERE

- `N_NODE` is the total number of node in the network,
- `BYZ_FRAC` is the percentage of byzantine nodes in the total number of node in the network [0;1],
- `VIEW_FRAC` is the percentage of nodes present in the view of each node (allows to calculate the size of the view according to `N_NODE`) [0:1]
- `SUBSET_FRAC` is the percentage of nodes in each view which will be shared at the neighboring nodes. [0:1]
- `LOG_FILE` is the name of the logging file.
- `WAIT_TIME` is the time during which the program will run before closing.
