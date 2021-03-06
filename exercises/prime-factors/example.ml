open Core

let square_root_trunc n =
    (* Square root is not defined on int64 *)
    Int64.to_float n |> sqrt |> Int64.of_float

let rec factors_of' = function
    | 1L -> []
    | n  -> factors_of_loop n
and factors_of_loop n =
    let open Int64 in
    let i = ref (square_root_trunc n) in
    let res = ref None in
    while !i > 1L && Option.is_none !res do
        let i' = !i in
        if (rem n i') = 0L then (
            let m = n / i' in
            res := Some (List.concat [factors_of' i'; factors_of' m]));
        i := (i' - 1L);
    done;
    Option.value ~default:[n] !res

let factors_of n = List.sort ~cmp:Int64.compare (factors_of' n)
