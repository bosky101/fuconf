%% git clone https://github.com/bosky101/fuconf
%% sudo apt-get install erlang OR brew install erlang
%% cd fuconf
-module(fuconf).

-compile([export_all]).

%% variables must be upper case
%% functions, atoms in lower case
increment(X)->
    X+1.

do_something()->
    %% just print a dot
    io:format(".").

wait_for_a_second()->
    timer:sleep(1000).

%% a pointless daemon, but a daemon no less
daemon()->
    daemon().

do_something_every_second_daemon()->
    do_something(),
    wait_for_a_second(),
    do_something_every_second_daemon().

%% erlc fuconf.erl && erl -s fuconf
start()->
    spawn(fun()->
                  %listen()
                  %listen_forever()
                  listen_forever_concurrent()
          end),

    %%client(<<"foo">>).
    ok.

%% a constant
-define(TCP_OPTS, [binary,{packet,4},{reuseaddr, true}]).

client(Msg)->
    {ok,S} = gen_tcp:connect("localhost", 8021, ?TCP_OPTS),
    gen_tcp:send(S, Msg),
    client_loop().

client_loop()->
    receive
        {tcp_closed,_}->
            client_loop();
        {tcp,_,Incoming} ->
            io:format("~n client_loop got ~p~n",[Incoming]),
            ok;
        _ ->
            %% unexpected
            client_loop()
    after 5000 ->
            io:format("~n client timed out after 5 secs",[]),
            ok
    end.

increment_till_100_forever(100)->
    increment_till_100_forever(0);
increment_till_100_forever(X)->
    increment_till_100_forever(X+1).

recv()->
    receive
        _X ->
            %% means than other processes
            %% can message pass anything here
            ok
    end.

recv_forever()->
    receive
        _X ->
            recv_forever()
    end.

recv_and_increment_forever(Sum)->
    receive
        _X ->
            recv_and_increment_forever(Sum+1)
    end.

listen()->
    {ok,ListenSocket} = gen_tcp:listen(8021,?TCP_OPTS),
    {ok,_Socket} = gen_tcp:accept(ListenSocket).

recv_and_echo()->
    receive
        {tcp, Socket, Incoming} ->
            gen_tcp:send(Socket, <<"echo ", Incoming/binary>>),
            gen_tcp:close(Socket)
    end.

listen_forever()->
    {ok,ListenSocket} = gen_tcp:listen(8021,?TCP_OPTS),
    accept_loop(ListenSocket).

accept_loop(ListenSocket)->
    case gen_tcp:accept(ListenSocket) of
        {ok,Socket} ->
            handler(ListenSocket, Socket),
            accept_loop(ListenSocket);
        {error,Reason} ->
            io:format("cant accept since error: ~p",[Reason])
    end.

handler(ListenSocket, Socket) ->
    receive
        {tcp_closed, Closed}->
            io:format("~n closed ~p, listening ~p accepted ~p",[Closed,ListenSocket,Socket]),
            accept_loop(ListenSocket);
        {tcp, Socket, Incoming} ->
            gen_tcp:send(Socket, <<"echo ", Incoming/binary >>);
        Request ->
            io:format("~nreceived: ~p~n", [Request])
    end.


listen_forever_concurrent()->
    {ok,ListenSocket} = gen_tcp:listen(8021,?TCP_OPTS),
    accept_loop_concurrent(ListenSocket).

accept_loop_concurrent(ListenSocket)->
    case gen_tcp:accept(ListenSocket) of
        {ok,Socket} ->
            Pid = spawn(?MODULE, handler, [ListenSocket,Socket]),
            gen_tcp:controlling_process(Socket, Pid),
            accept_loop_concurrent(ListenSocket);
        {error,Reason} ->
            io:format("cant accept since error: ~p",[Reason])
    end.


child_daemon()->
    child_daemon().

fork()->
    spawn(fun()->
                  child_daemon()
          end).

foo()->
    io:format(".",[]),
    foo().

bar()->
    io:format("x",[]),
    bar().

get_ok()->
    foo(),  %% hi, i am self()::<pid>
    bar(),  %% still in same process
            %% if the last expression if not a function or receive
    ok.     %% the process ends.

run_get_ok()->
    get_ok(). %% returns ok, so the process ends here

bar(0)->       %% this is a guard clause
    ok;        %% process ends when X = 0
bar(X)->
    do_something_with(X),
    bar(X-1).  %% stayin 'alive

do_something_with(X)->
    X.


%% TODO
%% a fault-tolerant tcp client that sends data over a tcp socket
%% if the server is unreachable, buffer data and resend when up

send_foo(_Foo)->
    %%TODO
    ok.

send_foo_N_times(_N)->
    %%TODO
    ok.

send_foo_N_times_with_retry(_N)->
    %%TODO
    ok.
