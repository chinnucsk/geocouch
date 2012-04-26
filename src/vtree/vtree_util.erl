% Licensed under the Apache License, Version 2.0 (the "License"); you may not
% use this file except in compliance with the License. You may obtain a copy of
% the License at
%
%   http://www.apache.org/licenses/LICENSE-2.0
%
% Unless required by applicable law or agreed to in writing, software
% distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
% WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
% License for the specific language governing permissions and limitations under
% the License.

% This module implements a split algorithm for the vtree. It is an
% implementation of the split algorithm described in:
% A Revised R * -tree in Comparison with Related Index Structures
% by Norbert Beckmann, Bernhard Seeger

-module(vtree_util).

-include("couch_db.hrl").

-export([calc_mbb/2, min/2, max/2]).


-spec min(Tuple::{any(), any()} | [any()], Less::fun()) -> Min::any().
min({A, B}, Less) ->
    case Less(A, B) of
        true -> A;
        false -> B
    end;
min([H|T], Less) ->
    min(T, Less, H).
-spec min(List::[any()], Less::fun(), Min::any()) -> Min::any().
min([], _Less, Min) ->
    Min;
min([H|T], Less, Min) ->
    Min2 = case Less(H, Min) of
               true -> H;
               false -> Min
           end,
    min(T, Less, Min2).

-spec max(Tuple::{any(), any()} | [any()], Less::fun()) -> Max::any().
max({A, B}, Less) ->
    case Less(A, B) of
        true -> B;
        false -> A
    end;
max([H|T], Less) ->
    max(T, Less, H).
-spec max(List::[any()], Less::fun(), Max::any()) -> Max::any().
max([], _Less, Max) ->
    Max;
max([H|T], Less, Max) ->
    Max2 = case Less(H, Max) of
               true -> Max;
               false -> H
           end,
    max(T, Less, Max2).

% Calculate the enclosing bounding box from a list of bounding boxes
-spec calc_mbb(List::[[{any(), any()}]], Less::fun()) -> [{any(), any()}].
calc_mbb([H|T], Less) ->
    calc_mbb(T, Less, H).
-spec calc_mbb(List::[[{any(), any()}]], Less::fun(),  Mbb::[{any(), any()}])
              -> Mbb::[{any(), any()}].
calc_mbb([], _Less, Mbb) ->
    Mbb;
calc_mbb([H|T], Less, Mbb) ->
    Mbb2 = lists:map(
             fun({{Min, Max}, {MinMbb, MaxMbb}}) ->
                     {?MODULE:min({Min, MinMbb}, Less),
                      ?MODULE:max({Max, MaxMbb}, Less)}
             end, lists:zip(H, Mbb)),
    calc_mbb(T, Less, Mbb2).
