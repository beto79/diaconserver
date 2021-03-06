%% @author author <author@example.com>
%% @copyright YYYY author.

%% @doc Web server for diaconserver.

-module(diaconserver_web).
-author('author <author@example.com>').

-export([start/1, stop/0, loop/2]).

%% External API

start(Options) ->
    {DocRoot, Options1} = get_option(docroot, Options),
    Loop = fun (Req) ->
                   ?MODULE:loop(Req, DocRoot)
           end,
    mochiweb_http:start([{name, ?MODULE}, {loop, Loop} | Options1]).

stop() ->
    mochiweb_http:stop(?MODULE).

loop(Req, DocRoot) ->
    "/" ++ Path = Req:get(path),
    case Req:get(method) of
        Method when Method =:= 'GET'; Method =:= 'HEAD' ->
            case Path of
				"diaconserver"
				  ->
					%%io:format("-nReq : ~p~n", [Req]),
					Data = Req:parse_qs(),
					io:format("-nData : ~p~n", [Data]),
					Json = proplists:get_value("json", Data),
					Callback = proplists:get_value("callback", Data),
					io:format("-nJson : ~p~n", [Json]),
					Struct = mochijson2:decode(Json),
					io:format("~nStruct : ~p~n", [Struct]),

					A = struct:get_value(<<"action">>, Struct),
					Action = list_to_atom(binary_to_list(A)),
					
					Parameters = struct:get_value(<<"parameters">>, Struct),
					
					Result = diaconactions:Action(Parameters),
					
					EncodedResult = mochijson2:encode(Result),

					DataOut = Callback ++ "("  ++ EncodedResult ++ ")",
					Req:ok({"text/javascript", [], DataOut});

	 
				_->
                    Req:serve_file(Path, DocRoot)
            end;
        'POST' ->
            case Path of
               
				"diaconserver"
				  ->
					io:format("-nReq : ~p~n", [Req]),
					Data = Req:parse_post(),
					io:format("-nData : ~p~n", [Data]),
					Json = proplists:get_value("json", Data),
					io:format("-nJson : ~p~n", [Json]),
					Struct = mochijson2:decode(Json),

					io:format("~nStruct : ~p~n", [Struct]),

					%%A = struct:get_value(<<"action">>, Struct),
					%%Action = list_to_existing_atom(binary_to_list(A)),
								

					%%Result = notes:Action(Struct),

					%%io:format("~nResult : ~p~n", [Result]),

					%%Result = "{"prueba:", "valor"}",
					%%DataOut = mochijson2:encode(Result),
					DataOut = "prueba",

					Req:ok({"application/json", [], [DataOut]});
				_ ->
                    Req:not_found()
            end;
        _ ->
            Req:respond({501, [], []})
    end.

%% Internal API

get_option(Option, Options) ->
    {proplists:get_value(Option, Options), proplists:delete(Option, Options)}.


%%
%% Tests
%%
-include_lib("eunit/include/eunit.hrl").
-ifdef(TEST).
-endif.
