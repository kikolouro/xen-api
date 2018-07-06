(** Disallows whitespace around the edges in [of_string] and [t_of_sexp], but doesn't
    check when reading from bin_io. *)

open! Import
open Std_internal

module type S = sig
  type t = private string [@@deriving hash]
  include Identifiable with type t := t

  module Stable : sig
    module V1 : sig
      type nonrec t = t [@@deriving hash]
      include Stable_comparable.V1
        with type t := t
        with type comparator_witness = comparator_witness
    end
  end
end

module type String_id = sig
  module type S = S

  include S

  (** [Make] customizes the error messages generated by [of_string]/[of_sexp] to include
      [module_name].  It also registers a pretty printer. *)
  module Make (M : sig val module_name : string end) () : S

  (** [Make_with_validate] is like [Make], but modifies [of_string]/[of_sexp]/[bin_read_t]
      to raise if [validate] returns an error.  Before using this functor
      one should be mindful of the performance implications (the [validate] function
      will run every time an instance is created) as well as potential versioning issues
      (when [validate] changes old binaries still run the old version of the function). *)
  module Make_with_validate (M : sig
      val module_name : string
      val validate : string -> unit Or_error.t
    end) () : S

  (** This does what [Make] does without registering a pretty printer.  Use this when the
      module that is made is not exposed in mli.  Registering a pretty printer without
      exposing it causes an error in utop. *)
  module Make_without_pretty_printer (M : sig val module_name : string end) () : S

  (** See [Make_with_validate] and [Make_without_pretty_printer] *)
  module Make_with_validate_without_pretty_printer (M : sig
      val module_name : string
      val validate : string -> unit Or_error.t
    end) () : S
end
