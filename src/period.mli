(**************************************************************************)
(*                                                                        *)
(*  This file is part of Calendar.                                        *)
(*                                                                        *)
(*  Copyright (C) 2003-2008 Julien Signoles                               *)
(*                                                                        *)
(*  you can redistribute it and/or modify it under the terms of the GNU   *)
(*  Lesser General Public License as published by the Free Software       *)
(*  Foundation, either version 2.1 of the Licence, or (at your option)    *)
(*  version 3.                                                            *)
(*                                                                        *)
(*  It is distributed in the hope that it will be useful,                 *)
(*  but WITHOUT ANY WARRANTY; without even the implied warranty of        *)
(*  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the         *)
(*  GNU Lesser General Public License for more details.                   *)
(*                                                                        *)
(*  See the GNU Lesser General Public Licence version 2.1 for more        *)
(*  details (enclosed in the file LGPL).                                  *)
(*                                                                        *)
(**************************************************************************)

(*i $Id: period.mli,v 1.14 2008-02-01 10:48:33 signoles Exp $ i*)

(** A period represents the time passed between two events (a date, a time...).
  Only an interface defining arithmetic operations on periods is defined here.
  An implementation of this interface depends on the kind of an event (see
  module [Time.Period], [Date.Period] and [Calendar.Period]). *)

(** Common interface for all periods. *)
module type S = sig

  type t
    (** Type of a period. *)

  val empty : t
    (** The empty period. *)

  val add : t -> t -> t
    (** Addition of periods. *)

  val sub : t -> t -> t
    (** Substraction of periods. *)

  val opp : t -> t
    (** Opposite of a period. *)

  val compare : t -> t -> int
    (** Comparison function between two periods.
	Same behaviour than [Pervasives.compare]. *)

  val equal: t -> t -> bool
    (** Equality function between two periods. Same behaviour than [(=)]. 
	@since 1.09.0 *)

  val hash: t -> int
    (** Hash function for periods.
	@since 2.0 *)

end
