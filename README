Slides at http://www.slideshare.net/bosky101/recursion-and-erlang

Install erlang
    sudo apt-get install erlang
    OR brew install erlang
    OR download from http://erlang.org

Clone this repo and compile

    git clone https://github.com/bosky101/fuconf
    cd fuconf
    erlc fuconf.erl

on terminal1

    erl
    > fuconf:start().
    server listening on 8021

on terminal 2

    > fuconf:client(<<"hello">>).
    client_loop got <<"echo hello">>

run a function forever

    > fuconf:do_something_every_second_daemon().
    . . . . . .
