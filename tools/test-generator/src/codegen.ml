open Core

open Model
open Yojson.Basic

type edit_parameters_function = (string * json) list -> (string * string) list

type subst = Subst of string [@@deriving eq, show]

let subst_to_string (Subst s) = s

let map_subst (s: subst) ~(f: string -> string): subst =
  Subst (subst_to_string s |> f)

let replace_key (key: string) (value: string) (target: string): string =
  let replace = String.substr_replace_all ~with_:value in
  replace ~pattern:("$" ^ key) target |> replace ~pattern:("$(" ^ key ^ ")")

let rec replace_keys (ed: edit_parameters_function) (s: string) (suite_name: string) (c: case): subst =
  let s = replace_key "description" c.description s in
  let s = replace_key "suite-name" suite_name s in
  let parameter_strings = ed @@ List.map ~f:(fun (k,p) -> (k,p)) c.parameters in
  List.fold parameter_strings ~init:(Subst s) ~f:(fun (Subst s) (k,v) -> Subst (replace_key k v s))

let fill_in_template (ed: edit_parameters_function) (test_template: string) (suite_name: string) (cases: case list) =
  List.map cases ~f:(replace_keys ed test_template suite_name)
