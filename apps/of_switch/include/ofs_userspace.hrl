%%%-----------------------------------------------------------------------------
%%% @copyright (C) 2012, Erlang Solutions Ltd.
%%% @doc Header file for userspace implementation of OpenFlow switch.
%%% @end
%%%-----------------------------------------------------------------------------

-include_lib("of_protocol/include/of_protocol.hrl").

-record(flow_entry, {
          priority          :: integer(),
          match             :: ofp_match(),
          cookie            :: binary(),
          install_time      :: erlang:timestamp(),
          instructions = [] :: ordsets:ordset(ofp_instruction())
         }).

-record(flow_entry_counter, {
          key                  :: {FlowTableId :: integer(), #flow_entry{}},
          received_packets = 0 :: integer(),
          received_bytes   = 0 :: integer()
         }).

-record(flow_table, {
          id             :: integer(),
          entries = []   :: [#flow_entry{}],
          config  = drop :: ofp_table_config()
         }).

-record(flow_table_counter, {
          id :: integer(),
          %% Reference count is dynamically generated for the sake of simplicity
          %% reference_count = 0 :: integer(),
          packet_lookups = 0 :: integer(),
          packet_matches = 0 :: integer()
         }).

-record(ofs_pkt, {
          fields :: ofp_match(),
          actions = [] :: ordsets:ordset(ofp_action()),
          metadata = << 0:64/integer >> :: binary(),
          size = 0 :: integer(),
          in_port :: integer(),
          packet :: pkt:packet()
         }).

-type ofs_port_type() :: physical | logical | reserved.

-record(ofs_port, {
          number             :: ofp_port_no(),
          type               :: ofs_port_type(),
          pid                :: pid(),
          iface              :: string(),
          port = #ofp_port{} :: ofp_port()
         }).

-record(queue_stats, {
          key            :: {ofp_port_no(), ofp_queue_id()},
          tx_bytes   = 0 :: integer(),
          tx_packets = 0 :: integer(),
          tx_errors  = 0 :: integer()
         }).

-record(ofs_bucket, {
          value   :: ofp_bucket(),
          counter :: ofp_bucket_counter()
         }).

-record(group, {
          id            :: ofp_group_id(),
          type    = all :: ofp_group_type(),
          buckets = []  :: [#ofs_bucket{}]
         }).

-type route_result() :: drop | controller | output.