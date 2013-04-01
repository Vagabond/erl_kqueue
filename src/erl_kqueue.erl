-module(erl_kqueue).

-behaviour(gen_server).

-export([start/1, start_link/1]).

-export([init/1, handle_call/3, handle_cast/2, handle_info/2, code_change/3, terminate/2]).

-record(state, {
		port,
		parent,
		ref
	}).

start(File) ->
	Ref = make_ref(),
	gen_server:start(?MODULE, [File, self(), Ref], []),
	Ref.

start_link(File) ->
	Ref = make_ref(),
	gen_server:start_link(?MODULE, [File, self(), Ref], []),
	Ref.

%% gen_server callbacks

init([File, Parent, Ref]) ->
	Dir = case code:priv_dir(?MODULE) of
		{error, bad_name} ->
			EbinDir = filename:dirname(code:which(?MODULE)),
			AppPath = filename:dirname(EbinDir),
			filename:join(AppPath, "priv");
		Path ->
			Path
	end,
	try erlang:open_port({spawn_executable, filename:join(Dir, "erl_kqueue") },
			[exit_status, {args, [File]}]) of
		Port ->
			{ok, #state{port=Port, parent=Parent, ref=Ref}}
		catch
			_:_ ->
				Parent ! {Ref, error},
				ignore
		end.

handle_call(_Msg, _From, State) ->
	{reply, unknown, State}.

handle_cast(_Msg, State) ->
	{noreply, State}.

handle_info({Port, {exit_status, Status}}, State=#state{port=Port, parent=Parent, ref=Ref}) ->
	case Status of
		0 ->
			Parent ! {Ref, changed};
		127 ->
			Parent ! {Ref, bad_port};
		_ ->
			Parent ! {Ref, error}
	end,
	{stop, normal, State}.

code_change(_OldVsn, State, _Extra) ->
	{ok, State}.

terminate(_Reason, _State) ->
	ok.


